// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once using tag to prevent multiple instances
    final controller = Get.put(LoginPageController(), tag: 'login_controller', permanent: true);

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
            ),
          ),
          child: Column(
            children: [
              // Logo
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Center(child: Assets.images.logo.logo.svg(width: 90, height: 90)),
              ),

              Expanded(
                child: Container(
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
                          // Login to your account
                          Row(
                            children: [
                              Text(tr('Welcome to'), style: theme.textTheme.headlineSmall),
                              const SizedBox(width: 10),
                              Assets.images.logo.renva.svg(
                                width: 20,
                                height: 20,
                                color: StyleRepo.deepBlue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                tr('Login to your account.'),
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(width: 5),
                              Assets.icons.emojis.veryHappyFace.svg(
                                width: 20,
                                height: 20,
                                color: StyleRepo.forestGreen,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            tr('Enter the following info to reach your account.'),
                            style: theme.textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 40),

                          // Phone Number
                          Text(tr('Phone Number'), style: theme.textTheme.bodyMedium),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: controller.phone,
                            keyboardType: TextInputType.phone,
                            validator: controller.validatePhone,
                            decoration: InputDecoration(
                              hintText: 'Ex: +963 111 222 333',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Assets.icons.messages.phoneRing2.svg(width: 20, height: 20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Text(tr('Password'), style: theme.textTheme.bodyMedium),

                          const SizedBox(height: 8),

                          Obx(
                            () => TextFormField(
                              controller: controller.password,
                              obscureText: controller.hidePassword.value,
                              validator: controller.validatePassword,
                              decoration: InputDecoration(
                                hintText: '••• ••• •••',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Assets.icons.document.keyhole.svg(width: 20, height: 20),
                                ),
                                suffixIcon: IconButton(
                                  icon:
                                      controller.hidePassword.value
                                          ? Assets.icons.essentials.eyeOff.svg(
                                            width: 20,
                                            height: 20,
                                            color: StyleRepo.grey,
                                          )
                                          : Assets.icons.essentials.eye.svg(
                                            width: 20,
                                            height: 20,
                                            color: StyleRepo.grey,
                                          ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: controller.forgotPassword,
                              child: Text(
                                tr('Forget Password ?'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: StyleRepo.deepBlue,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login Button
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value ? null : controller.login,
                                child:
                                    controller.isLoading.value
                                        ? const CircularProgressIndicator(
                                          color: StyleRepo.softWhite,
                                        )
                                        : Text(tr('Login')),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Sign Up
                          Center(
                            child: TextButton(
                              onPressed: controller.goToSignup,
                              child: Text(
                                tr('Sign up'),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: StyleRepo.forestGreen,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Join as a guest
                          Center(
                            child: InkWell(
                              onTap: controller.joinAsGuest,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.login, size: 16, color: StyleRepo.deepBlue),
                                  const SizedBox(width: 5),
                                  Text(
                                    tr('Join us a guest'),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: StyleRepo.deepBlue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Transparent logo watermark at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
