import 'package:flutter/material.dart';

import '../../../core/style/repo.dart';

class ServiceCategoryModel {
  final int id;
  final String title;
  final String svg;
  final int minPrice;
  final int maxPrice;
  final int prvCnt;
  final List<SubCategoryModel> subCategories;
  final List<String> description;
  final List<Keyword> keywords;

  ServiceCategoryModel({
    required this.id,
    required this.title,
    required this.svg,
    required this.minPrice,
    required this.maxPrice,
    required this.prvCnt,
    required this.subCategories,
    this.description = const [],
    this.keywords = const [],
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      svg: json['svg'] ?? '',
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 0,
      prvCnt: json['prv_cnt'] ?? 0,
      description: json['description'] != null ? List<String>.from(json['description']) : [],
      keywords:
          json['keywords'] != null
              ? (json['keywords'] as List).map((k) => Keyword.fromJson(k)).toList()
              : [],

      subCategories:
          json['subCategories'] != null
              ? (json['subCategories'] as List)
                  .map((subCat) => SubCategoryModel.fromJson(subCat))
                  .toList()
              : <SubCategoryModel>[],
    );
  }

  String get imageUrl => svg.isNotEmpty ? svg : '';
  String get iconUrl => svg;
  String get iconName => title.toLowerCase().replaceAll(' ', '_');

  String get subtitle {
    List<String> parts = [];

    if (subCategories.isNotEmpty) {
      parts.add('${subCategories.length} subcategories');
    }

    if (prvCnt > 0) {
      parts.add('$prvCnt providers');
    }

    if (minPrice > 0 || maxPrice > 0) {
      parts.add('Up to \$${maxPrice > 0 ? maxPrice : minPrice}');
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'Service available';
  }

  bool get hasSubcategories => subCategories.isNotEmpty;

  Color get leftEdgeColor => _getColorForIndex(id);

  static Color _getColorForIndex(int index) {
    final colors = [
      StyleRepo.lightdeepblue,
      StyleRepo.forestGreen,
      StyleRepo.softGreen,
      StyleRepo.lightdeepblue,
      StyleRepo.grey,
    ];
    return colors[(index - 1) % colors.length];
  }
}

class SubCategoryModel {
  final int id;
  final String title;
  final String svg;
  final int minPrice;
  final int maxPrice;
  final int prvCnt;
  final List<String> description;
  final List<Keyword> keywords;

  SubCategoryModel({
    required this.id,
    required this.title,
    required this.svg,
    required this.minPrice,
    required this.maxPrice,
    required this.prvCnt,
    this.description = const [],
    this.keywords = const [],
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      svg: json['svg'] ?? '',
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 0,
      prvCnt: json['prv_cnt'] ?? 0,
      description: json['description'] != null ? List<String>.from(json['description']) : [],
      keywords:
          json['keywords'] != null
              ? (json['keywords'] as List).map((k) => Keyword.fromJson(k)).toList()
              : [],
    );
  }

  String get imageUrl => svg.isNotEmpty ? svg : '';
  String get priceRange =>
      minPrice > 0 || maxPrice > 0 ? '\$$minPrice - \$$maxPrice' : 'Price varies';

  String get providerCountText => prvCnt > 0 ? '$prvCnt providers available' : 'No providers yet';

  String get keywordsText => keywords.isNotEmpty ? keywords.map((k) => k.title).join(', ') : '';

  @override
  String toString() {
    return 'SubCategoryModel(id: $id, title: $title, providers: $prvCnt)';
  }
}

class Keyword {
  final String title;

  Keyword({required this.title});

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(title: json['title'] ?? '');
  }

  @override
  String toString() => title;
}
