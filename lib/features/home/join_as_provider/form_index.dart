import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../core/localization/strings.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../core/utils/responsive.dart';
import '../../../gen/assets.gen.dart';
import 'form_controller.dart';

class JoinAsProviderFormPage extends StatelessWidget {
  const JoinAsProviderFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinAsProviderFormController());
    final theme = Theme.of(context);
    final r = context.responsive;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, r),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(r.space24, r.space20, r.space24, r.space24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePictureSection(controller, r),
                      SizedBox(height: r.space32),

                      // Name Field
                      _buildTextField(
                        context: context,
                        r: r,
                        label: tr(LocaleKeys.profile_full_name),
                        controller: controller.nameController,
                        validator: controller.validateName,
                        hintText: tr(LocaleKeys.profile_full_name_placeholder),
                        prefixIcon: Assets.icons.essentials.circleUser,
                        onChanged: (value) => controller.clearError(),
                      ),
                      SizedBox(height: r.space20),

                      // Email Field
                      _buildTextField(
                        context: context,
                        r: r,
                        label: tr(LocaleKeys.profile_email),
                        controller: controller.emailController,
                        validator: controller.validateEmail,
                        hintText: tr(LocaleKeys.profile_email_placeholder),
                        prefixIcon: Assets.icons.messages.openedMail,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => controller.clearError(),
                      ),
                      SizedBox(height: r.space20),

                      // Phone field
                      _buildPhoneField(context, controller, r),
                      SizedBox(height: r.space20),

                      // Gender field
                      _buildGenderField(context, controller, theme, r),
                      SizedBox(height: r.space32),

                      // Service Area
                      _buildServiceAreaSection(controller, theme, r),
                      SizedBox(height: r.space32),

                      // Working Time
                      _buildWorkingTimeSection(controller, theme, r),
                      SizedBox(height: r.space32),

                      // Description
                      _buildDescriptionField(context, controller, r),
                      SizedBox(height: r.space32),

                      // Upload Photos
                      _buildUploadPhotosSection(controller, theme, r),
                      SizedBox(height: r.space48),

                      // Join Button
                      _buildJoinButton(controller, r),
                      SizedBox(height: r.space20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, Responsive r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space20, vertical: r.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Assets.icons.arrows.leftCircle.svg(width: r.iconSize24, height: r.iconSize24),
          ),
          SizedBox(width: r.space12),
          Text(
            tr(LocaleKeys.profile_menu_service_provider),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: r.fontSize18,
              color: StyleRepo.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(JoinAsProviderFormController controller, Responsive r) {
    return Center(
      child: Column(
        children: [
          Obx(() {
            final hasImage = controller.profileImagePath.value.isNotEmpty;
            final imageSize = r.value(mobile: 100.0, tablet: 110.0, desktop: 120.0);
            return GestureDetector(
              onTap: controller.pickProfilePhoto,
              child: Stack(
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: StyleRepo.softGrey,
                    ),
                    child: ClipOval(
                      child:
                          hasImage
                              ? Image.file(
                                File(controller.profileImagePath.value),
                                fit: BoxFit.cover,
                                width: imageSize,
                                height: imageSize,
                              )
                              : Container(
                                color: StyleRepo.softGrey,
                                child: Assets.icons.essentials.circleUser.svg(
                                  width: imageSize * 0.5,
                                  height: imageSize * 0.5,
                                  colorFilter: const ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                                ),
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: r.iconSize32,
                      height: r.iconSize32,
                      decoration: const BoxDecoration(
                        color: StyleRepo.deepBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Assets.icons.essentials.photoCamera.svg(
                          width: r.iconSize16,
                          height: r.iconSize16,
                          colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: r.space12),
          Text(
            tr(LocaleKeys.profile_add_profile_photo),
            style: TextStyle(
              color: StyleRepo.grey,
              fontSize: r.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required Responsive r,
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required String hintText,
    required SvgGenImage prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return AppStyle.buildFormField(
      context: context,
      label: label,
      controller: controller,
      validator: validator,
      hintText: hintText,
      prefixIcon: prefixIcon.svg(
        width: r.iconSize20,
        height: r.iconSize20,
        colorFilter: const ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildPhoneField(BuildContext context, JoinAsProviderFormController controller, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.profile_phone_number),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: r.fontSize14, color: StyleRepo.black),
        ),
        SizedBox(height: r.space8),
        InternationalPhoneNumberInput(
          onInputChanged: controller.onPhoneChanged,
          validator: controller.validatePhone,
          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: TextStyle(color: StyleRepo.black, fontSize: r.fontSize14),
          initialValue: PhoneNumber(isoCode: 'SY'),
          textFieldController: controller.phoneController,
          formatInput: false,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          inputDecoration: InputDecoration(
            hintText: tr(LocaleKeys.profile_phone_placeholder),
            hintStyle: TextStyle(color: StyleRepo.grey, fontSize: r.fontSize14),
            filled: true,
            fillColor: StyleRepo.softWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: r.space16, vertical: r.space12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField(
    BuildContext context,
    JoinAsProviderFormController controller,
    ThemeData theme,
    Responsive r,
  ) {
    return GestureDetector(
      onTap: controller.selectGender,
      child: _buildTextField(
        context: context,
        r: r,
        label: tr(LocaleKeys.profile_gender),
        controller: controller.genderController,
        validator: controller.validateGender,
        hintText: tr(LocaleKeys.profile_gender_placeholder),
        prefixIcon: Assets.icons.essentials.circleUser,
        readOnly: true,
        onTap: controller.selectGender,
      ),
    );
  }

  Widget _buildServiceAreaSection(JoinAsProviderFormController controller, ThemeData theme, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.join_provider_service_area),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: r.fontSize16,
            color: StyleRepo.black,
          ),
        ),
        SizedBox(height: r.space12),
        Obx(() {
          final selectedArea = controller.serviceArea.value;
          return Column(
            children: [
              _buildRadioOption(
                title: tr(LocaleKeys.join_provider_service_area_specific),
                value: 'specific',
                groupValue: selectedArea,
                onChanged: controller.setServiceArea,
                r: r,
              ),
              SizedBox(height: r.space8),
              _buildRadioOption(
                title: tr(LocaleKeys.join_provider_service_area_all_regions),
                value: 'all_regions',
                groupValue: selectedArea,
                onChanged: controller.setServiceArea,
                r: r,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
    required Responsive r,
  }) {
    final isSelected = value == groupValue;
    final radioSize = r.value(mobile: 20.0, tablet: 22.0, desktop: 24.0);

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: r.space8, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: radioSize,
              height: radioSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey,
                  width: 2,
                ),
                color: isSelected ? StyleRepo.deepBlue : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: radioSize * 0.3,
                          height: radioSize * 0.3,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: StyleRepo.softWhite,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: r.space12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: StyleRepo.black,
                  fontSize: r.fontSize14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingTimeSection(JoinAsProviderFormController controller, ThemeData theme, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.join_provider_working_time),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: r.fontSize16,
            color: StyleRepo.black,
          ),
        ),
        SizedBox(height: r.space12),
        Obx(() {
          final anyTime = controller.isAnyTime.value;
          return Column(
            children: [
              // Time input fields
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      controller: controller.workingFromController,
                      hintText: tr(LocaleKeys.join_provider_working_time_from),
                      enabled: !anyTime,
                      r: r,
                    ),
                  ),
                  SizedBox(width: r.space16),
                  Expanded(
                    child: _buildTimeField(
                      controller: controller.workingToController,
                      hintText: tr(LocaleKeys.join_provider_working_time_to),
                      enabled: !anyTime,
                      r: r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.space12),
              // Any Time checkbox
              GestureDetector(
                onTap: controller.toggleAnyTime,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: r.space8, horizontal: 4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: r.value(mobile: 20.0, tablet: 22.0, desktop: 24.0),
                        height: r.value(mobile: 20.0, tablet: 22.0, desktop: 24.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: anyTime ? StyleRepo.deepBlue : StyleRepo.grey,
                            width: 2,
                          ),
                          color: anyTime ? StyleRepo.deepBlue : Colors.transparent,
                        ),
                        child:
                            anyTime
                                ? Center(
                                  child: Container(
                                    width: r.value(mobile: 6.0, tablet: 7.0, desktop: 8.0),
                                    height: r.value(mobile: 6.0, tablet: 7.0, desktop: 8.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: StyleRepo.softWhite,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      SizedBox(width: r.space12),
                      Text(
                        tr(LocaleKeys.join_provider_working_time_any_time),
                        style: TextStyle(
                          color: StyleRepo.black,
                          fontSize: r.fontSize14,
                          fontWeight: anyTime ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String hintText,
    required Responsive r,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: enabled ? StyleRepo.grey : StyleRepo.grey.withValues(alpha: 0.5),
          fontSize: r.fontSize14,
        ),
        filled: true,
        fillColor: enabled ? StyleRepo.softWhite : StyleRepo.softGrey.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius12),
          borderSide: BorderSide(color: StyleRepo.softGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius12),
          borderSide: BorderSide(color: StyleRepo.softGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius12),
          borderSide: BorderSide(color: StyleRepo.deepBlue, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius12),
          borderSide: BorderSide(color: StyleRepo.softGrey.withValues(alpha: 0.5), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: r.space16, vertical: r.space12),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, JoinAsProviderFormController controller, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.join_provider_description),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: r.fontSize16, color: StyleRepo.black),
        ),
        SizedBox(height: r.space8),
        TextFormField(
          controller: controller.descriptionController,
          validator: controller.validateDescription,
          maxLines: 4,
          onChanged: (value) => controller.clearError(),
          decoration: InputDecoration(
            hintText: tr(LocaleKeys.join_provider_description_placeholder),
            hintStyle: TextStyle(color: StyleRepo.grey, fontSize: r.fontSize14),
            filled: true,
            fillColor: StyleRepo.softWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.radius12),
              borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
            ),
            contentPadding: EdgeInsets.all(r.space16),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPhotosSection(JoinAsProviderFormController controller, ThemeData theme, Responsive r) {
    final uploadContainerHeight = r.value(mobile: 120.0, tablet: 130.0, desktop: 140.0);
    final thumbnailSize = r.value(mobile: 80.0, tablet: 90.0, desktop: 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.join_provider_upload_photos),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: r.fontSize16,
            color: StyleRepo.black,
          ),
        ),
        SizedBox(height: r.space12),
        GestureDetector(
          onTap: controller.pickGalleryPhotos,
          child: Container(
            width: double.infinity,
            height: uploadContainerHeight,
            decoration: BoxDecoration(
              color: StyleRepo.softGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(r.radius12),
              border: Border.all(color: StyleRepo.softGrey, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.essentials.photoCamera.svg(
                  width: r.iconSize24,
                  height: r.iconSize24,
                  colorFilter: const ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                ),
                SizedBox(height: r.space8),
                Text(
                  tr(LocaleKeys.join_provider_upload_photo),
                  style: TextStyle(
                    color: StyleRepo.grey,
                    fontSize: r.fontSize14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: r.space12),
        Obx(() {
          final images = controller.galleryImages;
          if (images.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: thumbnailSize,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imagePath = images[index];
                return Container(
                  width: thumbnailSize,
                  height: thumbnailSize,
                  margin: EdgeInsets.only(right: r.space8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r.radius8),
                    image: DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeGalleryImage(index),
                          child: Container(
                            width: r.iconSize20,
                            height: r.iconSize20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: r.fontSize12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildJoinButton(JoinAsProviderFormController controller, Responsive r) {
    final buttonHeight = r.buttonHeightMedium;

    return Obx(() {
      final saving = controller.isSaving.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: saving ? null : controller.submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleRepo.deepBlue,
            foregroundColor: StyleRepo.softWhite,
            disabledBackgroundColor: StyleRepo.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius24)),
            padding: EdgeInsets.symmetric(vertical: r.space16),
            elevation: 0,
            minimumSize: Size(double.infinity, buttonHeight),
          ),
          child:
              saving
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: r.iconSize20,
                        height: r.iconSize20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: r.space12),
                      Text(
                        tr(LocaleKeys.buttons_saving),
                        style: TextStyle(
                          fontSize: r.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: StyleRepo.softWhite,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    tr(LocaleKeys.buttons_join),
                    style: TextStyle(
                      fontSize: r.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: StyleRepo.softWhite,
                    ),
                  ),
        ),
      );
    });
  }
}
