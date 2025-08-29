// features/provider/add_offer/controller.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../main/controller.dart';

class AddOfferController extends GetxController {
  // Data from previous page (order details)
  String orderId = '';
  Map<String, dynamic> orderData = {};
  String requesterName = '';
  String categoryTitle = '';
  String description = '';
  int minPrice = 100;
  int maxPrice = 400;

  // Form controllers
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final executionTimeController = TextEditingController();

  // Form validation keys
  final formKey = GlobalKey<FormState>();

  // Reactive state
  final RxList<File> galleryImages = <File>[].obs;
  final RxString selectedTimeUnit = 'hour'.obs;
  final RxBool isFormValid = false.obs;
  final RxBool isSubmitting = false.obs;

  // Time unit options (API expects these specific values)
  final List<String> timeUnits = ['hour', 'day', 'week', 'month', 'year'];

  // Image picker
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  final AppBuilder appBuilder = Get.find<AppBuilder>();

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsFromPreviousPage();
    _setupFormValidation();
  }

  @override
  void onClose() {
    priceController.dispose();
    descriptionController.dispose();
    executionTimeController.dispose();
    super.onClose();
  }

  void _loadArgumentsFromPreviousPage() {
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map<String, dynamic>;
        orderId = args['orderId']?.toString() ?? '';
        orderData = args['orderData'] ?? {};
        requesterName = args['requesterName'] ?? '';
        categoryTitle = args['categoryTitle'] ?? '';
        description = args['description'] ?? '';

        // Extract min/max price from order data
        if (orderData['apiData'] != null) {
          final apiData = orderData['apiData'] as Map<String, dynamic>;
          final category = apiData['category'] as Map<String, dynamic>?;
          if (category != null) {
            minPrice = category['min_price'] ?? 100;
            maxPrice = category['max_price'] ?? 400;
          }
        }
      }
    } catch (e) {
      print(' Error loading arguments: $e');
      Get.back();
    }
  }

  void _setupFormValidation() {
    // Listen to form changes
    priceController.addListener(_validateForm);
    descriptionController.addListener(_validateForm);
    executionTimeController.addListener(_validateForm);
    ever(galleryImages, (_) => _validateForm());
  }

  void _validateForm() {
    bool isValid = _isFormValid();
    isFormValid.value = isValid;
  }

  bool _isFormValid() {
    // Check price is within range
    final price = double.tryParse(priceController.text.trim());
    if (price == null || price < minPrice || price > maxPrice) {
      return false;
    }

    // Check description length
    if (descriptionController.text.trim().length < 10) {
      return false;
    }

    // Check execution time
    final time = int.tryParse(executionTimeController.text.trim());
    if (time == null || time <= 0) {
      return false;
    }

    return true;
  }

  // Price validation
  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_required_field);
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < minPrice || price > maxPrice) {
      return 'Price must be between $minPrice - $maxPrice SEK';
    }

    return null;
  }

  // Description validation
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_required_field);
    }
    if (value.trim().length < 10) {
      return tr(LocaleKeys.forms_min_length, args: ['10']);
    }
    return null;
  }

  // Execution time validation
  String? validateExecutionTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_required_field);
    }

    final time = int.tryParse(value.trim());
    if (time == null || time <= 0) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // Time unit selection
  void updateTimeUnit(String? unit) {
    if (unit != null && timeUnits.contains(unit)) {
      selectedTimeUnit.value = unit;
    }
  }

  // Gallery image management
  Future<void> addGalleryImage() async {
    if (_isPicking) return;
    _isPicking = true;

    if (galleryImages.length >= 5) {
      PopUpToast.show('Maximum 5 photos allowed');
      _isPicking = false;
      return;
    }

    try {
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text('Add Photo'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                title: Text(tr(LocaleKeys.dialogs_camera)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green, size: 28),
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
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          galleryImages.add(File(image.path));
          PopUpToast.show('Photo added successfully');
        }
      }
    } catch (e) {
      PopUpToast.show('Error adding photo');
    } finally {
      _isPicking = false;
    }
  }

  void removeGalleryImage(int index) {
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
      PopUpToast.show('Photo removed');
    }
  }

  bool get canAddMorePhotos => galleryImages.length < 5;

  // Price range display helpers
  String get priceRangeText => '$minPrice - $maxPrice SEK';
  String get priceHint => 'Ex: ${(minPrice + (maxPrice - minPrice) / 2).round()} SEK';

  // Navigation methods
  void goBack() {
    Get.back();
  }

  void continueToReview() {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      PopUpToast.show('Please fill all required fields correctly');
      return;
    }

    // Navigate to review page with offer data
    Get.toNamed(
      Pages.review_offer_page.value,
      arguments: {
        'orderId': orderId,
        'orderData': orderData,
        'requesterName': requesterName,
        'categoryTitle': categoryTitle,
        'orderDescription': description,
        'offerDescription': descriptionController.text.trim(),
        'price': priceController.text.trim(),
        'executionTime': executionTimeController.text.trim(),
        'timeUnit': selectedTimeUnit.value,
        'galleryImages': galleryImages.toList(),
        'priceRange': priceRangeText,
      },
    );
  }

  // API submission (called from review page)
  Future<void> submitOffer({
    required String offerDescription,
    required String price,
    required String executionTime,
    required List<File> images,
  }) async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;
      // Create FormData for multipart request
      final formData = FormData.fromMap({
        'order_id': orderId,
        'description': offerDescription,
        'price': price,
        'time': executionTime,
        'time_type': selectedTimeUnit.value,
      });

      // Add gallery images
      for (int i = 0; i < images.length; i++) {
        if (await images[i].exists()) {
          formData.files.add(
            MapEntry(
              'gallery[$i]',
              await MultipartFile.fromFile(
                images[i].path,
                filename: 'offer_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              ),
            ),
          );
        }
      }

      // Make API call
      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.new_offer,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json'},
        ),
      );

      if (response.success) {
        await _handleSuccessfulOfferSubmission(response);
      } else {
        _handleOfferSubmissionError(response);
      }
    } catch (e) {
      PopUpToast.show('Network error. Please check your connection.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _handleSuccessfulOfferSubmission(ResponseModel response) async {
    try {
      PopUpToast.show('Offer submitted successfully!');

      Get.until((route) => route.settings.name == Pages.home.value); // pop all pages above MainPage
      final mainPageController = Get.find<MainPageController>();
      mainPageController.changePage(0); // switch to ProviderHomePage :D
    } catch (e) {
      print('Error handling successful submission: $e');
      PopUpToast.show('Offer submitted but navigation failed');
    }
  }

  void _handleOfferSubmissionError(ResponseModel response) {
    String errorMsg = 'Failed to submit offer. Please try again.';

    try {
      if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
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
      }
    } catch (e) {
      print('Error parsing error response: $e');
    }

    PopUpToast.show(errorMsg);
  }
}
