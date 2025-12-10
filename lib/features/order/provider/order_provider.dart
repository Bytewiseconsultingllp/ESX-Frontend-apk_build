// providers/order_provider.dart
import 'dart:convert';
import 'dart:developer';
import 'package:esx/core/services/url.dart';
import 'package:esx/features/order/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;
  bool isLoading = false;
  String? error;
  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$orderUrl/orders/getOrdersOfUser/$userId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    debugPrint(
        'Fetch Orders URL: ${Uri.parse('$orderUrl/orders/getOrdersOfUser/$userId')}');
    debugPrint('Fetch Orders Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _orders = (data['orders'] as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  Future<void> createOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('$orderUrl/orders/createOrder'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': order.userId,
        'productId': order.productId,
        'totalAmount': order.totalAmount,
        'advanceAmount': order.advanceAmount,
        'deliveryStatus': order.deliveryStatus,
        'orderStatus': order.orderStatus,
        'expectedDeliveryTime': order.expectedDeliveryTime,
        'deliveryAddress': order.deliveryAddress,
      }),
    );
    debugPrint(
        'Create Order URL: ${Uri.parse('$orderUrl/orders/createOrder')}');
    debugPrint('Create Order request body: ${jsonEncode({
          'userId': order.userId,
          'productId': order.productId,
          'totalAmount': order.totalAmount,
          'advanceAmount': order.advanceAmount,
          'deliveryStatus': order.deliveryStatus,
          'orderStatus': order.orderStatus,
          'expectedDeliveryTime': order.expectedDeliveryTime,
          'deliveryAddress': order.deliveryAddress,
        })}');
    debugPrint('Create Order Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Order created successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      await fetchOrders();
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.delete(
      Uri.parse('$orderUrl/deleteOrder/$orderId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      _orders.removeWhere((order) => order.id == orderId);
      notifyListeners();
    } else {
      throw Exception('Failed to delete order');
    }
  }

  Future<void> updateOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.put(
      Uri.parse('$orderUrl/orders/updateOrder'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'orderId': order.id,
        'userId': order.userId,
        'productId': order.productId,
        'totalAmount': order.totalAmount,
        'advanceAmount': order.advanceAmount,
        'deliveryStatus': order.deliveryStatus,
        'orderStatus': order.orderStatus,
        'expectedDeliveryTime': order.expectedDeliveryTime,
        'deliveryAddress': order.deliveryAddress,
      }),
    );

    if (response.statusCode == 200) {
      await fetchOrders();
    } else {
      throw Exception('Failed to update order');
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$orderUrl/orders/getOrder/$orderId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    isLoading = false;
    notifyListeners();
    log('Get Order URL: ${Uri.parse('$orderUrl/orders/getOrder/$orderId')}');
    log('Get Order Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['order']);
    } else {
      throw Exception('Failed to fetch order');
    }
  }
}
