// ignore_for_file: unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';

class LoginPageController extends GetxController {
  AppBuilder appBuilder = Get.find();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController password, phoneController;
  PhoneNumber? selectedPhoneNumber;
  final RxString errorMessage = ''.obs;

  final RxBool hidePassword = true.obs;

  @override
  void onInit() {
    password = TextEditingController();
    phoneController = TextEditingController();
    _initializeDefaultPhone();
    super.onInit();
  }

  @override
  void onClose() {
    password.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _initializeDefaultPhone() {
    selectedPhoneNumber = PhoneNumber(
      phoneNumber: '+963111111111', //  Valid 9-digit mobile number starting with 9
      isoCode: 'SY',
      dialCode: '+963', //  Include the + sign
    );
    phoneController.text = '111111111';
    password.text = '12345678';
  }

  String? validatePhone(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.phoneNumber == null) {
      return Validators.validateRequired(null, tr(LocaleKeys.auth_phone_number));
    }

    String fullNumber = phoneNumber.phoneNumber!;
    if (fullNumber.isEmpty) {
      return Validators.validateRequired(null, tr(LocaleKeys.auth_phone_number));
    }

    // Special validation for Syrian numbers (optional - for better UX :D)
    if (phoneNumber.isoCode == 'SY') {
      return _validateSyrianNumber(fullNumber);
    }

    // For other countries, let libphonenumber handle validation
    return null;
  }

  // Syrian-specific validation helper
  String? _validateSyrianNumber(String fullNumber) {
    // Remove +963 prefix for checking
    String numberPart = fullNumber.replaceFirst('+963', '');

    // Check mobile numbers (9 digits starting with 9)
    if (numberPart.startsWith('9') && numberPart.length == 9) {
      return null;
    }

    // Check common landline formats
    List<String> validPrefixes = ['11', '21', '23', '31', '33', '41', '43', '51', '53'];
    for (String prefix in validPrefixes) {
      if (numberPart.startsWith(prefix) && numberPart.length >= 7 && numberPart.length <= 8) {
        return null; //  Valid landline number
      }
    }

    // If none match, provide helpful error
    return tr(LocaleKeys.forms_invalid_phone);
  }

  String? validatePassword(String? value) {
    // First check if required
    final requiredCheck = Validators.validateRequired(value, tr(LocaleKeys.auth_password));
    if (requiredCheck != null) return requiredCheck;

    // Then check minimum length
    if (value!.length < 6) {
      return tr(
        LocaleKeys.forms_min_length,
        namedArgs: {'field': tr(LocaleKeys.auth_password), 'min': '6'},
      );
    }
    return null;
  }

  // Handle phone number changes from libphonenumber widget
  void onPhoneChanged(PhoneNumber number) {
    selectedPhoneNumber = number;
    clearError();
  }

  void onPhoneValidated(bool isValid) {}

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  void clearError() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  void onPasswordChanged(String value) => clearError();

  Future<void> forgotPassword() async {
    errorMessage.value = '';

    if (selectedPhoneNumber == null || selectedPhoneNumber!.phoneNumber == null) {
      _showError('Please enter a valid phone number first');
      return;
    }

    String? phoneValidation = validatePhone(selectedPhoneNumber);
    if (phoneValidation != null) {
      _showError(phoneValidation);
      return;
    }

    try {
      await _makeForgotPasswordAPICall();
    } catch (e) {
      print(' Forgot password error: $e');
      _showError('Network error. Please check your connection and try again.');
    }
  }

  Future<void> _makeForgotPasswordAPICall() async {
    final phoneNumber = selectedPhoneNumber!;

    String fullNumber = phoneNumber.phoneNumber!;
    String dialCode = phoneNumber.dialCode!.replaceFirst('+', ''); // Remove + for API
    String cleanPhone = fullNumber.replaceFirst('+$dialCode', '');

    Map<String, dynamic> jsonData = {'phone': cleanPhone, 'dial_country_code': dialCode};

    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.forgetPassword,
        method: RequestMethod.Post,
        body: jsonData,
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success) {
      await _handleForgotPasswordSuccess(response, cleanPhone, dialCode, fullNumber);
    } else {
      _handleForgotPasswordError(response);
    }
  }

  Future<void> _handleForgotPasswordSuccess(
    ResponseModel response,
    String cleanPhone,
    String dialCode,
    String fullNumber,
  ) async {
    try {
      String message = 'Verification code sent to your phone';
      try {
        if (response.data is List && (response.data as List).isNotEmpty) {
          message = (response.data as List).first.toString();
        } else if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
      } catch (e) {
        print(' Could not extract message from response: $e');
      }

      // Show success message
      PopUpToast.show('OTP Sent for Password Reset');

      Get.toNamed(
        Pages.verify.value,
        arguments: {
          'phoneNumber': fullNumber,
          'cleanPhone': cleanPhone,
          'dialCode': dialCode,
          'fromForgotPassword': true,
        },
      );
    } catch (e) {
      print(' Error processing forgot password success: $e');
      _showError('Request succeeded but failed to process response. Please try again.');
    }
  }

  void _handleForgotPasswordError(ResponseModel response) {
    String errorMsg = 'Failed to send verification code. Please try again.';

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
      print(' Error parsing forgot password error response: $e');
    }

    _showError(errorMsg);
  }

  void joinAsGuest() {
    appBuilder.setRole(Role.guest);
    appBuilder.setToken(null);
    appBuilder.setVerified(false);
    appBuilder.setProfileCompleted(false);
    Get.offAllNamed(Pages.home.value);
  }

  void goToSignup() {
    Get.toNamed(Pages.signup.value);
  }

  void login() async {
    errorMessage.value = '';

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedPhoneNumber == null || selectedPhoneNumber!.phoneNumber == null) {
      _showError(
        tr(LocaleKeys.forms_required_field, namedArgs: {'field': tr(LocaleKeys.auth_phone_number)}),
      );
      return;
    }

    // Double-check validation before submitting
    String? phoneValidation = validatePhone(selectedPhoneNumber);
    if (phoneValidation != null) {
      _showError(phoneValidation);
      return;
    }

    try {
      await _makeLoginAPICall();
    } catch (e) {
      _showError(tr(LocaleKeys.messages_network_error_check_connection));
    }
  }

  // LibPhoneNumber API call - Check response to determine navigation
  Future<void> _makeLoginAPICall() async {
    print(' === LIBPHONENUMBER LOGIN DEBUG ===');

    final phoneNumber = selectedPhoneNumber!;

    // Extract clean phone number (without country code and + sign)
    String fullNumber = phoneNumber.phoneNumber!;
    String dialCode = phoneNumber.dialCode!.replaceFirst('+', ''); // Remove + for API
    String cleanPhone = fullNumber.replaceFirst('+$dialCode', '');

    Map<String, dynamic> jsonData = {
      'phone': cleanPhone,
      'dial_country_code': dialCode,
      'password': password.text,
      'device_token': 'FLUTTER_APP',
    };

    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.login,
        method: RequestMethod.Post,
        body: jsonData,
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success && response.data != null) {
      await _handleSuccessfulLogin(response, cleanPhone, dialCode);
    } else {
      _handleLoginError(response);
    }
  }

  Future<void> _handleSuccessfulLogin(
    ResponseModel response,
    String cleanPhone,
    String dialCode,
  ) async {
    try {
      //  Check if API response contains user data with verification/completion status
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if there's user data in the response
        if (responseData.containsKey('phone_verified_at') &&
            responseData.containsKey('is_completed') &&
            responseData.containsKey('token')) {
          String? token = responseData['token'];
          String? phoneVerifiedAt = responseData['phone_verified_at'];
          int isCompleted = responseData['is_completed'] ?? 0;

          // Update app state with API response values
          appBuilder.setToken(token);
          APIService.instance.setToken(token);
          appBuilder.setVerified(phoneVerifiedAt != null);
          appBuilder.setProfileCompleted(isCompleted == 1);
          appBuilder.setRole(Role.user);

          if (phoneVerifiedAt == null) {
            PopUpToast.show(tr(LocaleKeys.messages_please_verify_phone));
            _navigateToVerification(cleanPhone, dialCode);
          } else if (isCompleted != 1) {
            PopUpToast.show(tr(LocaleKeys.messages_please_complete_profile));
            await Future.delayed(Duration(milliseconds: 1000));
            Get.offAllNamed(Pages.complete_info.value);
          } else {
            PopUpToast.show(tr(LocaleKeys.messages_welcome_back));
            await Future.delayed(Duration(milliseconds: 1000));
            Get.offAllNamed(Pages.home.value);
          }

          return;
        }
      }

      // Set user as new_user (needs verification)
      appBuilder.setRole(Role.new_user);
      appBuilder.setVerified(false);
      appBuilder.setToken(null);
      appBuilder.setProfileCompleted(false);

      //  Extract success message

      String message = tr(LocaleKeys.verification_verification_sent);
      try {
        if (response.data is List && (response.data as List).isNotEmpty) {
          message = (response.data as List).first.toString();
        } else if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
      } catch (e) {
        print(' Could not extract message from response: $e');
      }

      PopUpToast.show(tr(LocaleKeys.messages_otp_sent));

      // Navigate to verification with clean data
      _navigateToVerification(cleanPhone, dialCode);
    } catch (e) {
      _showError(tr(LocaleKeys.errors_something_went_wrong));
    }
  }

  // Clean navigation to verification with structured data
  void _navigateToVerification(String cleanPhone, String dialCode) {
    Get.toNamed(
      Pages.verify.value,
      arguments: {
        'phoneNumber': '+$dialCode$cleanPhone',
        'cleanPhone': cleanPhone,
        'dialCode': dialCode,
        'fromLogin': true,
      },
    );
  }

  void _handleLoginError(ResponseModel response) {
    String errorMsg = tr(LocaleKeys.errors_login_failed);

    try {
      if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['error'] != null) {
          errorMsg = errorData['error'].toString();
        } else if (errorData['errors'] != null) {
          if (errorData['errors'] is Map) {
            Map<String, dynamic> errors = errorData['errors'];
            List<String> errorMessages = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });
            errorMsg = errorMessages.join('\n');
          } else if (errorData['errors'] is List) {
            List errors = errorData['errors'];
            errorMsg = errors.join('\n');
          }
        }
      } else if (response.data is List && (response.data as List).isNotEmpty) {
        List errors = response.data as List;
        errorMsg = errors.join('\n');
      } else if (response.message.isNotEmpty) {
        errorMsg = response.message;
      }
    } catch (e) {
      print(' Error parsing login error response: $e');
    }

    _showError(errorMsg);
  }

  void _showError(String message) {
    errorMessage.value = message;
    PopUpToast.show(tr(LocaleKeys.errors_login_failed));
  }
}
