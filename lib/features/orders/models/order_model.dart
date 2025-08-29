import '../../add_orders/models/order.dart';

class OrderModel {
  final String id;
  final String serviceCategory;
  final String serviceSubcategory;
  final String description;
  final String location;
  final DateTime dateTime;
  final OrderStatus status;
  final String? serviceIcon;
  final String? cancelReason;
  final String? deleteReason;
  final int? offerCount;
  final int? viewerCount;
  final String? minPrice;
  final String? maxPrice;
  final ProviderModel? provider;
  final String? customerRating;
  final int? customerStarRating;
  final String? providerRating;
  final int? providerStarRating;

  OrderModel({
    required this.id,
    required this.serviceCategory,
    required this.serviceSubcategory,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.status,
    this.serviceIcon,
    this.cancelReason,
    this.deleteReason,
    this.offerCount,
    this.viewerCount,
    this.minPrice,
    this.maxPrice,
    this.provider,
    this.customerRating,
    this.customerStarRating,
    this.providerRating,
    this.providerStarRating,
  });

  factory OrderModel.fromOrderResponse(OrderResponseModel orderResponse) {
    return OrderModel(
      id: orderResponse.id.toString(),
      serviceCategory: orderResponse.mainCategory.title,
      serviceSubcategory: orderResponse.category.title,
      description: orderResponse.description,
      location: orderResponse.address.title ?? 'Unknown Location',
      dateTime: DateTime.tryParse(orderResponse.createdAt) ?? DateTime.now(),
      status: OrderStatus.fromString(orderResponse.status),
      serviceIcon: orderResponse.mainCategory.svg,
      cancelReason: orderResponse.cancelReason,
      deleteReason: orderResponse.deleteReason,
      offerCount: orderResponse.offerCount,
      viewerCount: orderResponse.viewerCount,
      minPrice: orderResponse.minPrice,
      maxPrice: orderResponse.maxPrice,
      provider: orderResponse.provider,
    );
  }

  factory OrderModel.fromApiResponse(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.tryParse(json['created_at']) ?? DateTime.now();

    ProviderModel? provider;
    try {
      if (json['provider'] != null) {
        provider = ProviderModel.fromJson(json['provider']);
      } else {}
    } catch (e) {
      provider = null;
    }

    final orderModel = OrderModel(
      id: json['id'].toString(),
      serviceCategory: json['mainCategory']?['title'] ?? 'Unknown Service',
      serviceSubcategory: json['category']?['title'] ?? 'Unknown Subcategory',
      description: json['description'] ?? 'No description',
      location: json['address']?['title'] ?? 'Unknown Location',
      dateTime: dateTime,
      status: OrderStatus.fromString(json['status']),
      serviceIcon: json['mainCategory']?['svg'],
      cancelReason: json['cancel_reason'],
      deleteReason: json['delete_reason'],
      offerCount: json['offer_cnt'],
      viewerCount: json['viewer_cnt'],
      minPrice: json['min_price']?.toString(),
      maxPrice: json['max_price']?.toString(),
      provider: provider,
      customerRating: json['customer_review']?['comment'],
      customerStarRating: json['customer_review']?['rating']?.round(),
      providerRating: json['provider_review']?['comment'],
      providerStarRating: json['provider_review']?['rating']?.round(),
    );

    return orderModel;
  }
  String? get providerName => provider?.name;
  String? get providerAvatarUrl => provider?.avatar.mediumUrl;
  bool get hasCustomerRating =>
      (customerRating != null && customerRating!.isNotEmpty) ||
      (customerStarRating != null && customerStarRating! > 0);
  bool get hasProviderRating => providerRating != null && providerRating!.isNotEmpty;
}

class CancelReasonModel {
  final int id;
  final String reasonText;
  final String? type; // customer, provider, or both :)
  final bool isActive;

  CancelReasonModel({required this.id, required this.reasonText, this.type, this.isActive = true});

  factory CancelReasonModel.fromJson(Map<String, dynamic> json) {
    return CancelReasonModel(
      id: json['id'] ?? 0,
      reasonText: json['reason_text'] ?? '',
      type: json['type'],
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == null,
    );
  }

  // Helper getter for display
  String get displayText => reasonText;

  // Helper to check if this reason is for customers
  bool get isCustomerReason => type == null || type == 'customer' || type == 'both';

  // Helper to check if this reason is for providers
  bool get isProviderReason => type == null || type == 'provider' || type == 'both';

  @override
  String toString() {
    return 'CancelReasonModel(id: $id, reasonText: $reasonText, type: $type)';
  }
}
