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
        serviceType = args['serviceType'] ?? tr(LocaleKeys.orders_as_soon_as_possible);
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

  // Getters for display with proper localization
  String get serviceTypeDisplay {
    return serviceType == tr(LocaleKeys.add_order_details_specific_date)
        ? tr(LocaleKeys.orders_scheduled)
        : tr(LocaleKeys.orders_as_soon_as_possible);
  }

  String get dateTimeDisplay {
    if (serviceType == tr(LocaleKeys.add_order_details_specific_date) && selectedDate != null) {
      String display = DateFormat('dd/MM/yyyy').format(selectedDate!);
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
    return '${priceRange.start.round()} - ${priceRange.end.round()} $currency';
  }

  String get categoryDisplay {
    return subcategoryTitle.isNotEmpty ? subcategoryTitle : categoryTitle;
  }

  String get descriptionDisplay {
    return description.isNotEmpty ? description : tr(LocaleKeys.offer_details_default_description);
  }

  String get photoCountDisplay {
    final count = uploadedPhotos.length;
    return tr(LocaleKeys.complete_order_photos_count, namedArgs: {'count': count.toString()});
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
        PopUpToast.show(tr(LocaleKeys.add_orders_please_select_subcategory));
        return;
      }

      if (priceRange.start <= 0 || priceRange.end <= 0) {
        PopUpToast.show(tr(LocaleKeys.forms_invalid_price_range));
        return;
      }

      if (description.trim().length < 10) {
        PopUpToast.show(tr(LocaleKeys.forms_min_length, args: ['10']));
        return;
      }

      Map<String, dynamic> formDataMap = {
        'main_category_id': categoryId.toString(),
        'category_id': subcategoryId.toString(),
        'prv_category_id': subcategoryId.toString(),
        'description': description.trim(),
        'type':
            serviceType == tr(LocaleKeys.orders_as_soon_as_possible)
                ? 'immediately'
                : 'none_immediately',
        'min_price': priceRange.start.round().toString(),
        'max_price': priceRange.end.round().toString(),
        'address_lat': '32.000',
        'address_long': '24.5555',
        'address_title': 'test',
        'address_id': '1',
      };

      DateTime dateToUse =
          serviceType == tr(LocaleKeys.add_order_details_specific_date) && selectedDate != null
              ? selectedDate!
              : DateTime.now();

      String timeToUse =
          serviceType == tr(LocaleKeys.add_order_details_specific_date) && selectedTime != null
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
        await _handleSuccessfulOrderCreation(response);
      } else {
        _handleOrderCreationError(response);
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.offer_details_network_error));
    }
  }

  // Handle successful order creation
  Future<void> _handleSuccessfulOrderCreation(ResponseModel response) async {
    try {
      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        try {
          createdOrder.value = OrderResponseModel.fromJson(responseData);
        } catch (modelError) {
          print(' Model creation failed, but API was successful: $modelError');
          createdOrder.value = null;
        }

        String successMessage =
            responseData['message'] ??
            response.message ??
            tr(LocaleKeys.orders_order_created_successfully);

        PopUpToast.show(
          successMessage.isNotEmpty
              ? successMessage
              : tr(LocaleKeys.orders_order_created_successfully),
        );

        _navigateAfterSuccess();
      } else {
        throw Exception('Response data is null despite success status');
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.orders_order_created_successfully));
      _navigateAfterSuccess();
    }
  }

  // Handle order creation error
  void _handleOrderCreationError(ResponseModel response) {
    String errorMessage = tr(LocaleKeys.orders_error_creating_order);

    if (response.data != null) {
      if (response.data is Map<String, dynamic>) {
        Map<String, dynamic> data = response.data;

        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
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
        List<String> errors = (response.data as List).cast<String>();
        errorMessage = errors.join('\n');
      } else {
        errorMessage = response.data.toString();
      }
    }

    PopUpToast.show(errorMessage);
  }

  void _navigateAfterSuccess() {
    Get.offAllNamed('/home');
  }
}
