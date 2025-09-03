import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
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
      // Set fallback data with translations
      providerInfo.value = {
        'name': tr(LocaleKeys.provider_home_provider_name_fallback),
        'category': tr(LocaleKeys.provider_home_service_provider_fallback),
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
            'name':
                providerData['name'] ??
                userData['first_name'] ??
                tr(LocaleKeys.provider_home_provider_name_fallback),
            'category': _extractCategoryFromProvider(providerData),
            'rating': (providerData['rate'] ?? 0.0).toDouble(),
            'avatar': _extractAvatarFromProvider(providerData),
            'status': providerData['status'] ?? 'Approved',
          };
        } else {
          // Use user data as fallback
          providerInfo.value = {
            'name': userData['first_name'] ?? tr(LocaleKeys.provider_home_provider_name_fallback),
            'category': tr(LocaleKeys.provider_home_service_provider_fallback),
            'rating': 0.0,
            'avatar': userData['avatar']?['original_url'],
            'status': 'Pending',
          };
        }
      } else {
        throw Exception('API call failed: ${response.message}');
      }
    } catch (e) {
      print('Error fetching from API: $e');
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
      return tr(LocaleKeys.provider_home_service_provider_fallback);
    } catch (e) {
      print('Error extracting category: $e');
      return tr(LocaleKeys.provider_home_service_provider_fallback);
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
            return ResponseModel(
              statusCode: 200,
              success: true,
              data: ordersData,
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
        'description': _safeToString(
          apiOrderData['description'],
          tr(LocaleKeys.provider_home_service_request_fallback),
        ),
        'minPrice': _parsePrice(apiOrderData['min_price']),
        'maxPrice': _parsePrice(apiOrderData['max_price']),
        'orderType': _safeToString(apiOrderData['type'], 'immediately'),
      };

      return formattedOrder;
    } catch (e) {
      print('Error formatting order: $e');
      rethrow;
    }
  }

  String _calculateTimeSinceCreated(Map<String, dynamic> apiOrderData) {
    try {
      final createdAtString = _safeToString(apiOrderData['created_at']);

      if (createdAtString.isEmpty) {
        return tr(LocaleKeys.provider_home_just_now);
      }

      final createdAt = DateTime.parse(createdAtString);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        final days = difference.inDays;
        return days == 1
            ? '1 ${tr(LocaleKeys.provider_home_day_ago)}'
            : '$days ${tr(LocaleKeys.provider_home_days_ago)}';
      } else if (difference.inHours > 0) {
        final hours = difference.inHours;
        return hours == 1
            ? '1 ${tr(LocaleKeys.provider_home_hour_ago)}'
            : '$hours ${tr(LocaleKeys.provider_home_hours_ago)}';
      } else if (difference.inMinutes > 0) {
        final minutes = difference.inMinutes;
        return minutes == 1
            ? '1 ${tr(LocaleKeys.provider_home_min_ago)}'
            : '$minutes ${tr(LocaleKeys.provider_home_mins_ago)}';
      } else {
        return tr(LocaleKeys.provider_home_just_now);
      }
    } catch (e) {
      print('Error calculating time since created: $e');
      return tr(LocaleKeys.provider_home_recently);
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
        return tr(LocaleKeys.provider_home_name_of_services_requester);
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
          return '${tr(LocaleKeys.provider_home_customer_prefix)} ${phone.substring(phone.length - 4)}';
        }
        return tr(LocaleKeys.provider_home_name_of_services_requester);
      }
    } catch (e) {
      print('Error building customer name: $e');
      return tr(LocaleKeys.provider_home_name_of_services_requester);
    }
  }

  String _extractLocation(Map<String, dynamic> apiOrderData) {
    try {
      final address = apiOrderData['address'];
      if (address == null || address is! Map<String, dynamic>) {
        return tr(LocaleKeys.provider_home_location_not_specified);
      }

      final title = _safeToString(address['title']);
      final addressStr = _safeToString(address['address']);

      if (title.isNotEmpty) {
        return title;
      } else if (addressStr.isNotEmpty) {
        return addressStr;
      } else {
        return tr(LocaleKeys.provider_home_location_not_specified);
      }
    } catch (e) {
      print('Error extracting location: $e');
      return tr(LocaleKeys.provider_home_location_not_specified);
    }
  }

  String _extractCategoryTitle(Map<String, dynamic> apiOrderData) {
    try {
      final category = apiOrderData['category'];
      if (category == null || category is! Map<String, dynamic>) {
        return tr(LocaleKeys.provider_home_service_request_fallback);
      }
      return _safeToString(
        category['title'],
        tr(LocaleKeys.provider_home_service_request_fallback),
      );
    } catch (e) {
      print('Error extracting category: $e');
      return tr(LocaleKeys.provider_home_service_request_fallback);
    }
  }

  String _formatOrderDate(Map<String, dynamic> apiOrderData) {
    try {
      final createdAt = _safeToString(apiOrderData['created_at']);
      if (createdAt.isEmpty) return tr(LocaleKeys.provider_home_today);

      final date = DateTime.parse(createdAt);
      return '${date.day} - ${_getLocalizedWeekdayAbbr(date.weekday)} - ${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return tr(LocaleKeys.provider_home_today);
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
      print('Error formatting time: $e');
      return '12:00 PM';
    }
  }

  String _getLocalizedWeekdayAbbr(int weekday) {
    try {
      const weekdayKeys = [
        LocaleKeys.provider_home_monday, // 1
        LocaleKeys.provider_home_tuesday, // 2
        LocaleKeys.provider_home_wednesday, // 3
        LocaleKeys.provider_home_thursday, // 4
        LocaleKeys.provider_home_friday, // 5
        LocaleKeys.provider_home_saturday, // 6
        LocaleKeys.provider_home_sunday, // 7
      ];

      if (weekday >= 1 && weekday <= 7) {
        return tr(weekdayKeys[weekday - 1]);
      }
      return tr(LocaleKeys.provider_home_today);
    } catch (e) {
      print('Error getting weekday abbreviation: $e');
      return tr(LocaleKeys.provider_home_today);
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
      Get.toNamed(Pages.view_order_detail.value, arguments: {'orderId': orderId});
    } catch (e) {
      print('Error viewing order details: $e');
      PopUpToast.show(tr(LocaleKeys.provider_home_unable_to_view_order_details));
    }
  }

  void onNotificationTap() {
    PopUpToast.show(tr(LocaleKeys.provider_home_notifications_tapped));
  }

  void onFilterOrdersTap() {
    PopUpToast.show(tr(LocaleKeys.provider_home_filter_orders_tapped));
  }
}
