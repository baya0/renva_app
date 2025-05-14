import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';

class VerifyPhoneController extends GetxController {
  // Form and input management
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxInt resendCooldown = 0.obs;
  final RxString errorMessage = ''.obs;

  // Verification timer
  Timer? _resendTimer;

  // Phone number passed from previous screen
  final String? initialPhoneNumber;

  VerifyPhoneController({this.initialPhoneNumber});

  @override
  void onInit() {
    super.onInit();

    // Pre-fill phone number if provided
    if (initialPhoneNumber != null) {
      phoneController.text = initialPhoneNumber!;
      _requestVerificationCode();
    }
  }

  @override
  void onClose() {
    // Dispose controllers and cancel timer
    phoneController.dispose();
    codeController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // Validation method for verification code
  String? validateVerificationCode(String? value) {
    return Validators.validateRequired(value, 'verification_code'.tr);
  }

  // Request verification code
  Future<void> _requestVerificationCode() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.requestVerificationCode,
          method: RequestMethod.Post,
          body: {"phone_number": phoneController.text},
        ),
      );

      if (response.success) {
        _startResendCooldown();
        // Verification code sent successfully
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'error_occurred'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify phone number
  Future<void> verifyPhoneNumber() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      //For testing: Check if code is 1234
      if (codeController.text == "1234") {
        // Set user as verified
        final appBuilder = Get.find<AppBuilder>();
        appBuilder.setVerified(true);
        Get.offAllNamed(Pages.complete_info.value);
      } else {
        errorMessage.value = 'Invalid verification code. Use 1234 for testing.';
      }
    } catch (e) {
      errorMessage.value = 'error_occurred'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // Start resend cooldown timer
  void _startResendCooldown() {
    resendCooldown.value = 60; // 60 seconds cooldown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Resend verification code
  void resendVerificationCode() {
    if (resendCooldown.value == 0) {
      _requestVerificationCode();
    }
  }

  // Navigation methods
  void goBack() => Get.back();
  void goToSignup() => Get.toNamed(Pages.signup.value);
}
