import 'dart:io';

import 'package:get/get.dart';

import '../../../core/widgets/modern_toast.dart';
import '../add_offer/controller.dart';

class ReviewOfferController extends GetxController {
  // Offer data from add offer page
  String orderId = '';
  Map<String, dynamic> orderData = {};
  String requesterName = '';
  String categoryTitle = '';
  String orderDescription = '';
  String offerDescription = '';
  String price = '';
  String executionTime = '';
  String timeUnit = '';
  List<File> galleryImages = [];
  String priceRange = '';

  // Loading state
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOfferData();
  }

  void _loadOfferData() {
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map<String, dynamic>;
        orderId = args['orderId']?.toString() ?? '';
        orderData = args['orderData'] ?? {};
        requesterName = args['requesterName'] ?? '';
        categoryTitle = args['categoryTitle'] ?? '';
        orderDescription = args['orderDescription'] ?? '';
        offerDescription = args['offerDescription'] ?? '';
        price = args['price'] ?? '';
        executionTime = args['executionTime'] ?? '';
        timeUnit = args['timeUnit'] ?? '';
        galleryImages = List<File>.from(args['galleryImages'] ?? []);
        priceRange = args['priceRange'] ?? '';
      } else {
        PopUpToast.show('Error loading offer data');
        Get.back();
      }
    } catch (e) {
      PopUpToast.show('Error loading offer data');
      Get.back();
    }
  }

  // Getters for display
  String get formattedExecutionTime =>
      '$executionTime ${timeUnit.capitalizeFirst}${int.parse(executionTime) != 1 ? 's' : ''}';
  String get formattedPrice => '$price SEK';
  bool get hasImages => galleryImages.isNotEmpty;

  // Get order date from API data
  String get orderDate {
    try {
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['date'] != null) {
        return apiData['date'].toString();
      }
      return 'Date not specified';
    } catch (e) {
      return 'Date not specified';
    }
  }

  // Get order time from API data
  String get orderTime {
    try {
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['start_at'] != null) {
        return apiData['start_at'].toString();
      }
      return '03:00 Am'; // Default as shown in the image
    } catch (e) {
      return '03:00 Am';
    }
  }

  // Navigation methods
  void goBack() {
    Get.back();
  }

  void editOffer() {
    Get.back(); // Go back to add offer page to edit
  }

  // Submit offer to API
  Future<void> submitOffer() async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;

      // Get the AddOfferController to use its API submission logic
      final addOfferController = Get.find<AddOfferController>();

      await addOfferController.submitOffer(
        offerDescription: offerDescription,
        price: price,
        executionTime: executionTime,
        images: galleryImages,
      );
    } catch (e) {
      PopUpToast.show('Failed to submit offer. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
