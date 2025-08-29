import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/modern_toast.dart';

class AddOrderDetailsController extends GetxController {
  // Data from previous pages
  String categoryTitle = '';
  String subcategoryTitle = '';
  int categoryId = 0;
  int subcategoryId = 0;
  int minPrice = 0;
  int maxPrice = 0;
  String serviceSvg = '';

  // Service type selection
  final RxString selectedServiceType = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsFromPreviousPage();
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

        if (categoryId == 0 || subcategoryId == 0) {
          PopUpToast.show('Invalid category selection');
          Get.back();
          return;
        }
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
    }
  }

  void updateServiceType(String type) {
    selectedServiceType.value = type;

    if (type == 'Specific Date') {
      _selectDateTime();
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;

      // Optionally select time too
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        selectedTime.value = pickedTime;
      }
    }
  }

  // Navigation to complete order page
  void navigateToCompleteOrder() {
    if (selectedServiceType.value.isEmpty) {
      PopUpToast.show('Please select a service type');
      return;
    }

    final orderData = {
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'categoryTitle': categoryTitle,
      'subcategoryTitle': subcategoryTitle,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'serviceSvg': serviceSvg,
      'serviceType': selectedServiceType.value,
      'selectedDate': selectedDate.value,
      'selectedTime': selectedTime.value,
    };

    Get.toNamed('/complete_order_detail', arguments: orderData);
  }

  // Helper getters
  bool get isServiceTypeSelected => selectedServiceType.value.isNotEmpty;

  String get dateTimeDisplay {
    if (selectedServiceType.value == 'Specific Date' && selectedDate.value != null) {
      String dateStr =
          "${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}";
      if (selectedTime.value != null) {
        dateStr += " at ${selectedTime.value!.format(Get.context!)}";
      }
      return dateStr;
    }
    return 'As Soon As Possible';
  }
}
