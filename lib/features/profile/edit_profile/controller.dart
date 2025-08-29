import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:renva0/core/style/repo.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';
import '../../../core/services/state_management/obs.dart';
import '../../../core/widgets/modern_toast.dart';
import '../models/user_model.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nationalIDController = TextEditingController();
  final genderController = TextEditingController();

  final ObsVar<String> profileImagePath = ObsVar<String>('');
  final ObsVar<String> currentProfileImageUrl = ObsVar<String>('');
  final ObsVar<int> selectedGenderId = ObsVar<int>(1); // 1 = Male, 2 = Female
  final ObsVar<bool> isSaving = ObsVar<bool>(false);
  final ObsVar<User?> currentUser = ObsVar<User?>(null);

  // Get services
  AppBuilder get appBuilder => Get.find<AppBuilder>();

  // Check if we should show provider fields
  bool get isProviderModeActive => appBuilder.isProvider.value && appBuilder.isProviderMode.value;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    nationalIDController.dispose();
    genderController.dispose();
    super.onClose();
  }

  void _populateProviderFields(Map<String, dynamic> userData) {
    try {
      final providerData = userData['provider'] as Map<String, dynamic>;

      String providerName = providerData['name'] ?? '';
      nameController.text = providerName;

      emailController.text = providerData['email'] ?? userData['email'] ?? '';

      nationalIDController.text = userData['nationalID'] ?? '';

      if (providerData['gender'] != null) {
        if (providerData['gender'] is Map) {
          final genderData = providerData['gender'] as Map<String, dynamic>;
          String genderName = genderData['name'] ?? '';
          int genderId = genderData['id'] ?? 1;

          selectedGenderId.value = genderId;
          genderController.text =
              genderName.isNotEmpty
                  ? genderName[0].toUpperCase() + genderName.substring(1).toLowerCase()
                  : (genderId == 1 ? 'Male' : 'Female');
        }
      } else if (userData['gender'] != null) {
        // Fallback to user gender
        if (userData['gender'] is Map) {
          final genderData = userData['gender'] as Map<String, dynamic>;
          String genderName = genderData['name'] ?? '';
          int genderId = genderData['id'] ?? 1;

          selectedGenderId.value = genderId;
          genderController.text =
              genderName.isNotEmpty
                  ? genderName[0].toUpperCase() + genderName.substring(1).toLowerCase()
                  : (genderId == 1 ? 'Male' : 'Female');
        }
      }

      // Use provider avatar if available, fallback to user avatar
      if (providerData['avatar'] != null && providerData['avatar']['original_url'] != null) {
        currentProfileImageUrl.value = providerData['avatar']['original_url'];
      } else if (userData['avatar'] != null && userData['avatar']['original_url'] != null) {
        currentProfileImageUrl.value = userData['avatar']['original_url'];
      }
    } catch (e) {
      print(' Error populating provider fields: $e');
      // Fallback to user data if provider data fails
      _populateFields(userData);
    }
  }

  Future<void> loadCurrentUserData() async {
    try {
      currentUser.reset(); // Sets loading state

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.getProfile,
          method: RequestMethod.Get,
          fromJson: (json) => json,
        ),
      );

      if (response.success && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        final user = User.fromJson(userData);

        currentUser.value = user;

        // Populate fields based on current mode
        if (isProviderModeActive && userData['provider'] != null) {
          _populateProviderFields(userData);
        } else {
          _populateFields(userData);
        }
      } else {
        throw Exception('API returned error: ${response.message}');
      }
    } catch (e) {
      currentUser.error = e.toString();
    }
  }

  void _populateFields(Map<String, dynamic> userData) {
    try {
      String firstName = userData['first_name'] ?? '';
      String lastName = userData['last_name'] ?? '';
      nameController.text = '$firstName $lastName'.trim();

      // Email
      emailController.text = userData['email'] ?? '';

      // National ID
      nationalIDController.text = userData['nationalID'] ?? '';

      // Gender - handle API format: {"id": 1, "name": "male"}
      if (userData['gender'] != null) {
        if (userData['gender'] is Map) {
          final genderData = userData['gender'] as Map<String, dynamic>;
          String genderName = genderData['name'] ?? '';
          int genderId = genderData['id'] ?? 1;

          selectedGenderId.value = genderId;
          // Capitalize first letter for display: "male" -> "Male"
          genderController.text =
              genderName.isNotEmpty
                  ? genderName[0].toUpperCase() + genderName.substring(1).toLowerCase()
                  : (genderId == 1 ? 'Male' : 'Female');
        } else if (userData['gender_id'] != null) {
          selectedGenderId.value = userData['gender_id'];
          genderController.text = selectedGenderId.value == 1 ? 'Male' : 'Female';
        }
      }

      if (userData['avatar'] != null && userData['avatar']['original_url'] != null) {
        currentProfileImageUrl.value = userData['avatar']['original_url'];
      }
    } catch (e) {
      print(' Error populating fields: $e');
    }
  }

  Future<void> refreshData() async {
    await loadCurrentUserData();
  }

  Future<void> pickProfilePhoto() async {
    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(tr(LocaleKeys.dialogs_select_image_source)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                subtitle: Text(tr(LocaleKeys.profile_take_new_photo)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(tr(LocaleKeys.dialogs_gallery)),
                subtitle: Text(tr(LocaleKeys.profile_choose_from_gallery)),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          ],
        ),
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedImage != null) {
          // Verify file exists and has content
          final file = File(pickedImage.path);
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;

          if (exists && size > 0) {
            profileImagePath.value = pickedImage.path;
            PopUpToast.show(tr(LocaleKeys.success_profile_photo_selected));
          } else {
            PopUpToast.show(tr(LocaleKeys.errors_invalid_image_file));
          }
        }
      }
    } catch (e) {
      print(' Error picking profile photo: $e');
      PopUpToast.show(tr(LocaleKeys.errors_failed_to_select_image));
    }
  }

  void removeProfilePicture() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.dialogs_remove_profile_picture)),
        content: Text(tr(LocaleKeys.dialogs_remove_confirmation)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          TextButton(
            onPressed: () {
              profileImagePath.value = '';
              currentProfileImageUrl.value = '';
              Get.back();
              PopUpToast.show(tr(LocaleKeys.success_profile_picture_updated));
            },
            child: Text(tr(LocaleKeys.dialogs_remove), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void selectGender() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_gender)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.male, color: StyleRepo.grey, size: 28),
              title: Text(tr(LocaleKeys.profile_male)),
              onTap: () {
                selectedGenderId.value = 1;
                genderController.text = tr(LocaleKeys.profile_male);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: StyleRepo.grey, size: 28),
              title: Text(tr(LocaleKeys.profile_female)),
              onTap: () {
                selectedGenderId.value = 2;
                genderController.text = tr(LocaleKeys.profile_female);
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
        ],
      ),
    );
  }

  String? validateName(String? value) {
    return Validators.validateName(value, minLength: 2, maxLength: 100);
  }

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validateNationalID(String? value) {
    return Validators.validateRequired(value, tr(LocaleKeys.profile_national_number));
  }

  String? validateGender(String? value) {
    return Validators.validateRequired(value, tr(LocaleKeys.profile_gender));
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (isSaving.value == true) return; // Prevent double submission

    isSaving.value = true;

    try {
      await _handleApiSave();
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_profile_update_failed));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _handleApiSave() async {
    try {
      List<String> nameParts = nameController.text.trim().split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Always try user profile update first for provider approval issues
      if (isProviderModeActive) {
        // Try provider update first, but have fallback ready
        bool providerUpdateSuccess = await _attemptProviderUpdate(firstName, lastName);

        if (!providerUpdateSuccess) {
          // Fall back to user profile update
          await _attemptUserUpdate(firstName, lastName, true);
        }
      } else {
        // Regular user update
        await _attemptUserUpdate(firstName, lastName, false);
      }
    } catch (e) {
      print(' API Error: $e');
      rethrow;
    }
  }

  Future<bool> _attemptProviderUpdate(String firstName, String lastName) async {
    try {
      FormData formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'nationalID': nationalIDController.text.trim(),
        'email': emailController.text.trim(),
        'gender_id': selectedGenderId.value.toString(),
      });

      // Add profile image if selected
      if (profileImagePath.value?.isNotEmpty == true) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(profileImagePath.value!, filename: 'avatar.jpg'),
          ),
        );
      }

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.updateProvider,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json', 'Locale': Get.context!.locale.languageCode},
        ),
      );

      if (response.success) {
        PopUpToast.show('Provider profile updated successfully!');
        await refreshData();
        Get.back(result: true);
        return true;
      } else {
        // Check for specific provider approval errors
        String errorMessage = response.message.toLowerCase();
        bool isApprovalError =
            errorMessage.contains('admin') ||
            errorMessage.contains('approved') ||
            errorMessage.contains('accepted') ||
            response.statusCode == 410;

        if (isApprovalError) {
          print(' Provider not approved by admin, falling back to user update');
          PopUpToast.show('Provider profile locked. Updating basic profile only...');
          return false; // Will trigger fallback
        } else {
          PopUpToast.show(
            response.message.isNotEmpty ? response.message : 'Provider update failed',
          );
          return false;
        }
      }
    } catch (e) {
      print(' Provider update error: $e');
      return false;
    }
  }

  Future<void> _attemptUserUpdate(String firstName, String lastName, bool isFallback) async {
    try {
      FormData formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'nationalID': nationalIDController.text.trim(),
        'email': emailController.text.trim(),
        'gender_id': selectedGenderId.value.toString(),
      });

      // Add profile image if selected
      if (profileImagePath.value?.isNotEmpty == true) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(profileImagePath.value!, filename: 'avatar.jpg'),
          ),
        );
      }

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.updateProfile,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json', 'Locale': Get.context!.locale.languageCode},
        ),
      );

      if (response.success) {
        if (isFallback) {
          PopUpToast.show('Profile updated! (Categories not saved - provider pending approval)');
        } else {
          PopUpToast.show(tr(LocaleKeys.success_profile_updated));
        }

        await refreshData();
        Get.back(result: true);
      } else {
        String errorMessage =
            response.message.isNotEmpty
                ? response.message
                : tr(LocaleKeys.errors_profile_update_failed);
        PopUpToast.show(errorMessage);
      }
    } catch (e) {
      if (isFallback) {
        PopUpToast.show('All profile updates failed. Please contact support.');
      } else {
        rethrow;
      }
    }
  }

  bool get hasProfileImage => profileImagePath.value?.isNotEmpty == true;
  bool get hasCurrentProfileImage => currentProfileImageUrl.value?.isNotEmpty == true;

  String get displayProfileImage {
    if (hasProfileImage) {
      return profileImagePath.value!;
    }
    return currentProfileImageUrl.value ?? '';
  }

  bool get hasChanges {
    return nameController.text.isNotEmpty ||
        emailController.text.isNotEmpty ||
        nationalIDController.text.isNotEmpty ||
        hasProfileImage;
  }

  // Check if form is valid and ready to save
  bool get canSave {
    return hasChanges &&
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        genderController.text.trim().isNotEmpty &&
        isSaving.value == false;
  }
}
