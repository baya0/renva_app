import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:renva0/core/style/repo.dart';

import '../../../core/localization/strings.dart';
import '../../../core/widgets/auth_container.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class VerifyPhonePage extends StatelessWidget {
  final String? phoneNumber;

  const VerifyPhonePage({super.key, this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyPhoneController(initialPhoneNumber: phoneNumber));

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildBackButton(theme, controller),

              _buildLogo(size),

              _buildMainContainer(context, controller, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme, VerifyPhoneController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Assets.icons.arrows.leftCircle.svg(width: 24, height: 24, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            tr(LocaleKeys.common_back),
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Logo widget
  Widget _buildLogo(Size size) {
    return SizedBox(
      height: size.height * 0.18,
      child: Center(child: Assets.images.logo.logo.svg(width: 90, height: 90, color: Colors.white)),
    );
  }

  Widget _buildMainContainer(
    BuildContext context,
    VerifyPhoneController controller,
    ThemeData theme,
  ) {
    return Expanded(
      child: AuthContainer(
        showWatermark: true,
        watermarkColor: StyleRepo.deepBlue,
        addScrolling: true,
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildTitle(theme),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(child: _buildInstructionText(theme)),
                  const SizedBox(width: 12),
                  _buildPhoneNumberDisplay(controller, theme),
                ],
              ),

              const SizedBox(height: 30),

              _buildPinInput(controller, theme),

              const SizedBox(height: 20),

              _buildResendSection(controller, theme),

              const SizedBox(height: 40),

              _buildConfirmButton(controller, theme),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Row(
      children: [
        Text(
          tr(LocaleKeys.verification_title),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: StyleRepo.black,
          ),
        ),
        const SizedBox(width: 8),
        Assets.icons.document.check.svg(width: 24, height: 24, color: StyleRepo.forestGreen),
      ],
    );
  }

  Widget _buildInstructionText(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      child: Text(
        tr(LocaleKeys.verification_subtitle),
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildPhoneNumberDisplay(VerifyPhoneController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Center(
        child: Text(
          controller.phoneController.text.isNotEmpty
              ? _hidePhoneNumber(controller.phoneController.text)
              : '**** *** **45',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: StyleRepo.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput(VerifyPhoneController controller, ThemeData theme) {
    final defaultStyle = PinTheme(
      width: 60,
      height: 60,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: StyleRepo.black,
      ),
      decoration: BoxDecoration(
        color: StyleRepo.darkwhite,
        border: Border.all(color: StyleRepo.softGrey),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final focusedStyle = defaultStyle.copyDecorationWith(
      border: Border.all(color: StyleRepo.deepBlue, width: 2),
    );

    final filledStyle = defaultStyle.copyDecorationWith(
      color: StyleRepo.softGreen,
      border: Border.all(color: StyleRepo.forestGreen),
    );

    final errorStyle = defaultStyle.copyDecorationWith(
      border: Border.all(color: Colors.red, width: 2),
    );

    return Center(
      child: Obx(() {
        final hasError = controller.errorMessage.value.isNotEmpty;

        return Pinput(
          length: 4,
          controller: controller.codeController,
          validator: controller.validateVerificationCode,
          defaultPinTheme: hasError ? errorStyle : defaultStyle,
          focusedPinTheme: focusedStyle,
          submittedPinTheme: filledStyle,
          errorPinTheme: errorStyle,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
          onCompleted: (_) => controller.verifyPhoneNumber(),
          onChanged: (value) {
            if (controller.errorMessage.value.isNotEmpty) {
              controller.errorMessage.value = '';
            }
          },
        );
      }),
    );
  }

  Widget _buildResendSection(VerifyPhoneController controller, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Obx(() {
            final cooldown = controller.resendCooldown.value;
            if (cooldown > 0) {
              return Text(
                tr(
                  LocaleKeys.messages_resend_code_in_seconds,
                  namedArgs: {'seconds': cooldown.toString().padLeft(2, '0')},
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 8),

          Obx(
            () => TextButton(
              onPressed:
                  controller.resendCooldown.value > 0 ? null : controller.resendVerificationCode,
              child: Text(
                tr(LocaleKeys.verification_resend_code),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      controller.resendCooldown.value > 0 ? Colors.grey[400] : StyleRepo.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(VerifyPhoneController controller, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.verifyPhoneNumber,
        child: Text(tr(LocaleKeys.common_confirm)),
      ),
    );
  }

  // Helper method to hide most of the phone number
  String _hidePhoneNumber(String phone) {
    if (phone.length > 7) {
      return "${phone.substring(0, phone.length - 6)} *** ***${phone.substring(phone.length - 2)}";
    }
    return phone;
  }
}
