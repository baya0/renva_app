import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';

class ResetPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? resetPasswordToken;

  final RxBool isLoading = false.obs;
  final RxBool hideNewPassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupTokenFromArguments();
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Setup token from verification page
  void _setupTokenFromArguments() {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      resetPasswordToken = args['resetToken'] as String?;
    }
  }

  // Validate new password
  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_password_required);
    }
    if (value.length < 6) {
      return tr(LocaleKeys.forms_password_min_length);
    }
    return null;
  }

  // Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.validation_confirm_password_required);
    }
    if (value != newPasswordController.text) {
      return tr(LocaleKeys.validation_passwords_do_not_match);
    }
    return null;
  }

  // Toggle password visibility
  void toggleNewPasswordVisibility() {
    hideNewPassword.value = !hideNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  // Clear error when user starts typing
  void onPasswordChanged(String value) {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  // Reset password
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _makeResetPasswordAPICall();
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.messages_network_error_check_connection));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _makeResetPasswordAPICall() async {
    /// Validate i have the required token
    if (resetPasswordToken == null || resetPasswordToken!.isEmpty) {
      PopUpToast.show(tr(LocaleKeys.errors_missing_reset_token));
      Get.offAllNamed(Pages.login.value);
      return;
    }

    Map<String, dynamic> jsonData = {
      'password': newPasswordController.text.trim(),
      'password_confirmation': confirmPasswordController.text.trim(),
    };

    // CRITICAL: the reset request must be authorized with the short-lived RESET
    // token issued by OTP verification — NOT the shared app auth token. Passing
    // it explicitly here also stops the previously-logged-in user's stale
    // Authorization header (merged in from the shared APIService) from leaking
    // into this request when reset is triggered from the profile screen.
    ResponseModel response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.resetPassword,
        method: RequestMethod.Post,
        body: jsonData,
        copyHeader: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resetPasswordToken',
        },
      ),
    );

    if (response.success) {
      await _handleResetPasswordSuccess(response);
    } else {
      _handleResetPasswordError(response);
    }
  }

  // Handle successful password reset
  Future<void> _handleResetPasswordSuccess(ResponseModel response) async {
    try {
      // Extract success message
      String message = tr(LocaleKeys.success_password_reset_successful);
      try {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
      } catch (e) {
        print(' Could not extract message from response: $e');
      }

      // Show success message
      PopUpToast.show(message);

      // Clear form
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Navigate back to login after short delay
      await Future.delayed(Duration(milliseconds: 1500));
      Get.offAllNamed(Pages.login.value);

      // Show another toast after navigation
      await Future.delayed(Duration(milliseconds: 500));
      PopUpToast.show(tr(LocaleKeys.success_login_with_new_password));
    } catch (e) {
      print(' Error processing reset password success: $e');
      PopUpToast.show(tr(LocaleKeys.errors_password_reset_processing_failed));

      // Still navigate to login as backup
      Get.offAllNamed(Pages.login.value);
    }
  }

  // Handle reset password error response
  void _handleResetPasswordError(ResponseModel response) {
    final errorMsg = extractResponseMessage(
      response,
      tr(LocaleKeys.errors_password_reset_failed),
    );
    errorMessage.value = errorMsg;
    PopUpToast.show(errorMsg);
  }

  // Go back to verification page
  void goBack() {
    Get.back();
  }

  // Cancel and go to login
  void cancelAndGoToLogin() {
    Get.offAllNamed(Pages.login.value);
  }
}
