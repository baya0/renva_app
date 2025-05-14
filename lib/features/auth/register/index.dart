import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/features/auth/register/controller.dart';

import '../../../core/routes/routes.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../gen/assets.gen.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once using tag to prevent multiple instances
    final controller = Get.put(
      RegisterPageController(),
      tag: 'register_controller',
      permanent: true,
    );

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
            ),
          ),
          child: Column(
            children: [
              // Back button row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:
                          () => Get.dialog(
                            AlertDialog(
                              title: Text(
                                'Go Back?',
                                style: theme.textTheme.titleMedium,
                              ),
                              content: Text(
                                tr(
                                  'Your profile information will not be saved. Do you want to go back?',
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Cancel',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.offAllNamed(Pages.login.value);
                                  },
                                  child: Text(
                                    tr('Go Back'),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      child: Assets.icons.arrows.leftCircle.svg(
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(tr('back'), style: theme.textTheme.titleSmall),
                  ],
                ),
              ),

              // Logo
              SizedBox(
                height: size.height * 0.15,
                child: Center(
                  child: Assets.images.logo.logo.svg(width: 90, height: 90),
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: AppStyle.roundedTopContainer,
                      padding: AppStyle.contentPadding,
                      child: SingleChildScrollView(
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              Text(
                                tr('Create New Account'),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                tr(
                                  'add your information to create new account',
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Phone Number
                              _buildFormField(
                                context: context,
                                label: tr('Phone Number'),
                                controller: controller.phone,
                                validator: controller.validatePhone,
                                hintText: 'Ex: +999 123 456 789',
                                prefixIcon:
                                    Assets.icons.messages.phoneRing2.svg(),
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 20),

                              // Password
                              Obx(
                                () => _buildFormField(
                                  context: context,
                                  label: tr('Password'),
                                  controller: controller.password,
                                  validator: controller.validatePassword,
                                  hintText: tr('add strong password'),
                                  prefixIcon:
                                      Assets.icons.document.keyhole.svg(),
                                  obscureText: controller.hidePassword.value,
                                  suffixIcon: IconButton(
                                    icon:
                                        controller.hidePassword.value
                                            ? Assets.icons.essentials.eyeOff
                                                .svg()
                                            : Assets.icons.essentials.eye.svg(),
                                    color: StyleRepo.grey,

                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Confirm Password
                              Obx(
                                () => _buildFormField(
                                  context: context,
                                  label: tr('Confirm Password'),
                                  controller: controller.confirmPassword,
                                  validator: controller.validateConfirmPassword,
                                  hintText: tr('Confirm Password'),
                                  prefixIcon:
                                      Assets.icons.document.keyhole.svg(),
                                  obscureText:
                                      controller.hideConfirmPassword.value,
                                  suffixIcon: IconButton(
                                    icon:
                                        controller.hidePassword.value
                                            ? Assets.icons.essentials.eyeOff
                                                .svg()
                                            : Assets.icons.essentials.eye.svg(),
                                    color: StyleRepo.grey,
                                    onPressed:
                                        controller
                                            .toggleConfirmPasswordVisibility,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Confirm Button
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        controller.isLoading.value
                                            ? null
                                            : controller.signup,
                                    child:
                                        controller.isLoading.value
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(tr('Confirm')),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Transparent logo watermark at the bottom
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: 0.05,
                          child: Assets.images.logo.logo.svg(
                            width: 200,
                            height: 200,
                            color: StyleRepo.deepBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build form fields with consistent styling
  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required String hintText,
    required Widget prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: prefixIcon, // Use the Widget directly
                ),
                // Vertical divider line positioned at the right edge of the prefix area
                Positioned(
                  right: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(width: 1, color: Colors.grey.shade300),
                ),
              ],
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
