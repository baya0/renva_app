import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/state_management/widgets/obs_widget.dart';
import '../../../core/style/repo.dart';
import '../../../core/style/style.dart';
import '../../../core/widgets/image.dart';
import '../../../gen/assets.gen.dart';
import '../models/user_model.dart';
import 'controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ObsVariableBuilder<User?>(
          obs: controller.currentUser,
          onRefresh: controller.refreshData,
          builder: (context, userData) {
            return _buildMainContent(context, controller, theme, userData);
          },
          loader: (context) => _buildLoadingState(theme),
          errorBuilder: (context, error) => _buildErrorState(controller, error, theme),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Assets.icons.arrows.leftCircle.svg(
                    width: 24,
                    height: 24,
                    color: StyleRepo.black,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tr(LocaleKeys.profile_edit_profile),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: StyleRepo.black,
                  ),
                ),
              ],
            ),
          ),

          // Loading content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.deepBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(LocaleKeys.common_loading),
                    style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(EditProfileController controller, String error, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Assets.icons.arrows.leftCircle.svg(
                    width: 24,
                    height: 24,
                    color: StyleRepo.black,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tr(LocaleKeys.profile_edit_profile),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: StyleRepo.black,
                  ),
                ),
              ],
            ),
          ),

          // Error content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
                    const SizedBox(height: 16),
                    Text(
                      tr(LocaleKeys.errors_failed_to_load_profile),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.refreshData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StyleRepo.deepBlue,
                        foregroundColor: StyleRepo.softWhite,
                      ),
                      child: Text(tr(LocaleKeys.common_retry)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    EditProfileController controller,
    ThemeData theme,
    User? userData,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: Stack(
        children: [
          _buildWatermarkBackground(),

          // Main content
          Column(
            children: [
              // Header
              _buildHeader(context, controller, theme),

              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        _buildProfilePhotoSection(controller, theme),

                        const SizedBox(height: 30),

                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_name),
                          controller: controller.nameController,
                          validator: controller.validateName,
                          hintText: tr(LocaleKeys.profile_full_name_placeholder),
                          prefixIcon: Assets.icons.essentials.circleUser.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_email),
                          controller: controller.emailController,
                          validator: controller.validateEmail,
                          hintText: tr(LocaleKeys.profile_email_placeholder),
                          prefixIcon: Assets.icons.messages.openedMail.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        // National ID Field
                        AppStyle.buildFormField(
                          context: context,
                          label: tr(LocaleKeys.profile_national_number),
                          controller: controller.nationalIDController,
                          validator: controller.validateNationalID,
                          hintText: tr(LocaleKeys.profile_national_number_placeholder),
                          prefixIcon: Assets.icons.document.shield.svg(
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        _buildGenderField(context, controller, theme),

                        const SizedBox(height: 40),

                        _buildSaveButton(controller, theme),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarkBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: -120,
              right: 0,
              child: Opacity(
                opacity: 0.02,
                child: Center(
                  child: Transform.rotate(
                    angle: 1.45,
                    child: Assets.images.logo.logo.svg(
                      width: 415,
                      height: 413,
                      color: StyleRepo.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 550,
              left: 27,
              right: 0,
              child: Opacity(
                opacity: 0.02,
                child: Center(
                  child: Transform.rotate(
                    angle: 1.45,
                    child: Assets.images.logo.logo.svg(
                      width: 415,
                      height: 413,
                      color: StyleRepo.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with back button
  Widget _buildHeader(BuildContext context, EditProfileController controller, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showUnsavedChangesDialog(context, controller),
            child: Assets.icons.arrows.leftCircle.svg(
              width: 24,
              height: 24,
              color: StyleRepo.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tr(LocaleKeys.profile_edit_profile),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: StyleRepo.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection(EditProfileController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr(LocaleKeys.profile_profile_picture),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: StyleRepo.black,
              ),
            ),
            // Remove button
            ObsVariableBuilder<String>(
              obs: controller.profileImagePath,
              builder: (context, imagePath) {
                if (imagePath.isNotEmpty || controller.hasCurrentProfileImage) {
                  return TextButton(
                    onPressed: controller.removeProfilePicture,
                    child: Text(
                      tr(LocaleKeys.dialogs_remove),
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        Center(
          child: GestureDetector(
            onTap: controller.pickProfilePhoto,
            child: Stack(
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StyleRepo.softGrey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildProfileImage(controller)),
                ),

                // Camera icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StyleRepo.deepBlue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Assets.icons.essentials.photoCamera.svg(
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Text(
            tr(LocaleKeys.profile_add_profile_photo),
            style: theme.textTheme.bodySmall?.copyWith(color: StyleRepo.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(EditProfileController controller) {
    return ObsVariableBuilder<String>(
      obs: controller.profileImagePath,
      builder: (context, imagePath) {
        // New image selected
        if (imagePath.isNotEmpty) {
          return Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: 105,
            height: 105,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
          );
        }

        return ObsVariableBuilder<String>(
          obs: controller.currentProfileImageUrl,
          builder: (context, imageUrl) {
            if (imageUrl.isNotEmpty) {
              return AppImage(
                path: imageUrl,
                type: ImageType.CachedNetwork,
                fit: BoxFit.cover,
                width: 105,
                height: 105,
                errorWidget: _buildDefaultAvatar(),
                loadingWidget: _buildLoadingAvatar(),
              );
            }

            return _buildDefaultAvatar();
          },
        );
      },
    );
  }

  Widget _buildGenderField(
    BuildContext context,
    EditProfileController controller,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: controller.selectGender,
      child: AbsorbPointer(
        // Prevents manual typing, only allows tap selection
        child: AppStyle.buildFormField(
          context: context,
          label: tr(LocaleKeys.profile_gender),
          controller: controller.genderController,
          validator: controller.validateGender,
          hintText: tr(LocaleKeys.profile_gender_placeholder),
          prefixIcon: Assets.icons.essentials.gender.svg(
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
          ),
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: StyleRepo.grey),
        ),
      ),
    );
  }

  Widget _buildSaveButton(EditProfileController controller, ThemeData theme) {
    return ObsVariableBuilder<bool>(
      obs: controller.isSaving,
      builder: (context, isSaving) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSaving ? null : controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaving ? StyleRepo.grey : StyleRepo.deepBlue,
              foregroundColor: StyleRepo.softWhite,
              disabledBackgroundColor: StyleRepo.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
            ),
            child:
                isSaving
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
                          tr(LocaleKeys.buttons_saving),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: StyleRepo.softWhite,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      tr(LocaleKeys.common_save),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: StyleRepo.softWhite,
                      ),
                    ),
          ),
        );
      },
    );
  }

  // Default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      width: 105,
      height: 105,
      color: StyleRepo.softGrey,
      child: Center(
        child: Assets.icons.essentials.circleUser.svg(
          width: 50,
          height: 50,
          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
        ),
      ),
    );
  }

  // Loading avatar
  Widget _buildLoadingAvatar() {
    return Container(
      width: 105,
      height: 105,
      color: StyleRepo.softGrey,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.deepBlue),
          strokeWidth: 2,
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context, EditProfileController controller) {
    if (controller.hasChanges) {
      Get.dialog(
        AlertDialog(
          title: Text(tr(LocaleKeys.dialogs_go_back_title)),
          content: Text(tr(LocaleKeys.dialogs_unsaved_changes)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen
              },
              child: Text(
                tr(LocaleKeys.dialogs_discard_changes),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
}
