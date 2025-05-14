// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/config/role.dart';
import '../../main/routescontroller.dart';

class CompleteInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final fullName = TextEditingController();
  final email = TextEditingController();
  final nationalNumber = TextEditingController();
  final gender = TextEditingController();

  final profileImage = ''.obs;
  final isLoading = false.obs;

  Future<void> pickProfilePhoto() async {
    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(tr('Select Image Source')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: Text(tr('Camera')),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(tr('Gallery')),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(source: source);
        if (pickedImage != null) {
          profileImage.value = pickedImage.path;
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return tr('validators.name_required');
    }
    if (value.length < 3) {
      return tr('validators.name_min', namedArgs: {'min': '3'});
    }
    if (value.length > 50) {
      return tr('validators.name_max', namedArgs: {'max': '50'});
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return tr('validators.email_required');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return tr('validators.email_invalid');
    }
    return null;
  }

  String? validateNationalNumber(String? value) {
    if (value == null || value.isEmpty) {
      return tr(
        'validators.required_field',
        namedArgs: {'field': tr('common.national_number')},
      );
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return tr(
        'validators.required_field',
        namedArgs: {'field': tr('common.gender')},
      );
    }
    return null;
  }

  void completeProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Update the app state
      final appBuilder = Get.find<AppBuilder>();
      appBuilder.setProfileCompleted(true);
      appBuilder.setRole(Role.user);
      Get.find<routesController>().checkAndNavigate();
    } catch (e) {
      print('Error completing profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    fullName.dispose();
    email.dispose();
    nationalNumber.dispose();
    gender.dispose();
    super.onClose();
  }
}
