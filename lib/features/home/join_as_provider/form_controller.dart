import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:renva0/core/style/repo.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/rest_api/utilitis/validator.dart';
import '../../../core/widgets/modern_toast.dart';

class JoinAsProviderFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final workingFromController = TextEditingController();
  final workingToController = TextEditingController();
  final descriptionController = TextEditingController();

  final profileImagePath = ''.obs;
  final galleryImages = <String>[].obs;
  final serviceArea = ''.obs;
  final isAnyTime = false.obs;
  final isSaving = false.obs;
  final selectedGenderId = 1.obs; // 1 = Male, 2 = Female

  // Phone number handling
  PhoneNumber? selectedPhoneNumber;
  String? cleanPhone;
  String? dialCode;

  // Selected services from previous page
  List<Map<String, String>> selectedServices = [];

  AppBuilder get appBuilder => Get.find<AppBuilder>();

  @override
  void onInit() {
    super.onInit();
    _loadSelectedServices();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    workingFromController.dispose();
    workingToController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load selected services from arguments
  void _loadSelectedServices() {
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map;
        selectedServices = List<Map<String, String>>.from(args['selectedServices'] ?? []);
      }
    } catch (e) {
      selectedServices = [];
    }
  }

  void onPhoneChanged(PhoneNumber number) {
    selectedPhoneNumber = number;

    String fullNumber = number.phoneNumber!; // "+966444888999"
    String dialCodeWithPlus = number.dialCode!; // "+966"

    // Clean dial code (remove +)
    dialCode = dialCodeWithPlus.replaceFirst('+', ''); // "966"

    // Extract clean phone (remove dial code part)
    cleanPhone = fullNumber.replaceFirst(dialCodeWithPlus, ''); // "444888999"
  }

  Future<void> pickProfilePhoto() async {
    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(tr(LocaleKeys.profile_select_profile_photo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text(tr(LocaleKeys.dialogs_gallery)),
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
          profileImagePath.value = pickedImage.path;
          PopUpToast.show(tr(LocaleKeys.success_image_selected));
        }
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_failed_to_select_image));
    }
  }

  Future<void> pickGalleryPhotos() async {
    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text('Select Gallery Photos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: StyleRepo.deepBlue),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: StyleRepo.forestGreen),
                title: Text(tr(LocaleKeys.dialogs_gallery)),
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
          galleryImages.add(pickedImage.path);
          PopUpToast.show('Gallery photo added');
        }
      }
    } catch (e) {
      PopUpToast.show('Failed to select gallery photo');
    }
  }

  void removeGalleryImage(int index) {
    try {
      if (index < galleryImages.length) {
        galleryImages.removeAt(index);
      }
    } catch (e) {
      PopUpToast.show('Failed to remove image');
    }
  }

  void selectGender() {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.profile_gender)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.male, color: Colors.blue),
              title: Text('Male'),
              onTap: () {
                selectedGenderId.value = 1;
                genderController.text = 'Male';
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.female, color: Colors.pink),
              title: Text('Female'),
              onTap: () {
                selectedGenderId.value = 2;
                genderController.text = 'Female';
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

  void setServiceArea(String area) {
    serviceArea.value = area;
  }

  void toggleAnyTime() {
    isAnyTime.value = !isAnyTime.value;
    if (isAnyTime.value) {
      workingFromController.clear();
      workingToController.clear();
    }
  }

  String? validateName(String? value) {
    return Validators.validateName(value, minLength: 2, maxLength: 50);
  }

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validatePhone(String? value) {
    if (selectedPhoneNumber == null || cleanPhone == null || dialCode == null) {
      return tr(LocaleKeys.forms_phone_required);
    }
    if (cleanPhone!.length < 7) {
      return tr(LocaleKeys.forms_phone_invalid);
    }
    return null;
  }

  String? validateGender(String? value) {
    return Validators.validateRequired(value, tr(LocaleKeys.profile_gender));
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? validateWorkingTime() {
    if (isAnyTime.value == true) return null;

    if (workingFromController.text.isEmpty || workingToController.text.isEmpty) {
      return 'Please set working hours or select "Any Time"';
    }
    return null;
  }

  Future<void> submitForm() async {
    if (!_validateForm()) {
      return;
    }

    if (isSaving.value == true) return; // Prevent double submission

    isSaving.value = true;

    try {
      // Check authentication token
      if (appBuilder.token == null || appBuilder.token!.isEmpty) {
        PopUpToast.show(tr(LocaleKeys.errors_no_auth_token));
        return;
      }

      await _makeProviderRegistrationAPI();
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_failed_complete_profile));
      print(' Provider registration error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!hasProfileImage) {
      PopUpToast.show(tr(LocaleKeys.forms_profile_photo_required));
      return false;
    }

    if (galleryImages.isEmpty) {
      PopUpToast.show('At least one gallery photo is required');
      return false;
    }

    if (serviceArea.value.isEmpty) {
      PopUpToast.show('Please select a service area');
      return false;
    }

    if (selectedServices.isEmpty) {
      PopUpToast.show('Please select at least one service category');
      return false;
    }

    final timeValidation = validateWorkingTime();
    if (timeValidation != null) {
      PopUpToast.show(timeValidation);
      return false;
    }

    final phoneValidation = validatePhone(phoneController.text);
    if (phoneValidation != null) {
      PopUpToast.show(phoneValidation);
      return false;
    }

    return true;
  }

  Future<void> _makeProviderRegistrationAPI() async {
    try {
      FormData formData = FormData.fromMap({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': cleanPhone!,
        'dial_country_code': dialCode!,
        'description': descriptionController.text.trim(),
        'service_area': serviceArea.value,
        'working_from': isAnyTime.value == true ? 'any_time' : workingFromController.text.trim(),
        'working_to': isAnyTime.value == true ? 'any_time' : workingToController.text.trim(),
        'is_any_time': (isAnyTime.value == true) ? '1' : '0',
      });

      if (profileImagePath.value.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(profileImagePath.value, filename: 'avatar.jpg'),
          ),
        );
      }

      //  gallery images as 'gallery[0]', 'gallery[1]' etc.
      for (int i = 0; i < galleryImages.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery[$i]',
            await MultipartFile.fromFile(galleryImages[i], filename: 'gallery_$i.jpg'),
          ),
        );
      }

      //  service category IDs as 'prv_category_ids[0]', 'prv_category_ids[1]' etc.
      final serviceIds = selectedServices.map((s) => s['id']!).toList();
      for (int i = 0; i < serviceIds.length; i++) {
        formData.fields.add(MapEntry('prv_category_ids[$i]', serviceIds[i]));
      }

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.join_as_provider,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json', 'Authorization': 'Bearer ${appBuilder.token}'},
        ),
      );

      if (response.success) {
        await _handleSuccessfulRegistration(response);
      } else {
        _handleRegistrationError(response);
      }
    } catch (e) {
      throw Exception('Provider registration API call failed: $e');
    }
  }

  Future<void> _handleSuccessfulRegistration(ResponseModel response) async {
    try {
      PopUpToast.show('Provider registration successful!');

      if (response.data != null && response.data is Map<String, dynamic>) {
        appBuilder.handleProviderRegistrationSuccess(response.data as Map<String, dynamic>);
      }

      // Navigate to success page or home
      Get.offAllNamed('/home');
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_processing_response_failed));
    }
  }

  void _handleRegistrationError(ResponseModel response) {
    String errorMsg = tr(LocaleKeys.errors_failed_complete_profile);

    try {
      if (response.data is List) {
        // Handle array of error messages
        final errors = response.data as List;
        errorMsg = errors.join('\n');
      } else if (response.data is Map<String, dynamic>) {
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
      print(' Error parsing registration error response: $e');
    }

    PopUpToast.show(errorMsg);
  }

  // Form field change handlers
  void onNameChanged(String value) => clearError();
  void onEmailChanged(String value) => clearError();

  void clearError() {
    // Clear any error states if needed
  }

  // Utility getters
  bool get hasProfileImage => profileImagePath.value.isNotEmpty;
  bool get hasGalleryImages => galleryImages.isNotEmpty;
  bool get isFormValid => formKey.currentState?.validate() ?? false;
}
