class ProviderOrderModel {
  final int id;
  final String status;
  final Map<String, dynamic>? cancelReason;
  final String? cancelledBy;
  final Map<String, dynamic> mainCategory;
  final Map<String, dynamic> category;
  final String description;
  final Map<String, dynamic> address;
  final String date;
  final String? startAt;
  final String? endAt;
  final String type;
  final List<Map<String, dynamic>> gallery;
  final ProviderOfferModel? providerOffer;
  final String minPrice;
  final String maxPrice;
  final int viewerCnt;
  final int offerCnt;
  final String createdAt;
  final List<dynamic> tags;
  final Map<String, dynamic>? transaction;
  final List<dynamic> mentions;
  final Map<String, dynamic>? review;
  final Map<String, dynamic>? providerReview;
  final double rate;
  final Map<String, dynamic> customer;
  final Map<String, dynamic>? provider;

  ProviderOrderModel({
    required this.id,
    required this.status,
    this.cancelReason,
    this.cancelledBy,
    required this.mainCategory,
    required this.category,
    required this.description,
    required this.address,
    required this.date,
    this.startAt,
    this.endAt,
    required this.type,
    required this.gallery,
    this.providerOffer,
    required this.minPrice,
    required this.maxPrice,
    required this.viewerCnt,
    required this.offerCnt,
    required this.createdAt,
    required this.tags,
    this.transaction,
    required this.mentions,
    this.review,
    this.providerReview,
    required this.rate,
    required this.customer,
    this.provider,
  });

  factory ProviderOrderModel.fromJson(Map<String, dynamic> json) {
    return ProviderOrderModel(
      id: json['id'],
      status: json['status'] ?? '',
      cancelReason: json['cancel_reason'],
      cancelledBy: json['cancelled_by'],
      mainCategory: json['mainCategory'] ?? {},
      category: json['category'] ?? {},
      description: json['description'] ?? '',
      address: json['address'] ?? {},
      date: json['date'] ?? '',
      startAt: json['start_at'],
      endAt: json['end_at'],
      type: json['type'] ?? '',
      gallery: List<Map<String, dynamic>>.from(json['gallery'] ?? []),
      providerOffer:
          json['provider_offer'] != null
              ? ProviderOfferModel.fromJson(json['provider_offer'])
              : null,
      minPrice: json['min_price']?.toString() ?? '0',
      maxPrice: json['max_price']?.toString() ?? '0',
      viewerCnt: json['viewer_cnt'] ?? 0,
      offerCnt: json['offer_cnt'] ?? 0,
      createdAt: json['created_at'] ?? '',
      tags: json['tags'] ?? [],
      transaction: json['transaction'],
      mentions: json['mentions'] ?? [],
      review: json['review'],
      providerReview: json['provider_review'],
      rate: (json['rate'] ?? 0).toDouble(),
      customer: json['customer'] ?? {},
      provider: json['provider'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'cancel_reason': cancelReason,
      'cancelled_by': cancelledBy,
      'mainCategory': mainCategory,
      'category': category,
      'description': description,
      'address': address,
      'date': date,
      'start_at': startAt,
      'end_at': endAt,
      'type': type,
      'gallery': gallery,
      'provider_offer': providerOffer?.toJson(),
      'min_price': minPrice,
      'max_price': maxPrice,
      'viewer_cnt': viewerCnt,
      'offer_cnt': offerCnt,
      'created_at': createdAt,
      'tags': tags,
      'transaction': transaction,
      'mentions': mentions,
      'review': review,
      'provider_review': providerReview,
      'rate': rate,
      'customer': customer,
      'provider': provider,
    };
  }

  String getProviderOrderStatus() {
    // ✅ Map API statuses to frontend statuses based on documentation:
    // API: waiting, processing, cancelled, completed
    // Frontend: pending, underway, cancelled, completed

    // First check if order is completed or cancelled
    if (status == 'completed') return 'completed';
    if (status == 'cancelled') return 'cancelled';

    // ✅ For provider view, only show orders where provider has made an offer
    if (providerOffer == null) {
      return 'no_offer';
    }

    // ✅ Map API statuses to frontend statuses
    switch (providerOffer!.status) {
      case 'waiting': // API status for pending offers
        return 'pending'; // Frontend status for Pending tab
      case 'processing': // API status for accepted/in-progress offers
        return 'underway'; // Frontend status for Underway tab
      case 'completed':
        return 'completed'; // Completed orders
      case 'cancelled':
      case 'declined':
        return 'cancelled'; // Cancelled/declined orders
      default:
        // Fallback: if order status is waiting, show as pending
        if (status == 'waiting') return 'pending';
        if (status == 'processing') return 'underway';
        return 'pending';
    }
  }

  // Check if order can be completed by provider
  bool get canComplete {
    return providerOffer != null && providerOffer!.status == 'accepted' && status == 'processing';
  }

  // Helper getters for better readability
  String get customerName {
    final firstName = customer['first_name'] ?? '';
    final lastName = customer['last_name'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String get categoryTitle => category['title'] ?? 'Service Request';

  String get mainCategoryTitle => mainCategory['title'] ?? 'Service';

  String get addressTitle => address['title'] ?? 'Unknown Location';

  bool get hasOffer => providerOffer != null;

  String get offerPrice => providerOffer?.price ?? '0';

  String get offerStatus => providerOffer?.status ?? 'none';

  // ✅ Add helper getters for cancel reason
  String get cancelReasonText {
    if (cancelReason == null) return '';
    return cancelReason!['reason_text']?.toString() ?? '';
  }

  int? get cancelReasonId {
    if (cancelReason == null) return null;
    return cancelReason!['id'];
  }

  bool get isCancelled => status == 'cancelled';
}

class ProviderOfferModel {
  final int id;
  final String description;
  final String price;
  final String time;
  final String timeType;
  final String status;
  final String paymentStatus;
  final String? declineReason;
  final Map<String, dynamic> provider;
  final int orderId;
  final List<Map<String, dynamic>> gallery;
  final String createdAt;

  ProviderOfferModel({
    required this.id,
    required this.description,
    required this.price,
    required this.time,
    required this.timeType,
    required this.status,
    required this.paymentStatus,
    this.declineReason,
    required this.provider,
    required this.orderId,
    required this.gallery,
    required this.createdAt,
  });

  factory ProviderOfferModel.fromJson(Map<String, dynamic> json) {
    return ProviderOfferModel(
      id: json['id'],
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      time: json['time']?.toString() ?? '0',
      timeType: json['time_type'] ?? 'hour',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      declineReason: json['decline_reason'],
      provider: json['provider'] ?? {},
      orderId: json['order_id'] ?? 0,
      gallery: List<Map<String, dynamic>>.from(json['gallery'] ?? []),
      createdAt: json['created_at'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'price': price,
      'time': time,
      'time_type': timeType,
      'status': status,
      'payment_status': paymentStatus,
      'decline_reason': declineReason,
      'provider': provider,
      'order_id': orderId,
      'gallery': gallery,
      'created_at': createdAt,
    };
  }

  // Helper getters
  bool get isPending => status == 'waiting';
  bool get isAccepted => status == 'processing';
  bool get isDeclined => status == 'cancelled';

  String get formattedPrice => '\$$price';
  String get timeDisplay => '$time $timeType${time != '1' ? 's' : ''}';
}
