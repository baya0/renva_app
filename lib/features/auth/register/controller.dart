// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';

import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';

class RegisterPageController extends GetxController {
  AppBuilder appBuilder = Get.find();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController password, confirmPassword, phone;
  final RxBool hidePassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    password = TextEditingController();
    confirmPassword = TextEditingController();
    phone = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    password.dispose();
    confirmPassword.dispose();
    phone.dispose();
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Check if it includes country code
    if (!value.contains('+')) {
      return 'Phone number must include country code (e.g., +999)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Check for strong password (optional)
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!(hasUppercase && hasDigits && hasSpecialCharacters)) {
      return 'Password should include uppercase, digits, and special characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  void signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.register,
          method: RequestMethod.Post,
          params: {"success": true},
          body: {"phone_number": phone.text, "password": password.text},
        ),
      );

      if (response.success) {
        // Signup successful, navigate to verification page
        Get.toNamed(Pages.verify.value, arguments: {"phone": phone.text});
      } else {
        // Signup failed
        print("Signup failed: ${response.message}");
      }
    } catch (e) {
      print("Signup error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
