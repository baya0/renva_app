import 'dart:io';

import 'package:flutter/material.dart';

// Address Model
class AddressModel {
  final String? title;
  final String? city;
  final String? postalCode;
  final String? latitude;
  final String? longitude;

  AddressModel({this.title, this.city, this.postalCode, this.latitude, this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      title: json['title'],
      city: json['city'],
      postalCode: json['postal_code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class CreateOrderModel {
  final int mainCategoryId;
  final int categoryId;
  final String description;
  final String type; // "none_immediately" or "immediately"
  final String minPrice;
  final String maxPrice;
  final String? date; // Format: "2024-11-23"
  final String? startAt; // Format: "09:00:00"
  final String? endAt;
  final List<File>? photos;
  final AddressModel? address;

  CreateOrderModel({
    required this.mainCategoryId,
    required this.categoryId,
    required this.description,
    required this.type,
    required this.minPrice,
    required this.maxPrice,
    this.date,
    this.startAt,
    this.endAt,
    this.photos,
    this.address,
  });

  factory CreateOrderModel.fromFormData({
    required int mainCategoryId,
    required int categoryId,
    required String description,
    required bool isImmediate,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    required int minPrice,
    required int maxPrice,
    List<File>? photos,
    AddressModel? address,
  }) {
    String type = isImmediate ? 'immediately' : 'none_immediately';
    String? dateStr;
    String? timeStr;

    if (!isImmediate && scheduledDate != null) {
      dateStr =
          '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';

      if (scheduledTime != null) {
        timeStr =
            '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}:00';
      }
    }

    return CreateOrderModel(
      mainCategoryId: mainCategoryId,
      categoryId: categoryId,
      description: description,
      type: type,
      minPrice: minPrice.toString(),
      maxPrice: maxPrice.toString(),
      date: dateStr,
      startAt: timeStr,
      photos: photos,
      address: address,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'main_category_id': mainCategoryId,
      'category_id': categoryId,
      'description': description,
      'type': type,
      'min_price': minPrice,
      'max_price': maxPrice,
    };

    if (date != null) json['date'] = date!;
    if (startAt != null) json['start_at'] = startAt!;
    if (endAt != null) json['end_at'] = endAt!;
    if (address != null) json['address'] = address!.toJson();

    return json;
  }
}

// Order Response Model
class OrderResponseModel {
  final int id;
  final String? status;
  final String? cancelReason;
  final String? deleteReason;
  final CategoryModel mainCategory;
  final CategoryModel category;
  final String description;
  final AddressResponseModel address;
  final String date;
  final String? startAt;
  final String? endAt;
  final String type;
  final String minPrice;
  final String maxPrice;
  final int viewerCount;
  final int offerCount;
  final String createdAt;
  final ProviderModel? provider;

  final List<GalleryItemModel> gallery;
  final List<ProviderModel> offeredProviders;
  final CustomerModel customer;

  OrderResponseModel({
    required this.id,
    this.status,
    this.cancelReason,
    this.deleteReason,
    required this.mainCategory,
    required this.category,
    required this.description,
    required this.address,
    required this.date,
    this.startAt,
    this.endAt,
    required this.type,
    required this.minPrice,
    required this.maxPrice,
    required this.viewerCount,
    required this.offerCount,
    required this.createdAt,
    this.provider,
    required this.gallery,
    required this.offeredProviders,
    required this.customer,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      id: json['id'],
      status: json['status'],
      cancelReason: json['cancel_reason'],
      mainCategory: CategoryModel.fromJson(json['mainCategory']),
      category: CategoryModel.fromJson(json['category']),
      description: json['description'],
      address: AddressResponseModel.fromJson(json['address']),
      date: json['date'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      type: json['type'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      viewerCount: json['viewer_cnt'],
      offerCount: json['offer_cnt'],
      createdAt: json['created_at'],
      provider: json['provider'] != null ? ProviderModel.fromJson(json['provider']) : null,
      gallery: (json['gallery'] as List).map((item) => GalleryItemModel.fromJson(item)).toList(),
      offeredProviders:
          (json['offeredProviders'] as List)
              .map((provider) => ProviderModel.fromJson(provider))
              .toList(),
      customer: CustomerModel.fromJson(json['customer']),
    );
  }
}

// Supporting Models
class CategoryModel {
  final int id;
  final String title;
  final String? svg;
  final int minPrice;
  final int maxPrice;
  final String? description;
  final int prvCount;

  CategoryModel({
    required this.id,
    required this.title,
    this.svg,
    required this.minPrice,
    required this.maxPrice,
    this.description,
    required this.prvCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle description field which can be either String or List
    String? description;
    if (json['description'] != null) {
      if (json['description'] is List) {
        // If it's a list, take the first element or join them
        final descList = json['description'] as List;
        description = descList.isNotEmpty ? descList.first?.toString() : null;
      } else if (json['description'] is String) {
        description = json['description'] as String;
      }
    }

    return CategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      svg: json['svg'],
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 0,
      description: description,
      prvCount: json['prv_cnt'] ?? 0,
    );
  }
}

class AddressResponseModel {
  final int id;
  final String? title;
  final String? latitude;
  final String? longitude;

  AddressResponseModel({required this.id, this.title, this.latitude, this.longitude});

  factory AddressResponseModel.fromJson(Map<String, dynamic> json) {
    return AddressResponseModel(
      id: json['id'],
      title: json['title'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class ProviderModel {
  final int id;
  final String name;
  final String description;
  final String dialCountryCode;
  final String phone;
  final String email;
  final String? gender;
  final int userId;
  final GalleryItemModel avatar;
  final List<GalleryItemModel> gallery;
  final List<CategoryModel> categories;
  final double rate;
  final String startAt;
  final String endAt;
  final List<ReviewModel> reviews;
  final double balance;
  final AddressResponseModel address;
  final int canHaveAChat;

  ProviderModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dialCountryCode,
    required this.phone,
    required this.email,
    this.gender,
    required this.userId,
    required this.avatar,
    required this.gallery,
    required this.categories,
    required this.rate,
    required this.startAt,
    required this.endAt,
    required this.reviews,
    required this.balance,
    required this.address,
    required this.canHaveAChat,
  });

  // Replace the entire ProviderModel.fromJson method in order.dart with this corrected version

  // Replace the ProviderModel.fromJson method in order.dart with this final version

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    print('🔍 ProviderModel.fromJson - Input: ${json.keys}');

    try {
      final provider = ProviderModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Provider',
        description: json['description'] ?? '',
        dialCountryCode: json['dial_country_code'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        gender: json['gender'],
        userId: json['user_id'] ?? 0,

        // Handle avatar
        avatar:
            json['avatar'] != null
                ? GalleryItemModel.fromJson(json['avatar'])
                : GalleryItemModel(
                  uuid: '',
                  originalUrl: '',
                  mediumUrl: '',
                  smallUrl: '',
                  thumbUrl: '',
                ),

        // Handle gallery array
        gallery:
            json['gallery'] != null
                ? (json['gallery'] as List).map((item) => GalleryItemModel.fromJson(item)).toList()
                : [],

        // Handle categories array
        categories:
            json['categories'] != null
                ? (json['categories'] as List).map((cat) => CategoryModel.fromJson(cat)).toList()
                : [],

        rate: (json['rate'] ?? 0).toDouble(),
        startAt: json['start_at'] ?? '',
        endAt: json['end_at'] ?? '',

        // Empty reviews since API structure is different
        reviews: [],

        balance: (json['balance'] ?? 0).toDouble(),

        // Handle address
        address:
            json['address'] != null
                ? AddressResponseModel.fromJson(json['address'])
                : AddressResponseModel(id: 0, title: null, latitude: null, longitude: null),

        canHaveAChat: json['can_have_a_chat'] ?? 0,
      );

      print('✅ ProviderModel created: ${provider.name}');
      return provider;
    } catch (e) {
      print('💥 ProviderModel.fromJson error: $e');
      print('🔍 JSON: $json');
      rethrow;
    }
  }
}

class CustomerModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String nationalId;
  final String dialCountryCode;
  final String phone;
  final String? phoneVerifiedAt;
  final int isCompleted;
  final GenderModel gender;
  final GalleryItemModel avatar;
  final GalleryItemModel idCard;
  final List<AddressResponseModel> addresses;
  final int providerId;
  final double providerRate;
  final int isApproved;
  final double balance;
  final ProviderModel provider;
  final int customerId;
  final double rate;
  final int ordersCount;
  final int points;
  final int pointsInSp;

  CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nationalId,
    required this.dialCountryCode,
    required this.phone,
    this.phoneVerifiedAt,
    required this.isCompleted,
    required this.gender,
    required this.avatar,
    required this.idCard,
    required this.addresses,
    required this.providerId,
    required this.providerRate,
    required this.isApproved,
    required this.balance,
    required this.provider,
    required this.customerId,
    required this.rate,
    required this.ordersCount,
    required this.points,
    required this.pointsInSp,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      nationalId: json['nationalID'],
      dialCountryCode: json['dial_country_code'],
      phone: json['phone'],
      phoneVerifiedAt: json['phone_verified_at'],
      isCompleted: json['is_completed'],
      gender: GenderModel.fromJson(json['gender']),
      avatar: GalleryItemModel.fromJson(json['avatar']),
      idCard: GalleryItemModel.fromJson(json['IDcard']),
      addresses:
          (json['addresses'] as List).map((addr) => AddressResponseModel.fromJson(addr)).toList(),
      providerId: json['provider_id'],
      providerRate: (json['provider_rate'] as num).toDouble(),
      isApproved: json['is_approved'],
      balance: (json['balance'] as num).toDouble(),
      provider: ProviderModel.fromJson(json['provider']),
      customerId: json['customer_id'],
      rate: (json['rate'] as num).toDouble(),
      ordersCount: json['orders_cnt'],
      points: json['points'],
      pointsInSp: json['points_in_sp'],
    );
  }
}

class GenderModel {
  final int id;
  final String name;

  GenderModel({required this.id, required this.name});

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(id: json['id'], name: json['name']);
  }
}

class GalleryItemModel {
  final String uuid;
  final String originalUrl;
  final String mediumUrl;
  final String smallUrl;
  final String thumbUrl;

  GalleryItemModel({
    required this.uuid,
    required this.originalUrl,
    required this.mediumUrl,
    required this.smallUrl,
    required this.thumbUrl,
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    return GalleryItemModel(
      uuid: json['uuid'],
      originalUrl: json['original_url'],
      mediumUrl: json['medium_url'],
      smallUrl: json['small_url'],
      thumbUrl: json['thumb_url'],
    );
  }
}

class ReviewModel {
  final int id;
  final String comment;
  final double rating;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      comment: json['comment'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class TransactionModel {
  final int id;
  final String amount;
  final String status;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

class MentionModel {
  final int id;
  final String text;

  MentionModel({required this.id, required this.text});

  factory MentionModel.fromJson(Map<String, dynamic> json) {
    return MentionModel(id: json['id'], text: json['text']);
  }
}

enum OrderStatus {
  pending,
  underway,
  complete,
  cancelled;

  String get apiStatus {
    switch (this) {
      case OrderStatus.pending:
        return 'waiting';
      case OrderStatus.underway:
        return 'processing';
      case OrderStatus.complete:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
      case 'underway':
        return OrderStatus.underway;
      case 'completed':
      case 'complete':
        return OrderStatus.complete;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
