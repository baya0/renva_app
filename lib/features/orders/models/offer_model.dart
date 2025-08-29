class OfferModel {
  final String id;
  final String providerId;
  final String providerName;
  final String? providerImage;
  final double providerRating;
  final int reviewCount;
  final String description;
  final double price;
  final String executionTime;
  final String timeUnit;
  final DateTime createdAt;
  final List<String>? images;
  final String deliveryTime;

  OfferModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    this.providerImage,
    required this.providerRating,
    required this.reviewCount,
    required this.description,
    required this.price,
    required this.executionTime,
    required this.timeUnit,
    required this.createdAt,
    this.images,
    required this.deliveryTime,
  });

  // ✅ CORRECT: Only show offer-specific images, not provider gallery
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    try {
      // Extract provider data safely
      final providerData = json['provider'] as Map<String, dynamic>? ?? {};

      // Extract avatar URL safely
      String? avatarUrl;
      if (providerData['avatar'] != null) {
        final avatar = providerData['avatar'] as Map<String, dynamic>;
        avatarUrl = avatar['medium_url'] ?? avatar['original_url'] ?? avatar['thumb_url'];
      }

      // 🎯 ONLY extract offer-specific gallery images (not provider gallery)
      List<String>? galleryImages;
      if (json['gallery'] != null && (json['gallery'] as List).isNotEmpty) {
        final offerGallery = json['gallery'] as List;
        galleryImages =
            offerGallery
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return item['medium_url'] ?? item['original_url'] ?? '';
                  }
                  return '';
                })
                .where((url) => url.isNotEmpty)
                .cast<String>()
                .toList();
        print('✅ Found ${galleryImages.length} offer images');
      } else {
        print('ℹ️ No offer images found - will hide image section');
      }

      return OfferModel(
        id: json['id'].toString(),
        providerId: providerData['id']?.toString() ?? '0',
        providerName: providerData['name'] ?? 'Unknown Provider',
        providerImage: avatarUrl,
        providerRating: _calculateProviderRating(providerData),
        reviewCount: _getReviewCount(providerData),
        description: json['description'] ?? '',
        price: _parsePrice(json['price']),
        executionTime: json['time']?.toString() ?? '1',
        timeUnit: json['time_type'] ?? 'day',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        images: galleryImages, // Only offer images, null if none
        deliveryTime: _formatDeliveryTime(
          json['time']?.toString() ?? '1',
          json['time_type'] ?? 'day',
        ),
      );
    } catch (e) {
      print('💥 Error parsing OfferModel: $e');
      rethrow;
    }
  }

  // Helper method to safely parse price
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to calculate provider rating
  static double _calculateProviderRating(Map<String, dynamic> providerData) {
    // You can implement actual rating calculation here
    // For now, return a default rating
    return 4.5;
  }

  // Helper method to get review count
  static int _getReviewCount(Map<String, dynamic> providerData) {
    // You can implement actual review count here
    // For now, return a default count
    return 0;
  }

  // Helper method to format delivery time
  static String _formatDeliveryTime(String time, String timeType) {
    try {
      final timeValue = int.tryParse(time) ?? 1;
      switch (timeType.toLowerCase()) {
        case 'hours':
          return timeValue == 1 ? '1 hour' : '$timeValue hours';
        case 'days':
          return timeValue == 1 ? '1 day' : '$timeValue days';
        case 'weeks':
          return timeValue == 1 ? '1 week' : '$timeValue weeks';
        default:
          return '$timeValue $timeType';
      }
    } catch (e) {
      return '1 day';
    }
  }

  // Format offer date method
  String formatOfferDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}';
    }
  }
}
