import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';
import '../../../core/widgets/modern_toast.dart';

class CompleteInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final fullName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final nationalNumber = TextEditingController();
  final gender = TextEditingController();

  final profileImage = ''.obs;
  final idImage = ''.obs;
  final RxString errorMessage = ''.obs;

  AppBuilder get appBuilder => Get.find<AppBuilder>();

  @override
  void onClose() {
    fullName.dispose();
    lastName.dispose();
    email.dispose();
    nationalNumber.dispose();
    gender.dispose();
    super.onClose();
  }

  void completeProfile() async {
    if (!_validateForm()) {
      return;
    }

    errorMessage.value = '';

    try {
      // Check authentication token
      if (appBuilder.token == null || appBuilder.token!.isEmpty) {
        _showError(tr(LocaleKeys.errors_no_auth_token));
        return;
      }
      await _makeProfileCompletionAPI();
    } catch (e) {
      _showError(tr(LocaleKeys.errors_failed_complete_profile));
    }
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (profileImage.value.isEmpty) {
      _showError(tr(LocaleKeys.forms_profile_photo_required));
      return false;
    }
    if (idImage.value.isEmpty) {
      _showError(tr(LocaleKeys.forms_id_photo_required));
      return false;
    }

    return true;
  }

  Future<void> _makeProfileCompletionAPI() async {
    try {
      FormData formData = FormData.fromMap({
        'first_name': fullName.text.trim(),
        'last_name': lastName.text.trim(),
        'nationalID': nationalNumber.text.trim(),
        'email': email.text.trim(),
        'gender_id': _getGenderId(gender.text.trim()),
      });

      if (profileImage.value.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'profile_image',
            await MultipartFile.fromFile(profileImage.value, filename: 'profile_image.jpg'),
          ),
        );
      }

      if (idImage.value.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'id_image',
            await MultipartFile.fromFile(idImage.value, filename: 'id_image.jpg'),
          ),
        );
      }

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.updateProfile,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json'},
        ),
      );

      if (response.success) {
        await _handleSuccessfulCompletion(response);
      } else {
        _handleCompletionError(response);
      }
    } catch (e) {
      throw Exception('${tr(LocaleKeys.errors_api_call_failed)}: $e');
    }
  }

  String _getGenderId(String genderText) {
    final normalizedGender = genderText.toLowerCase().trim();

    if (normalizedGender == 'male' || normalizedGender == '1') {
      return '1';
    } else if (normalizedGender == 'female' || normalizedGender == '2') {
      return '2';
    }
    return '1';
  }

  // Handle successful completion using API response
  Future<void> _handleSuccessfulCompletion(ResponseModel response) async {
    try {
      final appBuilder = Get.find<AppBuilder>();

      // Check if API response contains updated user data
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response contains completion status
        if (responseData.containsKey('is_completed')) {
          // Update from API response
          appBuilder.updateFromAPIResponse(responseData);
        } else {
          // Fallback: manually set as completed
          appBuilder.setProfileCompleted(true);
          appBuilder.setVerified(true);
          appBuilder.setRole(Role.user);
        }
      } else {
        appBuilder.setProfileCompleted(true);
        appBuilder.setVerified(true);
        appBuilder.setRole(Role.user);
      }
      appBuilder.debugPrintState();

      PopUpToast.show(tr(LocaleKeys.success_profile_completed_welcome));

      // Navigate to home
      await Future.delayed(Duration(milliseconds: 1000));

      Get.offAllNamed(Pages.home.value);
    } catch (e) {
      _showError(tr(LocaleKeys.errors_processing_response_failed));
    }
  }

  // Handle profile completion error
  void _handleCompletionError(ResponseModel response) {
    String errorMsg = tr(LocaleKeys.errors_failed_complete_profile);

    try {
      if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['error'] != null) {
          errorMsg = errorData['error'].toString();
        } else if (errorData['errors'] != null) {
          // Handle validation errors
          if (errorData['errors'] is Map) {
            Map<String, dynamic> errors = errorData['errors'];
            List<String> errorMessages = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });
            errorMsg = errorMessages.join('\n');
          }
        }
      } else if (response.message.isNotEmpty) {
        errorMsg = response.message;
      }
    } catch (e) {
      print(' Error parsing error response: $e');
    }

    _showError(errorMsg);
  }

  Future<void> pickProfilePhoto() async {
    await _pickImage(isProfilePhoto: true);
  }

  Future<void> pickIdPhoto() async {
    await _pickImage(isProfilePhoto: false);
  }

  Future<void> _pickImage({required bool isProfilePhoto}) async {
    try {
      // Show source selection dialog
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(
            isProfilePhoto
                ? tr(LocaleKeys.profile_select_profile_photo)
                : tr(LocaleKeys.profile_select_id_photo),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                subtitle: Text(tr(LocaleKeys.profile_take_new_photo)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green, size: 28),
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
          preferredCameraDevice: CameraDevice.front,
        );

        if (pickedImage != null) {
          if (isProfilePhoto) {
            profileImage.value = pickedImage.path;
          } else {
            idImage.value = pickedImage.path;
          }

          // Clear any previous error messages
          if (errorMessage.value.isNotEmpty) {
            errorMessage.value = '';
          }
          PopUpToast.show(tr(LocaleKeys.success_image_selected));
        }
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_failed_to_select_image));
    }
  }

  String? validateFullName(String? value) {
    return Validators.validateName(value, minLength: 2, maxLength: 50);
  }

  String? validateLastName(String? value) {
    return Validators.validateName(value, minLength: 2, maxLength: 50);
  }

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validateNationalNumber(String? value) {
    return Validators.validateRequired(value, tr(LocaleKeys.profile_national_number));
  }

  String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_gender_required);
    }

    final normalizedValue = value.trim().toLowerCase();

    // Accept: male, female, 1, 2, Male, Female
    if (['male', 'female', '1', '2'].contains(normalizedValue)) {
      return null;
    }

    return tr(LocaleKeys.forms_valid_gender);
  }

  // Helper methods - Localized
  void _showError(String message) {
    errorMessage.value = message;
    PopUpToast.show('${tr(LocaleKeys.common_error)}: $message');
  }

  void clearError() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  // Utility getters
  bool get hasProfileImage => profileImage.value.isNotEmpty;
  bool get hasIdImage => idImage.value.isNotEmpty;
  bool get isFormComplete => hasProfileImage && hasIdImage && _areFieldsFilled();

  bool _areFieldsFilled() {
    return fullName.text.trim().isNotEmpty &&
        lastName.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        nationalNumber.text.trim().isNotEmpty &&
        gender.text.trim().isNotEmpty;
  }

  // Form field change handlers to clear errors
  void onFullNameChanged(String value) => clearError();
  void onLastNameChanged(String value) => clearError();
  void onEmailChanged(String value) => clearError();
  void onNationalNumberChanged(String value) => clearError();
  void onGenderChanged(String value) => clearError();
}
