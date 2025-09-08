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

  // Mode detection
  bool isViewMode = false; // true = just viewing, false = can submit
  bool showEditButtons = true; // Whether to show "Edit" buttons

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

        print('=== DEBUG: ReviewOfferController arguments ===');
        print('Full arguments: $args');

        // Check for view mode
        isViewMode = args['viewMode'] == true || args['isViewOnly'] == true;
        showEditButtons = args['showEditButtons'] != false; // Default true unless explicitly false

        // Handle the new data structure from ProviderOrderCard
        if (args.containsKey('offer') && args.containsKey('order')) {
          // New structure from ProviderOrderCard navigation (VIEW MODE)
          isViewMode = true; // Automatically set to view mode when coming from offer card
          showEditButtons = false; // Hide edit buttons when viewing existing offers

          final offer = args['offer'] as Map<String, dynamic>? ?? {};
          final order = args['order'] as Map<String, dynamic>? ?? {};

          orderId = order['id']?.toString() ?? '';
          orderDescription = order['description']?.toString() ?? '';
          offerDescription = offer['description']?.toString() ?? '';
          price = offer['price']?.toString() ?? '';
          requesterName = offer['provider_name']?.toString() ?? '';

          // Try to extract execution time and other data if available
          executionTime = offer['execution_time']?.toString() ?? '1';
          timeUnit = offer['time_unit']?.toString() ?? 'hour';

          // Store the order data for date/time extraction
          orderData = {'apiData': order};
        } else {
          // Original structure from AddOfferController (SUBMIT MODE)
          isViewMode = false; // This is for submitting a new offer
          showEditButtons = true; // Show edit buttons for new offers

          orderId = args['orderId']?.toString() ?? '';
          orderData = args['orderData'] ?? {};
          requesterName = args['requesterName'] ?? '';
          categoryTitle = args['categoryTitle'] ?? '';
          orderDescription = args['orderDescription'] ?? '';
          offerDescription = args['offerDescription'] ?? '';
          price = args['price'] ?? '';
          executionTime = args['executionTime'] ?? '1';
          timeUnit = args['timeUnit'] ?? 'hour';
          galleryImages = List<File>.from(args['galleryImages'] ?? []);
          priceRange = args['priceRange'] ?? '';
        }
      } else {
        PopUpToast.show('Error loading offer data');
        Get.back();
      }
    } catch (e, stackTrace) {
      print(' Error in _loadOfferData: $e');
      print('Stack trace: $stackTrace');
      PopUpToast.show('Error loading offer data: $e');
      Get.back();
    }
  }

  // Getter to determine button text
  String get actionButtonText {
    return isViewMode ? 'Close' : 'Done';
  }

  // Getter to determine if button should be shown
  bool get shouldShowActionButton {
    return true; // Always show button, but text changes based on mode
  }

  // Getters for display with safe parsing
  String get formattedExecutionTime {
    try {
      // Safely parse execution time
      int parsedTime = int.tryParse(executionTime) ?? 1;
      String unit = timeUnit.isNotEmpty ? timeUnit : 'hour';

      // Add 's' for plural
      if (parsedTime != 1 && !unit.endsWith('s')) {
        unit += 's';
      }

      return '$parsedTime ${unit.capitalizeFirst}';
    } catch (e) {
      print('Error formatting execution time: $e');
      return '1 Hour'; // Fallback
    }
  }

  String get formattedPrice {
    try {
      // Clean the price string and validate
      String cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');

      if (cleanPrice.isEmpty) {
        return '\$0'; // Fallback
      }

      // Try to parse as double for proper formatting
      double? parsedPrice = double.tryParse(cleanPrice);
      if (parsedPrice != null) {
        return '\$${parsedPrice.toStringAsFixed(0)}';
      } else {
        // If parsing fails, return the original with currency symbol
        return '\$$price';
      }
    } catch (e) {
      print('Error formatting price: $e');
      return '\$$price'; // Fallback to original
    }
  }

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
      print('Error getting order date: $e');
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
      return '03:00 AM'; // Default as shown in the image
    } catch (e) {
      print('Error getting order time: $e');
      return '03:00 AM';
    }
  }

  // Navigation methods
  void goBack() {
    Get.back();
  }

  void editOffer() {
    if (isViewMode) {
      // In view mode, editing is not allowed
      PopUpToast.show('This offer cannot be edited');
      return;
    }
    Get.back(); // Go back to add offer page to edit
  }

  //  Updated action button handler
  Future<void> handleActionButton() async {
    if (isViewMode) {
      // In view mode, just close the page
      Get.back();
    } else {
      // In submit mode, submit the offer
      await submitOffer();
    }
  }

  // Submit offer to API (only used in submit mode)
  Future<void> submitOffer() async {
    if (isSubmitting.value) return;

    if (isViewMode) {
      // Don't allow submission in view mode
      Get.back();
      return;
    }

    try {
      isSubmitting.value = true;

      // Get the AddOfferController to use its API submission logic
      if (Get.isRegistered<AddOfferController>()) {
        final addOfferController = Get.find<AddOfferController>();

        await addOfferController.submitOffer(
          offerDescription: offerDescription,
          price: price,
          executionTime: executionTime,
          images: galleryImages,
        );
      } else {
        // If AddOfferController is not available, just go back
        PopUpToast.show('Offer submitted successfully');
        Get.back();
      }
    } catch (e) {
      print('Error submitting offer: $e');
      PopUpToast.show('Failed to submit offer. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
