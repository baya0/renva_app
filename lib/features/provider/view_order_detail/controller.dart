// features/provider/view_order_detail/controller.dart
import 'package:get/get.dart';

import '../../../core/routes/routes.dart';
import '../../../core/widgets/modern_toast.dart';

class ViewOrderDetailController extends GetxController {
  // Order data received from navigation arguments
  late Map<String, dynamic> orderData;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeOrderData();
  }

  void _initializeOrderData() {
    try {
      // Get order data from navigation arguments
      final arguments = Get.arguments;

      if (arguments != null && arguments is Map<String, dynamic>) {
        orderData = arguments;
        print('✅ Order data loaded: ${orderData['id']}');
      } else {
        // Fallback data if no arguments provided
        orderData = {
          'id': 'N/A',
          'requesterName': 'Unknown User',
          'categoryTitle': 'Service Request',
          'description': 'No description available',
          'date': 'Date not specified',
          'time': 'Time not specified',
          'status': 'pending',
        };
      }
    } catch (e) {
      PopUpToast.show('Error loading order details');
    }
  }

  // Get order photos from API data
  List<String> get orderPhotos {
    try {
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['gallery'] != null) {
        final gallery = apiData['gallery'] as List?;
        if (gallery != null && gallery.isNotEmpty) {
          return gallery
              .map((photo) => photo['original_url']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error extracting photos: $e');
      return [];
    }
  }

  // Get user avatar from API data
  String? get userAvatar {
    try {
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['customer'] != null) {
        final customer = apiData['customer'] as Map<String, dynamic>?;
        if (customer != null && customer['avatar'] != null) {
          final avatar = customer['avatar'] as Map<String, dynamic>?;
          return avatar?['original_url']?.toString();
        }
      }
      return null;
    } catch (e) {
      PopUpToast.show('Error extracting user avatar');
      return null;
    }
  }

  // Get order ID
  String get orderId => orderData['id']?.toString() ?? 'N/A';

  // Get order status
  String get orderStatus => orderData['status']?.toString() ?? 'pending';

  // Get requester name
  String get requesterName {
    try {
      // First try the formatted name
      final formattedName = orderData['requesterName']?.toString();
      if (formattedName != null && formattedName.isNotEmpty) {
        return formattedName;
      }

      // Try to extract from API data
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['customer'] != null) {
        final customer = apiData['customer'] as Map<String, dynamic>?;
        if (customer != null) {
          final firstName = customer['first_name']?.toString() ?? '';
          final lastName = customer['last_name']?.toString() ?? '';
          final fullName = '$firstName $lastName'.trim();
          if (fullName.isNotEmpty) {
            return fullName;
          }
        }
      }

      return 'Unknown User';
    } catch (e) {
      print('Error getting requester name: $e');
      return 'Unknown User';
    }
  }

  // Get category title
  String get categoryTitle {
    try {
      // First try the formatted category
      final formattedCategory = orderData['categoryTitle']?.toString();
      if (formattedCategory != null && formattedCategory.isNotEmpty) {
        return formattedCategory;
      }

      // Try to extract from API data
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['category'] != null) {
        final category = apiData['category'] as Map<String, dynamic>?;
        final categoryName = category?['title']?.toString();
        if (categoryName != null && categoryName.isNotEmpty) {
          return categoryName;
        }
      }

      return 'Service Request';
    } catch (e) {
      print('Error getting category title: $e');
      return 'Service Request';
    }
  }

  // Get description
  String get description => orderData['description']?.toString() ?? 'No description available';

  // Get formatted date
  String get formattedDate {
    try {
      final date = orderData['date']?.toString();
      if (date != null && date.isNotEmpty) {
        return date;
      }

      // Try to extract from API data
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['date'] != null) {
        return apiData['date'].toString();
      }

      return 'Date not specified';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Date not specified';
    }
  }

  // Get formatted time
  String get formattedTime {
    try {
      final time = orderData['time']?.toString();
      if (time != null && time.isNotEmpty) {
        return time;
      }

      // Try to extract from API data
      final apiData = orderData['apiData'] as Map<String, dynamic>?;
      if (apiData != null && apiData['start_at'] != null) {
        return apiData['start_at'].toString();
      }

      return 'Time not specified';
    } catch (e) {
      print('Error formatting time: $e');
      return 'Time not specified';
    }
  }

  // Get price range
  String get priceRange {
    try {
      final minPrice = orderData['minPrice'];
      final maxPrice = orderData['maxPrice'];

      if (minPrice != null && maxPrice != null) {
        return '\$$minPrice - \$$maxPrice';
      } else if (minPrice != null) {
        return 'From \$$minPrice';
      } else if (maxPrice != null) {
        return 'Up to \$$maxPrice';
      }

      return 'Price not specified';
    } catch (e) {
      print('Error getting price range: $e');
      return 'Price not specified';
    }
  }

  // Navigate to add offer page
  void addOffer() {
    try {
      // Pass the order data to the add offer page
      Get.toNamed(
        Pages.add_offer_page.value,
        arguments: {
          'orderId': orderId,
          'orderData': orderData,
          'requesterName': requesterName,
          'categoryTitle': categoryTitle,
          'description': description,
        },
      );
    } catch (e) {
      PopUpToast.show('Unable to add offer at this time');
    }
  }

  // Handle back navigation
  void goBack() {
    Get.back();
  }
}
