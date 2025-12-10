// models/order_model.dart
class Order {
  final String? name;
  final String id;
  final String userId;
  final String productId;
  final double totalAmount;
  final double advanceAmount;
  final String deliveryStatus;
  final String orderStatus;
  final String expectedDeliveryTime;
  final String deliveryAddress;
  final DateTime createdAt;
  final String? invoiceUrl;
  final String? shipmentProvider;
  final String? imageUrl;

  Order({
    this.name,
    required this.id,
    required this.userId,
    required this.productId,
    required this.totalAmount,
    required this.advanceAmount,
    required this.deliveryStatus,
    required this.orderStatus,
    required this.expectedDeliveryTime,
    required this.deliveryAddress,
    required this.createdAt,
    this.invoiceUrl,
    this.shipmentProvider,
    this.imageUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      name: json['name'] ?? '',
      id: json['_id'],
      userId: json['userId'],
      productId: json['productId'],
      totalAmount: json['totalAmount'].toDouble(),
      advanceAmount: json['advanceAmount'].toDouble(),
      deliveryStatus: json['deliveryStatus'],
      orderStatus: json['orderStatus'],
      expectedDeliveryTime: json['expectedDeliveryTime'],
      deliveryAddress: json['deliveryAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      invoiceUrl: json['invoiceUrl'],
      shipmentProvider: json['shipmentProvider'],
      imageUrl: json['imageUrl'],
    );
  }
}
