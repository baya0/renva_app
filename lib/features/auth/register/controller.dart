import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';
import '../../../core/widgets/modern_toast.dart';

class RegisterPageController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Updated for libphonenumber
  late TextEditingController password, confirmPassword, phoneController;
  PhoneNumber? selectedPhoneNumber;

  final RxBool hidePassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;

  // Make phone number reactive
  final RxString selectedPhoneDisplay = ''.obs;
  final RxBool isPhoneValid = false.obs;

  @override
  void onInit() {
    password = TextEditingController();
    confirmPassword = TextEditingController();
    phoneController = TextEditingController();
    _initializeDefaultPhone();
    super.onInit();
  }

  @override
  void onClose() {
    password.dispose();
    confirmPassword.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _initializeDefaultPhone() {
    selectedPhoneNumber = PhoneNumber(phoneNumber: '+963121212', isoCode: 'SY', dialCode: '+963');
    phoneController.text = '121212';
    password.text = '12345678';
    confirmPassword.text = '12345678';

    selectedPhoneDisplay.value = '+963121212';
    isPhoneValid.value = true;
  }

  String? validatePhone(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.phoneNumber == null) {
      return Validators.validateRequired(null, tr(LocaleKeys.auth_phone_number));
    }

    if (phoneNumber.phoneNumber!.isEmpty) {
      return Validators.validateRequired(null, tr(LocaleKeys.auth_phone_number));
    }

    return null;
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

  String? validateConfirmPassword(String? value) {
    return Validators.validateConfirmation(
      value,
      password.text,
      tr(LocaleKeys.auth_confirm_password),
    );
  }

  void onPhoneChanged(PhoneNumber number) {
    selectedPhoneNumber = number;
    clearError();

    selectedPhoneDisplay.value = number.phoneNumber ?? '';
  }

  // Handle phone validation and update reactive variable
  void onPhoneValidated(bool isValid) {
    isPhoneValid.value = isValid;
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  void clearError() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  void onPasswordChanged(String value) => clearError();
  void onConfirmPasswordChanged(String value) => clearError();

  void signup() async {
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

    try {
      await _makeRegistrationAPICall();
    } catch (e) {
      print(' Registration error: $e');
      _showError(tr(LocaleKeys.messages_network_error_check_internet));
    }
  }

  Future<void> _makeRegistrationAPICall() async {
    print(' === LIBPHONENUMBER REGISTRATION DEBUG ===');

    final phoneNumber = selectedPhoneNumber!;

    //  Properly extract clean phone number
    String fullNumber = phoneNumber.phoneNumber!;
    String dialCodeWithPlus = phoneNumber.dialCode!;

    // Remove + from dial code for API
    String cleanDialCode = dialCodeWithPlus.replaceFirst('+', '');

    // Extract clean phone number by removing the dial code part
    String cleanPhone = fullNumber.replaceFirst(dialCodeWithPlus, '');

    Map<String, dynamic> jsonData = {
      'phone': cleanPhone,
      'dial_country_code': cleanDialCode,
      'password': password.text,
      'password_confirmation': confirmPassword.text,
    };

    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.register,
        method: RequestMethod.Post,
        body: jsonData,
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success) {
      await _handleSuccessfulRegistration(response, cleanPhone, cleanDialCode);
    } else {
      _handleRegistrationError(response);
    }
  }

  Future<void> _handleSuccessfulRegistration(
    ResponseModel response,
    String cleanPhone,
    String dialCode,
  ) async {
    final appBuilder = Get.find<AppBuilder>();

    // Set user role to new_user (registered but not verified)
    appBuilder.setRole(Role.new_user);
    appBuilder.setToken(null);
    appBuilder.setVerified(false);
    appBuilder.setProfileCompleted(false);

    String successMessage = tr(LocaleKeys.messages_registration_successful_verify);
    if (response.data is List && (response.data as List).isNotEmpty) {
      successMessage = (response.data as List).first.toString();
    }

    PopUpToast.show(successMessage);

    // Navigate to verification with clean, structured data
    _navigateToVerification(cleanPhone, dialCode);
  }

  // Clean navigation to verification with structured data
  void _navigateToVerification(String cleanPhone, String dialCode) {
    Get.toNamed(
      Pages.verify.value,
      arguments: {
        'phoneNumber': '+$dialCode$cleanPhone',
        'cleanPhone': cleanPhone,
        'dialCode': dialCode,
        'fromRegistration': true,
      },
    );
  }

  void _handleRegistrationError(ResponseModel response) {
    String errorMsg = tr(LocaleKeys.errors_registration_failed);

    try {
      if (response.data is List && (response.data as List).isNotEmpty) {
        List errors = response.data as List;
        String errorText = errors.join('\n');

        // Special handling for common errors
        if (errorText.contains('already exist')) {
          errorMsg =
              '${tr(LocaleKeys.messages_phone_number_already_registered)}\n\n${tr(LocaleKeys.messages_phone_already_in_use)}\n\n${tr(LocaleKeys.messages_solutions)}\n${tr(LocaleKeys.messages_use_login_instead)}\n${tr(LocaleKeys.messages_try_different_number)}\n${tr(LocaleKeys.messages_contact_support)}';
        } else {
          errorMsg = errorText;
        }
      } else if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['errors'] != null) {
          if (errorData['errors'] is List) {
            List errors = errorData['errors'];
            errorMsg = errors.join('\n');
          } else if (errorData['errors'] is Map) {
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
          }
        }
      } else if (response.message.isNotEmpty) {
        errorMsg = response.message;
      }
    } catch (e) {
      print(' Error parsing registration error: $e');
    }

    _showError(errorMsg);
  }

  //  Helper to show error messages
  void _showError(String message) {
    errorMessage.value = message;
    PopUpToast.show(tr(LocaleKeys.errors_registration_failed));
  }

  // Helper getters using reactive variables
  bool get canSubmit =>
      selectedPhoneDisplay.value.isNotEmpty &&
      password.text.isNotEmpty &&
      confirmPassword.text.isNotEmpty;

  String get formattedPhoneNumber =>
      selectedPhoneDisplay.value.isNotEmpty
          ? selectedPhoneDisplay.value
          : tr(LocaleKeys.auth_phone_placeholder);
}
