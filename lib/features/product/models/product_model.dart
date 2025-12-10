import 'package:flutter/material.dart';

class Product {
  final String id;
  final String productName;
  final String sellerId;
  final String productDescription;
  final int noOfUnit;
  final List<String> productImage;
  final double minPrice;
  final double currentPrice;
  final double maxPrice;
  final int timeRefresh;
  final DateTime biddingDate;
  final bool isSold;
  final bool isPriceFrozen;
  final DateTime? freezeExpiresAt;
  final double? lastBiddedPrice;
  final List<String> category;
  final bool isAvailable;
  final DateTime lastUpdatedAt;
  final DateTime createdAt;
  final Dimensions dimensions;
  final DeliveryDetails deliveryDetails;

  Product({
    required this.id,
    required this.productName,
    required this.sellerId,
    required this.productDescription,
    required this.noOfUnit,
    required this.productImage,
    required this.minPrice,
    required this.currentPrice,
    required this.maxPrice,
    required this.timeRefresh,
    required this.biddingDate,
    required this.isSold,
    required this.isPriceFrozen,
    required this.freezeExpiresAt,
    required this.lastBiddedPrice,
    required this.category,
    required this.isAvailable,
    required this.lastUpdatedAt,
    required this.createdAt,
    required this.dimensions,
    required this.deliveryDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['_id'] ?? '',
        productName: json['productName'] ?? '',
        sellerId: json['sellerId'] ?? '',
        productDescription: json['productDescription'] ?? '',
        noOfUnit: json['noOfUnit'] ?? 0,
        productImage: List<String>.from(json['productImage'] ?? []),
        minPrice: (json['minPrice'] ?? 0).toDouble(),
        currentPrice: (json['currentPrice'] ?? 0).toDouble(),
        maxPrice: (json['maxPrice'] ?? 0).toDouble(),
        timeRefresh: json['timeRefresh'] ?? 0,
        biddingDate:
            DateTime.tryParse(json['biddingDate'] ?? '') ?? DateTime.now(),
        isSold: json['isSold'] ?? false,
        isPriceFrozen: json['isPriceFrozen'] ?? false,
        freezeExpiresAt: json['freezeExpiresAt'] != null
            ? DateTime.tryParse(json['freezeExpiresAt'])
            : null,
        lastBiddedPrice: json['lastBiddedPrice'] != null
            ? (json['lastBiddedPrice']).toDouble()
            : null,
        category: _parseCategory(json['category']),
        isAvailable: json['isAvailable'] ?? true,
        lastUpdatedAt:
            DateTime.tryParse(json['lastUpdatedAt'] ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        dimensions: Dimensions.fromJson(json['dimensions']),
        deliveryDetails: DeliveryDetails.fromJson(json['deliveryDetails']),
      );
    } catch (e) {
      debugPrint('Product parsing failed: $e');
      rethrow;
    }
  }

  static List<String> _parseCategory(dynamic rawCategory) {
    try {
      if (rawCategory is List) {
        return List<String>.from(rawCategory);
      } else if (rawCategory is String) {
        return List<String>.from(List<String>.from(
          (rawCategory.startsWith("["))
              ? List<String>.from(
                  (rawCategory.replaceAll(RegExp(r'[\[\]"]'), '').split(',')))
              : [rawCategory],
        ));
      }
    } catch (_) {}
    return [];
  }

  Product copyWith({
    double? currentPrice,
    double? lastBiddedPrice,
  }) {
    return Product(
      id: id,
      productName: productName,
      sellerId: sellerId,
      productDescription: productDescription,
      noOfUnit: noOfUnit,
      productImage: productImage,
      minPrice: minPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      maxPrice: maxPrice,
      timeRefresh: timeRefresh,
      biddingDate: biddingDate,
      isSold: isSold,
      isPriceFrozen: isPriceFrozen,
      freezeExpiresAt: freezeExpiresAt,
      lastBiddedPrice: lastBiddedPrice ?? this.lastBiddedPrice,
      category: category,
      isAvailable: isAvailable,
      lastUpdatedAt: lastUpdatedAt,
      createdAt: createdAt,
      dimensions: dimensions,
      deliveryDetails: deliveryDetails,
    );
  }
}

class Dimensions {
  final double length;
  final double width;
  final double height;

  Dimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic>? json) {
    return Dimensions(
      length: (json?['length'] ?? 0).toDouble(),
      width: (json?['width'] ?? 0).toDouble(),
      height: (json?['height'] ?? 0).toDouble(),
    );
  }
}

class DeliveryDetails {
  final String shippingTime;
  final double deliveryCharges;
  final List<String> deliveryOptions;

  DeliveryDetails({
    required this.shippingTime,
    required this.deliveryCharges,
    required this.deliveryOptions,
  });

  factory DeliveryDetails.fromJson(Map<String, dynamic>? json) {
    return DeliveryDetails(
      shippingTime:
          (json?['shippingTime'] ?? 'N/A').toString().replaceAll('"', ''),
      deliveryCharges: (json?['deliveryCharges'] ?? 0).toDouble(),
      deliveryOptions: List<String>.from(json?['deliveryOptions'] ?? []),
    );
  }
}
