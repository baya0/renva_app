import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
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

  // Getter to access AppBuilder instance
  AppBuilder get appBuilder => Get.find<AppBuilder>();

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
      // Check if we have the fromForgotPassword flag
      bool isFromForgotPassword = false;
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map;
        isFromForgotPassword = args['fromForgotPassword'] as bool? ?? false;
      }

      print('🔐 Verification successful');
      print('   From forgot password: $isFromForgotPassword');

      // ===== FORGOT PASSWORD FLOW (FROM PROFILE OR LOGIN) =====
      if (isFromForgotPassword) {
        print('🔐 Handling forgot password verification...');

        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;

          // CRITICAL: Extract the RESET token (NOT auth token!)
          String? resetToken = responseData['token'] ?? responseData['reset_token'];

          if (resetToken != null && resetToken.isNotEmpty) {
            print('✅ Reset token received');

            // IMPORTANT: Do NOT set this as auth token!
            // String resetPasswordToken = resetToken;  // Store separately

            PopUpToast.show(tr(LocaleKeys.verification_verification_sent));
            await Future.delayed(Duration(milliseconds: 500));

            // Navigate to YOUR reset password page
            Get.offNamed(
              Pages.reset_password.value, // Or whatever your route is
              arguments: {
                'resetToken': resetToken, // Pass reset token
                'phone': cleanPhone,
                'dialCode': dialCode,
              },
            );
            return;
          } else {
            throw Exception('No reset token received from verification');
          }
        } else {
          throw Exception('Invalid verification response format');
        }
      }

      // ===== NORMAL REGISTRATION/LOGIN FLOW =====
      print('👤 Handling normal verification (registration/login)...');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract AUTHENTICATION data
        String? authToken = responseData['token'];
        bool? isVerified = responseData['phone_verified_at'] != null;
        int? isCompleted = responseData['is_completed'];

        // NOW we can update app state (because it's normal login)
        if (authToken != null && authToken.isNotEmpty) {
          appBuilder.setToken(authToken);
          APIService.instance.setToken(authToken);
        }

        appBuilder.setVerified(isVerified);
        appBuilder.setRole(Role.user);

        // Check profile completion
        if (isCompleted == null || isCompleted != 1) {
          appBuilder.setProfileCompleted(false);
          PopUpToast.show(tr(LocaleKeys.verification_verification_sent));

          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Pages.complete_info.value);
        } else {
          appBuilder.setProfileCompleted(true);

          if (responseData.containsKey('user')) {
            appBuilder.updateFromAPIResponse(responseData);
          }

          PopUpToast.show(tr(LocaleKeys.success_verification_success));
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Pages.home.value);
        }
      }
    } catch (e) {
      print('💥 Error handling successful verification: $e');
      PopUpToast.show(tr(LocaleKeys.errors_something_went_wrong));
    }
  }

  Future<void> _handleForgotPasswordVerificationSuccess() async {
    try {
      PopUpToast.show(tr(LocaleKeys.success_phone_verified_set_password));
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
      PopUpToast.show(tr(LocaleKeys.errors_verification_proceed_failed));
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
