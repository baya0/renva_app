import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:renva0/features/add_orders/models/order.dart';

import '../../../../../core/config/app_builder.dart';
import '../../../../../core/localization/strings.dart';
import '../../../../../core/widgets/modern_toast.dart';

class CompleteOrderController extends GetxController {
  // Data from previous pages
  String categoryTitle = '';
  String subcategoryTitle = '';
  int categoryId = 0;
  int subcategoryId = 0;
  int minPrice = 100;
  int maxPrice = 400;
  String serviceSvg = '';
  String serviceType = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Form controllers
  final descriptionController = TextEditingController();

  late final Rx<RangeValues> priceRange;
  final RxList<File> uploadedPhotos = <File>[].obs;
  final RxBool isFormValid = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isSuccess = false.obs;

  // Form validation keys
  final descriptionFormKey = GlobalKey<FormState>();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final Rx<OrderResponseModel?> createdOrder = Rx<OrderResponseModel?>(null);

  final AppBuilder appBuilder = Get.find<AppBuilder>();

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsFromPreviousPage();
    // Initialize priceRange AFTER loading arguments
    priceRange = RangeValues(minPrice.toDouble(), maxPrice.toDouble()).obs;
    _setupFormValidation();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void _loadArgumentsFromPreviousPage() {
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map<String, dynamic>;
        categoryId = args['categoryId'] ?? 0;
        subcategoryId = args['subcategoryId'] ?? 0;
        categoryTitle = args['categoryTitle'] ?? '';
        subcategoryTitle = args['subcategoryTitle'] ?? '';
        minPrice = args['minPrice'] ?? 50;
        maxPrice = args['maxPrice'] ?? 200;
        serviceSvg = args['serviceSvg'] ?? '';
        serviceType = args['serviceType'] ?? '';
        selectedDate = args['selectedDate'];
        selectedTime = args['selectedTime'];
      } else {
        minPrice = 50;
        maxPrice = 200;
        Get.back();
      }
    } catch (e) {
      Get.back();
    }
  }

  void _setupFormValidation() {
    // Listen to description changes
    descriptionController.addListener(_validateForm);

    // Listen to other form changes
    ever(priceRange, (_) => _validateForm());
    ever(uploadedPhotos, (_) => _validateForm());
  }

  void _validateForm() {
    bool isValid = descriptionController.text.trim().length >= 10;
    isFormValid.value = isValid;
  }

  // Price range methods
  void updatePriceRange(RangeValues values) {
    priceRange.value = values;
  }

  // Description validation
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(LocaleKeys.forms_required_field);
    }
    if (value.trim().length < 10) {
      return tr(LocaleKeys.forms_min_length, namedArgs: {'min': '10'});
    }
    return null;
  }

  // Photo management methods
  bool _isPicking = false;

  Future<void> addPhoto() async {
    if (_isPicking) return; // Already picking
    _isPicking = true;

    if (uploadedPhotos.length >= 5) {
      PopUpToast.show(tr(LocaleKeys.forms_max_photos));
      _isPicking = false;
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        uploadedPhotos.add(File(image.path));
        PopUpToast.show(tr(LocaleKeys.forms_photo_added_successfully));
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.forms_error_adding_photo));
    } finally {
      _isPicking = false;
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < uploadedPhotos.length) {
      uploadedPhotos.removeAt(index);
      PopUpToast.show(tr(LocaleKeys.forms_photo_removed));
    }
  }

  bool get canAddMorePhotos => uploadedPhotos.length < 5;

  Future<void> submitOrder() async {
    if (!descriptionFormKey.currentState!.validate()) {
      return;
    }
    if (!isFormValid.value) {
      PopUpToast.show(tr(LocaleKeys.forms_required_field));
      return;
    }

    _navigateToReviewPage();
  }

  void _navigateToReviewPage() {
    // Prepare all order data to pass to review page
    final orderReviewData = {
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'categoryTitle': categoryTitle,
      'subcategoryTitle': subcategoryTitle,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'serviceSvg': serviceSvg,
      'serviceType': serviceType,
      'selectedDate': selectedDate,
      'selectedTime': selectedTime,
      'description': descriptionController.text.trim(),
      'priceRangeStart': priceRange.value.start,
      'priceRangeEnd': priceRange.value.end,
      'uploadedPhotos': uploadedPhotos.toList(),
    };
    // Navigate to review page
    Get.toNamed('/review_completed_order_page', arguments: orderReviewData);
  }

  // Navigation methods
  void goToMyOrders() {
    Get.offAllNamed('/home');
  }

  void createAnotherOrder() {
    Get.offAllNamed('/add_order_page');
  }

  void goBack() {
    if (isSuccess.value == true) {
      Get.offAllNamed('/home');
    } else {
      Get.back();
    }
  }

  // Getters for display with localization
  String get serviceTypeDisplay {
    return serviceType == tr(LocaleKeys.add_order_details_specific_date)
        ? tr(LocaleKeys.orders_scheduled)
        : tr(LocaleKeys.orders_as_soon_as_possible);
  }

  String get dateTimeDisplay {
    if (serviceType == tr(LocaleKeys.add_order_details_specific_date) && selectedDate != null) {
      String display = '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      if (selectedTime != null) {
        display +=
            ' ${tr(LocaleKeys.add_order_details_at_time)} ${selectedTime!.format(Get.context!)}';
      }
      return display;
    }
    return tr(LocaleKeys.orders_as_soon_as_possible);
  }

  String get priceRangeDisplay {
    final currency = tr(LocaleKeys.complete_order_sek_currency);
    return '${priceRange.value.start.round()} - ${priceRange.value.end.round()} $currency';
  }

  String get priceRangeDisplaySYP {
    // Alternative currency display
    final currency = tr(LocaleKeys.complete_order_syp_currency);
    return '${priceRange.value.start.round()} - ${priceRange.value.end.round()} $currency';
  }

  bool get hasPhotos => uploadedPhotos.isNotEmpty;
  int get photoCount => uploadedPhotos.length;

  String get categoryDisplay => '$categoryTitle - $subcategoryTitle';

  String get descriptionPreview {
    String desc = descriptionController.text;
    if (desc.length <= 100) {
      return desc;
    }
    return '${desc.substring(0, 100)}...';
  }

  // Localized photo count display
  String get photoCountDisplay {
    return tr(LocaleKeys.complete_order_photos_count, namedArgs: {'count': photoCount.toString()});
  }
}
