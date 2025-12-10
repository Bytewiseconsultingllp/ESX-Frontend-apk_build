import 'package:esx/features/product/models/product_model.dart';

class UserBid {
  final String id;
  final String productId;
  final String userId;
  final double totalAmount;
  final double advanceAmount;
  final String bidStatus;
  final int quantity;
  final double pricePerUnit;
  final DateTime createdAt;

  UserBid({
    required this.id,
    required this.productId,
    required this.userId,
    required this.totalAmount,
    required this.advanceAmount,
    required this.bidStatus,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
  });

  factory UserBid.fromJson(Map<String, dynamic> json) {
    return UserBid(
      id: json['_id'],
      productId: json['productId'],
      userId: json['userId'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      advanceAmount: (json['advanceAmount'] as num).toDouble(),
      bidStatus: json['bidStatus'],
      quantity: json['quantity'],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'productId': productId,
        'userId': userId,
        'totalAmount': totalAmount,
        'advanceAmount': advanceAmount,
        'bidStatus': bidStatus,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ProductWithBidStatus {
  final Product product;
  final UserBid? userBid;
  final bool isBiddedByUser;

  ProductWithBidStatus({
    required this.product,
    this.userBid,
  }) : isBiddedByUser = userBid != null;

  factory ProductWithBidStatus.fromJson(Map<String, dynamic> json) {
    return ProductWithBidStatus(
      product: Product.fromJson(json['product']),
      userBid:
          (json['userBid'] != null) ? UserBid.fromJson(json['userBid']) : null,
    );
  }
}
