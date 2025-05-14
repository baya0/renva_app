// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/routes/routes.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class CompleteInfoPage extends StatelessWidget {
  const CompleteInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once using tag to prevent multiple instances
    final controller = Get.put(
      CompleteInfoController(),
      tag: 'complete_info_controller',
      permanent: true,
    );

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: AppStyle.roundedTopContainer,
                  child: SingleChildScrollView(
                    padding: AppStyle.contentPadding,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('customer.complete_info.title'),
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            tr('customer.complete_info.subtitle'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 25),

                          Center(
                            //second
                            child: Column(
                              children: [
                                Obx(
                                  () => Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: StyleRepo.softGrey,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: StyleRepo.softGrey,
                                            width: 1,
                                          ),
                                          image:
                                              controller
                                                      .profileImage
                                                      .value
                                                      .isNotEmpty
                                                  ? DecorationImage(
                                                    image: FileImage(
                                                      File(
                                                        controller
                                                            .profileImage
                                                            .value,
                                                      ),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null,
                                        ),
                                        child:
                                            controller
                                                    .profileImage
                                                    .value
                                                    .isEmpty
                                                ? Assets
                                                    .icons
                                                    .essentials
                                                    .circleUser
                                                    .svg(
                                                      width: 36,
                                                      height: 36,
                                                      color: StyleRepo.grey,
                                                    )
                                                : null,
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: controller.pickProfilePhoto,
                                        child: Text(
                                          tr('customer.complete_info.add_pic'),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ID photo',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: controller.pickProfilePhoto,

                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: StyleRepo.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Assets
                                                  .icons
                                                  .essentials
                                                  .photoCamera
                                                  .svg(
                                                    width: 28,
                                                    height: 28,
                                                    color: StyleRepo.softWhite,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Add Photo',
                                          style: TextStyle(
                                            color: StyleRepo.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Full Name
                          Text(
                            tr('common.full_name'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: AppStyle.smallSpacing),
                          TextFormField(
                            controller: controller.fullName,
                            validator: controller.validateFullName,
                            decoration: InputDecoration(
                              hintText: tr(
                                'enter_full_name',
                              ), // Add this key to your translation files
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Assets.icons.essentials.circleUser.svg(
                                  width: 20,
                                  height: 20,
                                  color: StyleRepo.grey,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppStyle.smallSpacing + 8),

                          // Email
                          Text(
                            tr('common.email'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: AppStyle.smallSpacing),
                          TextFormField(
                            controller: controller.email,
                            validator: controller.validateEmail,
                            decoration: InputDecoration(
                              hintText: 'user.name@gmail.com',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Assets.icons.messages.openedMail.svg(
                                  width: 20,
                                  height: 20,
                                  color: StyleRepo.grey,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppStyle.smallSpacing + 8),

                          // National Number
                          Text(
                            tr('common.national_number'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: AppStyle.smallSpacing),
                          TextFormField(
                            controller: controller.nationalNumber,
                            validator: controller.validateNationalNumber,
                            decoration: InputDecoration(
                              hintText: tr(
                                'add_national_number',
                              ), // Add this key to your translation files
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Assets.icons.document.check.svg(
                                  width: 20,
                                  height: 20,
                                  color: StyleRepo.grey,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppStyle.smallSpacing + 8),

                          Text(
                            tr('common.gender'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: AppStyle.smallSpacing),
                          TextFormField(
                            controller: controller.gender,
                            validator: controller.validateGender,
                            decoration: InputDecoration(
                              hintText: tr(
                                'female',
                              ), // Add this key to your translation files
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Assets.icons.essentials.gender.svg(
                                  width: 20,
                                  height: 20,
                                  color: StyleRepo.grey,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),
                          //confirm button
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    controller.isLoading.value
                                        ? null
                                        : controller.completeProfile,
                                child: Text(
                                  tr('common.confirm'),
                                  style: theme.textTheme.labelLarge,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
