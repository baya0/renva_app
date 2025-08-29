import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:renva0/features/add_orders/models/order.dart';

import '../../../../../core/config/app_builder.dart';
import '../../../../../core/localization/strings.dart';
import '../../../../../core/services/rest_api/rest_api.dart';
import '../../../../../core/widgets/modern_toast.dart';

class ReviewCompletedOrderController extends GetxController {
  // Data from complete order page
  String categoryTitle = '';
  String subcategoryTitle = '';
  int categoryId = 0;
  int subcategoryId = 0;
  int minPrice = 50;
  int maxPrice = 200;
  String serviceSvg = '';
  String serviceType = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String description = '';
  RangeValues priceRange = const RangeValues(100, 400);
  List<File> uploadedPhotos = [];

  // UI state
  final RxBool isSubmitting = false.obs;
  final Rx<OrderResponseModel?> createdOrder = Rx<OrderResponseModel?>(null);

  final AppBuilder appBuilder = Get.find<AppBuilder>();

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsFromCompleteOrderPage();
  }

  void _loadArgumentsFromCompleteOrderPage() {
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
        serviceType = args['serviceType'] ?? 'As Soon As Possible';
        selectedDate = args['selectedDate'];
        selectedTime = args['selectedTime'];
        description = args['description'] ?? '';

        double priceStart = args['priceRangeStart']?.toDouble() ?? minPrice.toDouble();
        double priceEnd = args['priceRangeEnd']?.toDouble() ?? maxPrice.toDouble();

        // Ensure the values are within the category limits and not zero
        if (priceStart < minPrice.toDouble()) priceStart = minPrice.toDouble();
        if (priceEnd > maxPrice.toDouble()) priceEnd = maxPrice.toDouble();
        if (priceStart <= 0) priceStart = minPrice.toDouble();
        if (priceEnd <= 0) priceEnd = maxPrice.toDouble();

        priceRange = RangeValues(priceStart, priceEnd);

        // Handle uploaded photos
        if (args['uploadedPhotos'] != null && args['uploadedPhotos'] is List) {
          uploadedPhotos = List<File>.from(args['uploadedPhotos']);
        }
      }
    } catch (e) {
      print(' Error loading arguments: $e');
    }
  }

  // Getters for display
  String get serviceTypeDisplay {
    return serviceType == 'Specific Date'
        ? tr(LocaleKeys.orders_scheduled)
        : tr(LocaleKeys.orders_as_soon_as_possible);
  }

  String get dateTimeDisplay {
    if (serviceType == 'Specific Date' && selectedDate != null) {
      String display =
          '${selectedDate!.day} - ${_getMonthAbbr(selectedDate!.month)} - ${selectedDate!.year}';
      if (selectedTime != null) {
        display += ', ${selectedTime!.format(Get.context!)}';
      }
      return display;
    }
    return 'As soon as possible';
  }

  String get priceRangeDisplay {
    return '${priceRange.start.round()} SEK';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Navigation methods
  void goBack() {
    Get.back();
  }

  void cancelOrder() {
    Get.back();
  }

  // Main confirm method - submits order to API
  Future<void> confirmOrder() async {
    isSubmitting.value = true;

    try {
      await _makeOrderCreationAPI();
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.orders_error_creating_order));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _makeOrderCreationAPI() async {
    try {
      if (categoryId <= 0 || subcategoryId <= 0) {
        PopUpToast.show('Invalid category selection');
        return;
      }

      if (priceRange.start <= 0 || priceRange.end <= 0) {
        PopUpToast.show('Invalid price range: ${priceRange.start} - ${priceRange.end}');
        return;
      }

      if (description.trim().length < 10) {
        PopUpToast.show('Description must be at least 10 characters');
        return;
      }

      Map<String, dynamic> formDataMap = {
        'main_category_id': categoryId.toString(),
        'category_id': subcategoryId.toString(),
        'prv_category_id': subcategoryId.toString(),
        'description': description.trim(),
        'type': serviceType == 'As Soon As Possible' ? 'immediately' : 'none_immediately',
        'min_price': priceRange.start.round().toString(),
        'max_price': priceRange.end.round().toString(),
        'address_lat': '32.000',
        'address_long': '24.5555',
        'address_title': 'test',
        'address_id': '1',
      };

      DateTime dateToUse =
          serviceType == 'Specific Date' && selectedDate != null ? selectedDate! : DateTime.now();

      String timeToUse =
          serviceType == 'Specific Date' && selectedTime != null
              ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00'
              : '09:00:00';

      formDataMap['date'] = DateFormat('yyyy-MM-dd').format(dateToUse);
      formDataMap['start_at'] = timeToUse;

      FormData formData = FormData.fromMap(formDataMap);

      if (uploadedPhotos.isNotEmpty) {
        for (int i = 0; i < uploadedPhotos.length; i++) {
          final file = uploadedPhotos[i];

          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'gallery[$i]',
                await MultipartFile.fromFile(
                  file.path,
                  filename: 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
                ),
              ),
            );
          }
        }
      }
      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.new_order,
          method: RequestMethod.Post,
          body: formData,
          copyHeader: {'Accept': 'application/json'},
        ),
      );

      if (response.success) {
        // If API returns success, always call success handler
        await _handleSuccessfulOrderCreation(response);
      } else {
        // Only call error handler if API actually failed
        _handleOrderCreationError(response);
      }
    } catch (e) {
      PopUpToast.show('Network error. Please check your connection.');
    }
  }

  // Handle successful order creation
  Future<void> _handleSuccessfulOrderCreation(ResponseModel response) async {
    try {
      // Extract order details from response
      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        try {
          createdOrder.value = OrderResponseModel.fromJson(responseData);
        } catch (modelError) {
          // Even if model creation fails, we can still show success
          print(' Model creation failed, but API was successful: $modelError');
          createdOrder.value = null;
        }

        // Show success message
        String successMessage =
            responseData['message'] ??
            response.message ??
            tr(LocaleKeys.orders_order_created_successfully);

        PopUpToast.show(successMessage.isNotEmpty ? successMessage : 'Order created successfully!');

        // Navigate to success page
        _navigateAfterSuccess();
      } else {
        throw Exception('Response data is null despite success status');
      }
    } catch (e) {
      // Even if there's an error in parsing, show success since API worked
      PopUpToast.show('Order created successfully! (ID: ${response.data?['id'] ?? 'Unknown'})');
      _navigateAfterSuccess();
    }
  }

  // Handle order creation error
  void _handleOrderCreationError(ResponseModel response) {
    String errorMessage = tr(LocaleKeys.orders_error_creating_order);

    if (response.data != null) {
      if (response.data is Map<String, dynamic>) {
        // Handle structured error response
        Map<String, dynamic> data = response.data;

        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
          // Handle validation errors
          if (data['errors'] is List) {
            List<String> errors = (data['errors'] as List).cast<String>();
            errorMessage = errors.join('\n');
          } else if (data['errors'] is Map) {
            Map<String, dynamic> errors = data['errors'];
            List<String> errorMessages = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });
            errorMessage = errorMessages.join('\n');
          }
        }
      } else if (response.data is List) {
        // Handle list of errors directly
        List<String> errors = (response.data as List).cast<String>();
        errorMessage = errors.join('\n');
      } else {
        // Handle other data types
        errorMessage = response.data.toString();
      }
    }

    PopUpToast.show(errorMessage);
  }

  void _navigateAfterSuccess() {
    // Navigate to home or orders page after successful creation
    Get.offAllNamed('/home');
  }
}
