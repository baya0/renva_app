import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../gen/assets.gen.dart';
import 'form_controller.dart';

class JoinAsProviderFormPage extends StatelessWidget {
  const JoinAsProviderFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinAsProviderFormController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePictureSection(controller),
                      const SizedBox(height: 30),

                      // Name Field
                      _buildTextField(
                        context: context,
                        label: tr('profile.full_name'),
                        controller: controller.nameController,
                        validator: controller.validateName,
                        hintText: tr('profile.full_name_placeholder'),
                        prefixIcon: Assets.icons.essentials.circleUser,
                        onChanged: (value) => controller.clearError(),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                        context: context,
                        label: tr('profile.email'),
                        controller: controller.emailController,
                        validator: controller.validateEmail,
                        hintText: tr('profile.email_placeholder'),
                        prefixIcon: Assets.icons.messages.openedMail,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => controller.clearError(),
                      ),
                      const SizedBox(height: 20),

                      // Phone field
                      _buildPhoneField(context, controller),
                      const SizedBox(height: 20),

                      // Gender field
                      _buildGenderField(context, controller, theme),
                      const SizedBox(height: 30),

                      // Service Area
                      _buildServiceAreaSection(controller, theme),
                      const SizedBox(height: 30),

                      // Working Time
                      _buildWorkingTimeSection(controller, theme),
                      const SizedBox(height: 30),

                      // Description
                      _buildDescriptionField(context, controller),
                      const SizedBox(height: 30),

                      // Upload Photos
                      _buildUploadPhotosSection(controller, theme),
                      const SizedBox(height: 40),

                      // Join Button
                      _buildJoinButton(controller),
                      const SizedBox(height: 20),
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

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            child: Assets.icons.arrows.leftCircle.svg(width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          Text(
            tr('profile_menu.service_provider'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: StyleRepo.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(JoinAsProviderFormController controller) {
    return Center(
      child: Column(
        children: [
          Obx(() {
            final hasImage = controller.profileImagePath.value.isNotEmpty;
            return GestureDetector(
              onTap: controller.pickProfilePhoto,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
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
                                width: 100,
                                height: 100,
                              )
                              : Container(
                                color: StyleRepo.softGrey,
                                child: Assets.icons.essentials.circleUser.svg(
                                  width: 50,
                                  height: 50,
                                  color: StyleRepo.grey,
                                ),
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: StyleRepo.deepBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Assets.icons.essentials.photoCamera.svg(
                          width: 16,
                          height: 16,
                          color: StyleRepo.softWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            tr('profile.add_profile_photo'),
            style: const TextStyle(
              color: StyleRepo.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
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
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildPhoneField(BuildContext context, JoinAsProviderFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('profile.phone_number'),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        InternationalPhoneNumberInput(
          onInputChanged: controller.onPhoneChanged,
          validator: controller.validatePhone,
          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: const TextStyle(color: StyleRepo.black),
          initialValue: PhoneNumber(isoCode: 'SY'),
          textFieldController: controller.phoneController,
          formatInput: false,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          inputDecoration: InputDecoration(
            hintText: tr('profile.phone_placeholder'),
            hintStyle: const TextStyle(color: StyleRepo.grey, fontSize: 14),
            filled: true,
            fillColor: StyleRepo.softWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField(
    BuildContext context,
    JoinAsProviderFormController controller,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: controller.selectGender,
      child: _buildTextField(
        context: context,
        label: tr('profile.gender'),
        controller: controller.genderController,
        validator: controller.validateGender,
        hintText: tr('profile.gender_placeholder'),
        prefixIcon: Assets.icons.essentials.circleUser, // Using working icon instead
        readOnly: true,
        onTap: controller.selectGender,
      ),
    );
  }

  Widget _buildServiceAreaSection(JoinAsProviderFormController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Area',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final selectedArea = controller.serviceArea.value;
          return Column(
            children: [
              _buildRadioOption(
                title: 'I Provide A Service In A Specific Place',
                value: 'specific',
                groupValue: selectedArea,
                onChanged: controller.setServiceArea,
              ),
              const SizedBox(height: 8),
              _buildRadioOption(
                title: 'I Provide Services In All Regions',
                value: 'all_regions',
                groupValue: selectedArea,
                onChanged: controller.setServiceArea,
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
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
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
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: StyleRepo.softWhite,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: StyleRepo.black,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingTimeSection(JoinAsProviderFormController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working time',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
        ),
        const SizedBox(height: 12),
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
                      hintText: 'From',
                      enabled: !anyTime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      controller: controller.workingToController,
                      hintText: 'To',
                      enabled: !anyTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Any Time checkbox
              GestureDetector(
                onTap: controller.toggleAnyTime,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
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
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: StyleRepo.softWhite,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Any Time',
                        style: TextStyle(
                          color: StyleRepo.black,
                          fontSize: 14,
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
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: enabled ? StyleRepo.grey : StyleRepo.grey.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled ? StyleRepo.softWhite : StyleRepo.softGrey.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: StyleRepo.softGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: StyleRepo.softGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: StyleRepo.deepBlue, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: StyleRepo.softGrey.withValues(alpha: 0.5), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, JoinAsProviderFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.descriptionController,
          validator: controller.validateDescription,
          maxLines: 4,
          onChanged: (value) => controller.clearError(),
          decoration: InputDecoration(
            hintText: 'Add Description',
            hintStyle: const TextStyle(color: StyleRepo.grey, fontSize: 14),
            filled: true,
            fillColor: StyleRepo.softWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPhotosSection(JoinAsProviderFormController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photos',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.pickGalleryPhotos,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: StyleRepo.softGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StyleRepo.softGrey, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.essentials.photoCamera.svg(
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload Photo',
                  style: TextStyle(
                    color: StyleRepo.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final images = controller.galleryImages;
          if (images.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imagePath = images[index];
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
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
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
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

  Widget _buildJoinButton(JoinAsProviderFormController controller) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
          ),
          child:
              saving
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: StyleRepo.softWhite,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tr('buttons.saving'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StyleRepo.softWhite,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    tr('buttons.join'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: StyleRepo.softWhite,
                    ),
                  ),
        ),
      );
    });
  }
}
