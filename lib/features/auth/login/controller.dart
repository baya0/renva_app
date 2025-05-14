// ignore_for_file: avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';

class LoginPageController extends GetxController {
  AppBuilder appBuilder = Get.find();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController password, phone;
  final RxBool hidePassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    password = TextEditingController();
    phone = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    password.dispose();
    phone.dispose();
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.contains('+')) {
      return 'Phone number must include country code (e.g., +963)';
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
    return null;
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  void forgotPassword() {
    // Implement forgot password functionality
    Get.dialog(
      AlertDialog(
        title: Text(tr('Forgot Password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('Enter your email to receive a reset link')),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: tr('Email'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr('Cancel'))),
          ElevatedButton(
            onPressed: () {
              // Implement password reset API call
              Get.back();
              // Password reset email sent
            },
            child: Text(tr('Send')),
          ),
        ],
      ),
    );
  }

  void joinAsGuest() {
    // Set role to guest and navigate to home screen
    appBuilder.setRole(Role.guest);
    Get.offAllNamed(Pages.home.value);
  }

  void goToSignup() {
    Get.toNamed(Pages.signup.value);
  }

  void login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.login,
          method: RequestMethod.Post,
          params: {"success": true},
          body: {"phone_number": phone.text, "password": password.text},
        ),
      );

      if (response.success) {
        appBuilder.setRole(Role.user);
        appBuilder.setToken(response.data['access_token']);
        Get.offAllNamed(Pages.home.value);
      } else {
        // Login failed
        print("Login failed: ${response.message}");
      }
    } catch (e) {
      print("Login error: $e");
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
  }
}
