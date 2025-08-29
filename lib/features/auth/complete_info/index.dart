import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/controllers_tags.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../core/widgets/auth_container.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class CompleteInfoPage extends StatelessWidget {
  const CompleteInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CompleteInfoController(),
      tag: ControllersTags.completeInfoController,
      permanent: true,
    );

    final theme = Theme.of(context);

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr(LocaleKeys.common_back),
                      style: theme.textTheme.titleSmall?.copyWith(color: StyleRepo.softWhite),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: AuthContainer(
                  showWatermark: true,
                  watermarkOpacity: 0.03,
                  addScrolling: true,
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        //  Title
                        Text(
                          tr(LocaleKeys.profile_complete_profile),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),

                        const SizedBox(height: 8),

                        //  Subtitle
                        Text(
                          tr(LocaleKeys.profile_complete_subtitle),
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 30),

                        // Profile Photo and ID Photo Section
                        Column(
                          children: [
                            //  Profile Photo Section
                            Obx(
                              () => Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: StyleRepo.softGrey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: StyleRepo.softGrey, width: 1),
                                      image:
                                          controller.profileImage.value.isNotEmpty
                                              ? DecorationImage(
                                                image: FileImage(
                                                  File(controller.profileImage.value),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        controller.profileImage.value.isEmpty
                                            ? Assets.icons.essentials.circleUser.svg(
                                              width: 36,
                                              height: 36,
                                              colorFilter: ColorFilter.mode(
                                                StyleRepo.grey,
                                                BlendMode.srcIn,
                                              ),
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: controller.pickProfilePhoto,
                                    child: Text(
                                      tr(LocaleKeys.profile_add_profile_photo),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            //  ID Photo Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tr(LocaleKeys.profile_id_photo),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: controller.pickIdPhoto,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: StyleRepo.grey,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Assets.icons.essentials.photoCamera.svg(
                                            width: 28,
                                            height: 28,
                                            colorFilter: ColorFilter.mode(
                                              StyleRepo.softWhite,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      tr(LocaleKeys.profile_add_photo),
                                      style: const TextStyle(color: StyleRepo.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        //  Full Name Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_full_name),
                          controller: controller.fullName,
                          validator: controller.validateFullName,
                          hintText: tr(LocaleKeys.profile_full_name_placeholder),
                          prefixIcon: Assets.icons.essentials.circleUser.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //  Last Name Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_last_name),
                          controller: controller.lastName,
                          validator: controller.validateLastName,
                          hintText: tr(LocaleKeys.profile_last_name_placeholder),
                          prefixIcon: Assets.icons.essentials.circleUser.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //  Email Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_email),
                          controller: controller.email,
                          validator: controller.validateEmail,
                          hintText: tr(LocaleKeys.profile_email_placeholder),
                          prefixIcon: Assets.icons.messages.openedMail.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        //  National Number Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_national_number),
                          controller: controller.nationalNumber,
                          validator: controller.validateNationalNumber,
                          hintText: tr(LocaleKeys.profile_national_number_placeholder),
                          prefixIcon: Assets.icons.document.shield.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        //  Gender Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_gender),
                          controller: controller.gender,
                          validator: controller.validateGender,
                          hintText: tr(LocaleKeys.profile_gender_placeholder),
                          prefixIcon: Assets.icons.essentials.gender.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.completeProfile,
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
}
