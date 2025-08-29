import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/widgets/modern_toast.dart';

class ProviderHomePageController extends GetxController {
  final AppBuilder appBuilder = Get.find<AppBuilder>();

  final Rx<Map<String, dynamic>?> providerInfo = Rx<Map<String, dynamic>?>(null);

  final RxBool isLoadingProviderInfo = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadProviderInfo();
  }

  Future<void> loadProviderInfo() async {
    try {
      isLoadingProviderInfo.value = true;

      await _fetchProviderDataFromAPI();
    } catch (e) {
      // Set fallback data
      providerInfo.value = {
        'name': 'Provider Name',
        'category': 'Service Provider',
        'rating': 0.0,
        'avatar': null,
        'status': 'Active',
      };
    } finally {
      isLoadingProviderInfo.value = false;
    }
  }

  Future<void> _fetchProviderDataFromAPI() async {
    try {
      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.getProfile,
          method: RequestMethod.Get,
          fromJson: (json) => json,
        ),
      );

      if (response.success && response.data != null) {
        final userData = response.data as Map<String, dynamic>;

        // Check if user has provider data
        if (userData['provider'] != null) {
          final providerData = userData['provider'] as Map<String, dynamic>;

          providerInfo.value = {
            'name': providerData['name'] ?? userData['first_name'] ?? 'Provider',
            'category': _extractCategoryFromProvider(providerData),
            'rating': (providerData['rate'] ?? 0.0).toDouble(),
            'avatar': _extractAvatarFromProvider(providerData),
            'status': providerData['status'] ?? 'Approved',
          };
        } else {
          // Use user data as fallback
          providerInfo.value = {
            'name': userData['first_name'] ?? 'Provider',
            'category': 'Service Provider',
            'rating': 0.0,
            'avatar': userData['avatar']?['original_url'],
            'status': 'Pending',
          };
        }
      } else {
        throw Exception('API call failed: ${response.message}');
      }
    } catch (e) {
      print(' Error fetching from API: $e');
      rethrow;
    }
  }

  String _extractCategoryFromProvider(Map<String, dynamic> providerData) {
    try {
      final categories = providerData['categories'];
      if (categories != null && categories is List && categories.isNotEmpty) {
        final firstCategory = categories.first;
        if (firstCategory is Map<String, dynamic> && firstCategory['title'] != null) {
          return firstCategory['title'];
        }
      }
      return 'Service Provider';
    } catch (e) {
      print('Error extracting category: $e');
      return 'Service Provider';
    }
  }

  String? _extractAvatarFromProvider(Map<String, dynamic> providerData) {
    try {
      final avatar = providerData['avatar'];
      if (avatar != null && avatar is Map<String, dynamic>) {
        return avatar['original_url']?.toString();
      }
      return null;
    } catch (e) {
      print('Error extracting avatar: $e');
      return null;
    }
  }

  Future<void> refreshProviderInfo() async {
    // Set loading state
    providerInfo.value = {...providerInfo.value ?? {}, 'status': 'Refreshing...'};
    await loadProviderInfo();
  }

  Future<ResponseModel> fetchOrdersPage(int page, CancelToken cancel) async {
    try {
      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.orders_by_status,
          params: {"page": page},
          fromJson: (json) => json,
          cancelToken: cancel,
        ),
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final success = data['success'] ?? false;
          final ordersData = data['data'];

          if (success && ordersData is List) {
            // remember Return the response EXACTLY as ListViewPagination expects it
            // The PaginationController expects response.data to be a List, not a Map
            return ResponseModel(
              statusCode: 200,
              success: true,
              data: ordersData,

              /// here we Return the orders list directly :D
              message: response.message,
            );
          }
        }
      }

      return response;
    } catch (e) {
      print('Error fetching orders page $page: $e');
      rethrow;
    }
  }

  Map<String, dynamic> formatOrderForPager(Map<String, dynamic> apiOrderData) {
    try {
      final formattedOrder = {
        'id': _safeToString(apiOrderData['id']),
        'apiData': apiOrderData,
        'requesterName': _buildCustomerName(apiOrderData),
        'location': _extractLocation(apiOrderData),
        'date': _formatOrderDate(apiOrderData),
        'time': _formatOrderTime(apiOrderData),
        'duration': _calculateTimeSinceCreated(apiOrderData),
        'status': _safeToString(apiOrderData['status'], 'waiting'),
        'hasCloseButton': true,
        'categoryTitle': _extractCategoryTitle(apiOrderData),
        'subcategoryTitle': _extractCategoryTitle(apiOrderData),
        'description': _safeToString(apiOrderData['description'], 'Service request'),
        'minPrice': _parsePrice(apiOrderData['min_price']),
        'maxPrice': _parsePrice(apiOrderData['max_price']),
        'orderType': _safeToString(apiOrderData['type'], 'immediately'),
      };

      return formattedOrder;
    } catch (e) {
      print(' Error formatting order: $e');

      rethrow;
    }
  }

  String _calculateTimeSinceCreated(Map<String, dynamic> apiOrderData) {
    try {
      final createdAtString = _safeToString(apiOrderData['created_at']);

      if (createdAtString.isEmpty) {
        return 'Just now';
      }

      final createdAt = DateTime.parse(createdAtString);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        final days = difference.inDays;
        return days == 1 ? '1 day ago' : '$days days ago';
      } else if (difference.inHours > 0) {
        final hours = difference.inHours;
        return hours == 1 ? '1 hour ago' : '$hours hours ago';
      } else if (difference.inMinutes > 0) {
        final minutes = difference.inMinutes;
        return minutes == 1 ? '1 min ago' : '$minutes mins ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      print(' Error calculating time since created: $e');
      return 'Recently';
    }
  }

  String _safeToString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _buildCustomerName(Map<String, dynamic> apiOrderData) {
    try {
      final customer = apiOrderData['customer'];
      if (customer == null || customer is! Map<String, dynamic>) {
        return 'Name of the services requester';
      }

      final firstName = _safeToString(customer['first_name']);
      final lastName = _safeToString(customer['last_name']);

      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName';
      } else if (firstName.isNotEmpty) {
        return firstName;
      } else if (lastName.isNotEmpty) {
        return lastName;
      } else {
        final phone = _safeToString(customer['phone']);
        if (phone.length >= 4) {
          return 'Customer ${phone.substring(phone.length - 4)}';
        }
        return 'Name of the services requester';
      }
    } catch (e) {
      print(' Error building customer name: $e');
      return 'Name of the services requester';
    }
  }

  String _extractLocation(Map<String, dynamic> apiOrderData) {
    try {
      final address = apiOrderData['address'];
      if (address == null || address is! Map<String, dynamic>) {
        return 'Location not specified';
      }

      final title = _safeToString(address['title']);
      final addressStr = _safeToString(address['address']);

      if (title.isNotEmpty) {
        return title;
      } else if (addressStr.isNotEmpty) {
        return addressStr;
      } else {
        return 'Location not specified';
      }
    } catch (e) {
      print(' Error extracting location: $e');
      return 'Location not specified';
    }
  }

  String _extractCategoryTitle(Map<String, dynamic> apiOrderData) {
    try {
      final category = apiOrderData['category'];
      if (category == null || category is! Map<String, dynamic>) {
        return 'Service Request';
      }
      return _safeToString(category['title'], 'Service Request');
    } catch (e) {
      print('Error extracting category: $e');
      return 'Service Request';
    }
  }

  String _formatOrderDate(Map<String, dynamic> apiOrderData) {
    try {
      final createdAt = _safeToString(apiOrderData['created_at']);
      if (createdAt.isEmpty) return 'Today';

      final date = DateTime.parse(createdAt);
      return '${date.day} - ${_getWeekdayAbbr(date.weekday)} - ${date.year}';
    } catch (e) {
      print(' Error formatting date: $e');
      return 'Today';
    }
  }

  String _formatOrderTime(Map<String, dynamic> apiOrderData) {
    try {
      final createdAt = _safeToString(apiOrderData['created_at']);
      if (createdAt.isEmpty) return '12:00 PM';

      final date = DateTime.parse(createdAt);
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      print(' Error formatting time: $e');
      return '12:00 PM';
    }
  }

  String _getWeekdayAbbr(int weekday) {
    try {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (weekday >= 1 && weekday <= 7) {
        return weekdays[weekday - 1];
      }
      return 'Today';
    } catch (e) {
      print(' Error getting weekday abbreviation: $e');
      return 'Today';
    }
  }

  int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.round();
    if (price is String) {
      return int.tryParse(price) ?? 0;
    }
    return 0;
  }

  void viewOrderDetails(String orderId) {
    try {
      // Pass just the order ID to the details page
      Get.toNamed(Pages.view_order_detail.value, arguments: {'orderId': orderId});
    } catch (e) {
      print(' Error viewing order details: $e');
      PopUpToast.show('Unable to view order details');
    }
  }

  void onNotificationTap() {
    PopUpToast.show('Notifications tapped');
  }

  void onFilterOrdersTap() {
    PopUpToast.show('Filter orders tapped');
  }
}
