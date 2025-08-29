import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../core/localization/strings.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../core/widgets/auth_container.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginPageController(), tag: 'login_controller', permanent: true);

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
              SizedBox(
                height: size.height * 0.15,
                child: Center(
                  child: Assets.images.logo.logo.svg(
                    width: 90,
                    height: 90,
                    colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
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

                        Row(
                          children: [
                            Text(
                              tr(LocaleKeys.common_welcome_to),
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(width: 10),
                            Assets.images.logo.renva.svg(
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                StyleRepo.deepBlue,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Text(
                              tr(LocaleKeys.auth_login_title),
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(width: 5),
                            Assets.icons.emojis.veryHappyFace.svg(
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                StyleRepo.forestGreen,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(tr(LocaleKeys.auth_login_subtitle), style: theme.textTheme.bodyMedium),

                        const SizedBox(height: 30),

                        _buildLibPhoneNumberInput(context, controller, theme),

                        const SizedBox(height: 20),

                        Obx(
                          () => AppStyle.buildFormField(
                            context: context,
                            label: tr(LocaleKeys.auth_password),
                            controller: controller.password,
                            validator: controller.validatePassword,
                            hintText: tr(LocaleKeys.auth_password_placeholder),
                            prefixIcon: Assets.icons.document.keyhole.svg(width: 20, height: 20),
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
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.forgotPassword,
                            child: Text(
                              tr(LocaleKeys.auth_forgot_password),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: StyleRepo.deepBlue,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.login,
                            child: Text(
                              tr(LocaleKeys.auth_login),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: StyleRepo.softWhite,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: controller.goToSignup,
                            child: Text(
                              tr(LocaleKeys.auth_signup),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: StyleRepo.forestGreen,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Center(
                          child: InkWell(
                            onTap: controller.joinAsGuest,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.login, size: 16, color: StyleRepo.deepBlue),
                                const SizedBox(width: 5),
                                Text(
                                  tr(LocaleKeys.auth_join_as_guest),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: StyleRepo.deepBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
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
    LoginPageController controller,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.auth_phone_number),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StyleRepo.softGrey, width: 1),
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
            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
            inputDecoration: InputDecoration(
              hintText: tr(LocaleKeys.auth_phone_placeholder),
              hintStyle: theme.textTheme.labelSmall,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              // Add a subtle divider between country selector and phone input
              prefixIcon: Container(
                width: 80,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: StyleRepo.softGrey, width: 1)),
                ),
              ),
            ),
            onSaved: (PhoneNumber number) {
              controller.selectedPhoneNumber = number;
            },
            spaceBetweenSelectorAndTextField: 0,
            countries: const ['SY', 'US', 'GB', 'SA', 'AE', 'TR'], // Common countries
            searchBoxDecoration: InputDecoration(
              hintText: tr(LocaleKeys.common_search), //
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
