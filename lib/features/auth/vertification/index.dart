import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/features/auth/vertification/controller.dart';

class VerifyPhonePage extends StatelessWidget {
  const VerifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once using tag to prevent multiple instances
    final controller = Get.put(
      VerifyPhoneController(),
      tag: 'verify_controller',
      permanent: true,
    );

    // Pinput theme configuration for 4 digits
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: StyleRepo.softGrey),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: StyleRepo.deepBlue, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: StyleRepo.softGreen,
      border: Border.all(color: StyleRepo.forestGreen),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Verify Phone Number',
          style: TextStyle(color: StyleRepo.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: StyleRepo.black),
          onPressed: controller.goBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Verification icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StyleRepo.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user,
                      size: 40,
                      color: StyleRepo.forestGreen,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Verify Phone Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StyleRepo.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Enter the Code Sent To **** *** **45',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: StyleRepo.grey),
                  ),

                  const SizedBox(height: 40),

                  // Verification Code Input - 4 digits
                  Pinput(
                    length: 4, // Changed to 4 digits
                    controller: controller.codeController,
                    validator: controller.validateVerificationCode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onCompleted: (_) => controller.verifyPhoneNumber(),
                  ),

                  // Error Message
                  Obx(() {
                    final error = controller.errorMessage.value;
                    return error.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : const SizedBox.shrink();
                  }),

                  const SizedBox(height: 32),

                  // Resend timer
                  Obx(() {
                    final cooldown = controller.resendCooldown.value;
                    return Text(
                      cooldown > 0
                          ? '00:${cooldown.toString().padLeft(2, '0')} second'
                          : 'Resend Code',
                      style: TextStyle(
                        color:
                            cooldown > 0 ? StyleRepo.grey : StyleRepo.deepBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : controller.verifyPhoneNumber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StyleRepo.deepBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            controller.isLoading.value
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : const Text(
                                  'Confirm',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
