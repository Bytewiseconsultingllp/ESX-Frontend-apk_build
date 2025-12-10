import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esx/core/services/url.dart';

class BidProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  final String bidUrl = productUrl + '/bid';

  Future<void> placeBid({
    required String productId,
    required String userId,
    required int totalAmount,
    required int advanceAmount,
    required String paymentId,
    required int quantity,
    required int pricePerUnit,
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('$bidUrl/$productId');

      final requestBody = {
        'userId': userId,
        'totalAmount': totalAmount,
        'advanceAmount': advanceAmount,
        'paymentId': paymentId,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Bid request URL: $url');
      debugPrint('Bid request body: ${jsonEncode(requestBody)}');
      debugPrint('Bid response status code: ${response.statusCode}');
      debugPrint('Bid response body: ${response.body}');

      if (response.statusCode == 200) {
        _successMessage = "Bid placed successfully!";
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to place bid';
      }
    } catch (e) {
      _error = 'Error placing bid: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
