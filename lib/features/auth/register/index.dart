import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../core/constants/controllers_tags.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/auth_container.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      RegisterPageController(),
      tag: ControllersTags.registerController,
    );

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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:
                          () => Get.dialog(
                            AlertDialog(
                              title: Text(
                                tr(LocaleKeys.dialogs_go_back_title),
                                style: theme.textTheme.titleMedium,
                              ),
                              content: Text(
                                tr(LocaleKeys.profile_profile_not_saved),
                                style: theme.textTheme.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    tr(LocaleKeys.common_cancel),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.offAllNamed(Pages.login.value);
                                  },
                                  child: Text(
                                    tr(LocaleKeys.common_go_back),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      child: Assets.icons.arrows.leftCircle.svg(
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          StyleRepo.softWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr(LocaleKeys.common_back),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: StyleRepo.softWhite,
                      ),
                    ),
                  ],
                ),
              ),

              // Logo section
              SizedBox(
                height: size.height * 0.18,
                child: Center(
                  child: Assets.images.logo.logo.svg(
                    width: 90,
                    height: 90,
                    colorFilter: const ColorFilter.mode(
                      StyleRepo.softWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: AuthContainer(
                  showWatermark: true,
                  addScrolling: true,
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          tr(LocaleKeys.auth_signup_title),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          tr(LocaleKeys.auth_signup_subtitle),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 30),

                        _buildLibPhoneNumberInput(context, controller, theme),

                        const SizedBox(height: 20),

                        Obx(
                          () => _buildFormField(
                            context: context,
                            label: tr(LocaleKeys.auth_password),
                            controller: controller.password,
                            validator: controller.validatePassword,
                            hintText: tr(LocaleKeys.auth_add_strong_password),
                            prefixIcon: Assets.icons.document.keyhole.svg(
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[600]!,
                                BlendMode.srcIn,
                              ),
                            ),
                            obscureText: controller.hidePassword.value,
                            suffixIcon: IconButton(
                              icon:
                                  controller.hidePassword.value
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
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            onChanged: controller.onPasswordChanged,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Obx(
                          () => _buildFormField(
                            context: context,
                            label: tr(LocaleKeys.auth_confirm_password),
                            controller: controller.confirmPassword,
                            validator: controller.validateConfirmPassword,
                            hintText: tr(
                              LocaleKeys.auth_confirm_password_placeholder,
                            ),
                            prefixIcon: Assets.icons.document.keyhole.svg(
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[600]!,
                                BlendMode.srcIn,
                              ),
                            ),
                            obscureText: controller.hideConfirmPassword.value,
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
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                            onChanged: controller.onConfirmPasswordChanged,
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                !controller.canSubmit
                                    ? null
                                    : controller.signup,
                            child: Text(tr(LocaleKeys.common_confirm)),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibPhoneNumberInput(
    BuildContext context,
    RegisterPageController controller,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.auth_phone_number),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: StyleRepo.softWhite,
            border: Border.all(color: Colors.transparent),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: controller.onPhoneChanged,
            onInputValidated: controller.onPhoneValidated,
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              useBottomSheetSafeArea: true,
              setSelectorButtonAsPrefixIcon: true,
              leadingPadding: 16,
              trailingSpace: false,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            selectorTextStyle: const TextStyle(
              color: StyleRepo.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            initialValue: controller.selectedPhoneNumber,
            textFieldController: controller.phoneController,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            inputDecoration: InputDecoration(
              hintText: tr(LocaleKeys.auth_phone_placeholder),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              //  subtle divider between country selector and phone input
              prefixIcon: Container(
                width: 80,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
              ),
            ),
            onSaved: (PhoneNumber number) {
              controller.selectedPhoneNumber = number;
            },
            spaceBetweenSelectorAndTextField: 0,
            countries: const ['SY', 'US', 'GB', 'SA', 'AE', 'TR'],
            searchBoxDecoration: InputDecoration(
              hintText: tr(LocaleKeys.common_search),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
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
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
            prefixIcon: Container(
              width: 60,
              height: 48,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: prefixIcon,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: StyleRepo.softWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}
