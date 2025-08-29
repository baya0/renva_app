import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/style/repo.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(ResetPasswordController());

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      appBar: AppBar(
        backgroundColor: StyleRepo.softWhite,
        elevation: 0,
        leading: IconButton(
          icon: Assets.icons.arrows.leftCircle.svg(
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(StyleRepo.deepBlue, BlendMode.srcIn),
          ),
          onPressed: controller.goBack,
        ),
        title: Text(
          'Reset Password',
          style: theme.textTheme.titleLarge?.copyWith(
            color: StyleRepo.deepBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const SizedBox(height: 20),
                Text(
                  'Set New Password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new password for your account',
                  style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                ),
                const SizedBox(height: 32),

                const SizedBox(height: 32),

                // New Password Field
                Text(
                  'New Password',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: controller.newPasswordController,
                    obscureText: controller.hideNewPassword.value,
                    onChanged: controller.onPasswordChanged,
                    validator: controller.validateNewPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                      filled: true,
                      fillColor: StyleRepo.softGrey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.softGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.softGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: IconButton(
                        icon:
                            controller.hideNewPassword.value
                                ? Assets.icons.essentials.eyeOff.svg(
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    StyleRepo.grey,
                                    BlendMode.srcIn,
                                  ),
                                )
                                : Assets.icons.essentials.eyeOn.svg(
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    StyleRepo.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                        onPressed: controller.toggleNewPasswordVisibility,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.deepBlue),
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm Password Field
                Text(
                  'Confirm Password',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.hideConfirmPassword.value,
                    onChanged: controller.onPasswordChanged,
                    validator: controller.validateConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                      filled: true,
                      fillColor: StyleRepo.softGrey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.softGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.softGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: IconButton(
                        icon:
                            controller.hideConfirmPassword.value
                                ? Assets.icons.essentials.eyeOff.svg(
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    StyleRepo.grey,
                                    BlendMode.srcIn,
                                  ),
                                )
                                : Assets.icons.essentials.eyeOn.svg(
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    StyleRepo.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.deepBlue),
                  ),
                ),

                // Error Message
                Obx(
                  () =>
                      controller.errorMessage.value.isNotEmpty
                          ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: StyleRepo.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: StyleRepo.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: StyleRepo.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : const SizedBox(),
                ),

                const Spacer(),

                // Reset Password Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StyleRepo.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child:
                          controller.isLoading.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                              : Text(
                                'Reset Password',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: controller.cancelAndGoToLogin,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: StyleRepo.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
