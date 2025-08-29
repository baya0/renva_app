import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';

class VerifyPhoneController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // LibPhoneNumber structured data
  String? cleanPhone;
  String? dialCode;
  String? fullPhoneNumber;
  bool fromRegistration = false;
  bool fromForgotPassword = false;
  String? resetPasswordToken;

  final RxBool isLoading = false.obs;
  final RxInt resendCooldown = 0.obs;
  final RxString errorMessage = ''.obs;

  Timer? _resendTimer;
  final String? initialPhoneNumber;

  VerifyPhoneController({this.initialPhoneNumber});

  @override
  void onInit() {
    super.onInit();
    _setupPhoneNumberFromLibPhone();
  }

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // LIBPHONENUMBER: Setup from structured arguments
  void _setupPhoneNumberFromLibPhone() {
    // Get structured data from arguments
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      fullPhoneNumber = args['phoneNumber'] as String?;
      cleanPhone = args['cleanPhone'] as String?;
      dialCode = args['dialCode'] as String?;
      fromRegistration = args['fromRegistration'] == true;
      fromForgotPassword = args['fromForgotPassword'] == true; // Add this line
    }

    // Fallback to constructor parameter
    if (fullPhoneNumber == null && initialPhoneNumber != null) {
      fullPhoneNumber = initialPhoneNumber;
    }

    // Ultimate fallback
    if (fullPhoneNumber == null) {
      fullPhoneNumber = '+963121212';
      cleanPhone = '121212';
      dialCode = '963';
    }

    // Set display phone
    phoneController.text = fullPhoneNumber!;
  }

  // Validation for 4-digit OTP
  String? validateVerificationCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(
        LocaleKeys.forms_required_field,
        namedArgs: {'field': tr(LocaleKeys.verification_code_label)},
      );
    }
    if (value.length != 4) {
      return tr(
        LocaleKeys.forms_min_length,
        namedArgs: {'field': tr(LocaleKeys.verification_code_label), 'min': '4'},
      );
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return tr(LocaleKeys.verification_invalid_code);
    }
    return null;
  }

  Future<void> verifyPhoneNumber() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String enteredCode = codeController.text.trim();
      await _handleVerificationAPI(enteredCode);
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.messages_network_error_check_connection));
    } finally {
      isLoading.value = false;
    }
  }

  // LIBPHONENUMBER: Clean API call with structured data
  Future<void> _handleVerificationAPI(String code) async {
    // Validate we have the required data
    if (cleanPhone == null || dialCode == null) {
      _showPhoneNumberError();
      return;
    }

    Map<String, dynamic> jsonData = {
      'phone': cleanPhone!,
      'dial_country_code': dialCode!,
      'otp': code,
      'device_token': 'FLUTTER_APP',
    };

    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.verifyOtp,
        method: RequestMethod.Post,
        body: jsonData,
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success && response.data != null) {
      await _handleSuccessfulVerification(response);
    } else {
      _handleVerificationError(response);
    }
  }

  Future<void> _handleSuccessfulVerification(ResponseModel response) async {
    try {
      // Check if this is a forgot password flow
      if (fromForgotPassword) {
        // Extract the reset token from the verification response
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          resetPasswordToken = responseData['token']; // or whatever the token field is called

          if (resetPasswordToken != null) {
            await _handleForgotPasswordVerificationSuccess();
            return;
          } else {
            throw Exception('No reset token received from verification');
          }
        } else {
          throw Exception('Invalid verification response format');
        }
      }

      // Original registration/login verification logic (unchanged)
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract key values from API response
        String? phoneVerifiedAt = responseData['phone_verified_at'];
        int isCompleted = responseData['is_completed'] ?? 0;

        // Update app state with API response values
        final appBuilder = Get.find<AppBuilder>();
        appBuilder.updateFromAPIResponse(responseData);

        // Navigate based on API response values
        if (phoneVerifiedAt != null && isCompleted == 1) {
          PopUpToast.show(tr(LocaleKeys.messages_phone_verified_complete));
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Pages.home.value);
        } else if (phoneVerifiedAt != null && isCompleted != 1) {
          // User is verified but profile incomplete
          PopUpToast.show(tr(LocaleKeys.messages_please_complete_profile_info));
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Pages.complete_info.value);
        } else {
          // Something went wrong with verification
          throw Exception(tr(LocaleKeys.verification_verification_failed));
        }
      } else {
        throw Exception(tr(LocaleKeys.verification_verification_failed));
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.verification_verification_failed));

      // Fallback navigation
      final appBuilder = Get.find<AppBuilder>();
      appBuilder.refreshNavigation();
    }
  }

  Future<void> _handleForgotPasswordVerificationSuccess() async {
    try {
      PopUpToast.show('Phone verified! Now set your new password.');
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate to reset password page with the token (not phone data)
      Get.offNamed(
        Pages.reset_password.value,
        arguments: {
          'resetToken':
              resetPasswordToken, // Pass the token instead of phone data ??? asking about this
        },
      );
    } catch (e) {
      print(' Error handling forgot password verification: $e');
      PopUpToast.show('Verification successful but failed to proceed. Please try again.');
    }
  }

  // Handle verification error
  void _handleVerificationError(ResponseModel response) {
    String errorMsg = tr(LocaleKeys.verification_invalid_code);

    try {
      if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['error'] != null) {
          errorMsg = errorData['error'].toString();
        }
      } else if (response.data is List && (response.data as List).isNotEmpty) {
        List errors = response.data as List;
        errorMsg = errors.join('\n');
      } else if (response.message.isNotEmpty) {
        errorMsg = response.message;
      }
    } catch (e) {
      print(' Error parsing error response: $e');
    }

    errorMessage.value = errorMsg;
    PopUpToast.show(tr(LocaleKeys.verification_verification_failed));
  }

  Future<void> resendVerificationCode() async {
    if (resendCooldown.value > 0) {
      PopUpToast.show(tr(LocaleKeys.messages_please_wait));
      return;
    }

    // Validate we have the required data
    if (cleanPhone == null || dialCode == null) {
      _showPhoneNumberError();
      return;
    }

    // Start cooldown timer
    resendCooldown.value = 60;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });

    try {
      Map<String, dynamic> jsonData = {'phone': cleanPhone!, 'dial_country_code': dialCode!};

      // Used different endpoint for forgot password resend >>>
      String endpoint = fromForgotPassword ? EndPoints.forgetPassword : EndPoints.resendOtp;

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: endpoint,
          method: RequestMethod.Post,
          body: jsonData,
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show(tr(LocaleKeys.messages_code_resent));
      } else {
        // Cancel cooldown on failure
        _resendTimer?.cancel();
        resendCooldown.value = 0;
        PopUpToast.show(tr(LocaleKeys.messages_resend_failed));
      }
    } catch (e) {
      print(' Resend error: $e');

      // Cancel cooldown on network error
      _resendTimer?.cancel();
      resendCooldown.value = 0;
      PopUpToast.show(tr(LocaleKeys.messages_failed_resend_check_connection));
    }
  }

  void goBack() {
    Get.back();
  }

  // Clear error when user starts typing
  void onCodeChanged(String value) {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  // Show error when phone number data is missing
  void _showPhoneNumberError() {
    PopUpToast.show(tr(LocaleKeys.errors_something_went_wrong));

    // Navigate back to login if phone data is missing
    Get.offAllNamed(Pages.login.value);
  }
}
