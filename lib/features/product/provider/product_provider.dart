import 'dart:convert';
import 'dart:developer';
import 'package:esx/features/product/models/bid_product_model.dart';
import 'package:esx/features/product/models/product_model.dart';
import 'package:esx/features/profile/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:esx/core/services/url.dart';
import 'package:collection/collection.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<UserBid> _userBids = []; // Won products/completed bids
  List<UserBid> _liveBids = []; // Live/active bids
  bool _isLoading = false;
  String? _error;

  IO.Socket? _socket;

  List<Product> get products => _products;
  List<UserBid> get userBids => _userBids; // Won products
  List<UserBid> get liveBids => _liveBids; // Live bids
  bool get isLoading => _isLoading;
  String? get error => _error;
  final String productUrl = dotenv.env['PRODUCT_URL']!;
  final String orderUrl = dotenv.env['ORDER_URL']!;
  final String baseUrl = dotenv.env['BASE_URL']!;

  // Get products with bid status (using live bids)
  List<ProductWithBidStatus> get productsWithBidStatus {
    return _products.map((product) {
      final userBid = _liveBids.firstWhereOrNull(
        (bid) => bid.productId == product.id,
      );
      return ProductWithBidStatus(product: product, userBid: userBid);
    }).toList();
  }

  // Get only products that user has actively bidded on (live bids)
  List<ProductWithBidStatus> get biddedProducts {
    return productsWithBidStatus
        .where((productWithBid) => productWithBid.isBiddedByUser)
        .toList();
  }

  // Get won products with their details
  List<ProductWithBidStatus> get wonProducts {
    return _products
        .map((product) {
          final userBid = _userBids.firstWhereOrNull(
            (bid) => bid.productId == product.id,
          );
          return ProductWithBidStatus(product: product, userBid: userBid);
        })
        .where((productWithBid) => productWithBid.userBid != null)
        .toList();
  }

  // Fetch won products/bids
  Future<void> fetchWonBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final userId = prefs.getString('userId');

      if (accessToken == null) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('$orderUrl/bids/getBids/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Fetching won bids from: $url');
      debugPrint('Won bids status: ${response.statusCode}');
      log('Won bids response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // FIXED: Changed from 'livebids' to 'bids'
        final List<dynamic> bidsData = responseData['bids'] ?? [];

        final allUserBids =
            bidsData.map<UserBid>((json) => UserBid.fromJson(json)).toList();

        _userBids = allUserBids
            .groupListsBy((bid) => bid.productId)
            .values
            .map((bids) =>
                bids.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b))
            .toList();
      } else {
        _error = 'Failed to fetch won bids: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching won bids: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // New function to fetch live/active bids
  Future<void> fetchLiveBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final userId = prefs.getString('userId');

      if (accessToken == null) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('$productUrl/bid/getlivebids/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Fetching live bids from: $url');
      debugPrint('Live bids status: ${response.statusCode}');
      log('Live bids response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // FIXED: Changed from 'bids' to 'livebids'
        final List<dynamic> bidsData = responseData['livebids'] ?? [];

        final allUserBids =
            bidsData.map<UserBid>((json) => UserBid.fromJson(json)).toList();

        _liveBids = allUserBids
            .groupListsBy((bid) => bid.productId)
            .values
            .map((bids) =>
                bids.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b))
            .toList();
      } else {
        _error = 'Failed to fetch live bids: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching live bids: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserBids() async {
    await fetchWonBids();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      debugPrint('Access Token: $accessToken');

      if (accessToken == null) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('$productUrl/products');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('Fetching products from: $url');
      debugPrint('product status: ${response.statusCode}');
      log('product response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        _initializeSocketListeners();
      } else {
        _error = 'Failed to fetch products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch products, live bids, and won bids
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchProducts(),
      fetchLiveBids(),
      fetchWonBids(),
    ]);
  }

  // Check if user has active bid on a specific product
  bool hasUserBidded(String productId) {
    return _liveBids.any((bid) => bid.productId == productId);
  }

  // Check if user has won a specific product
  bool hasUserWon(String productId) {
    return _userBids.any((bid) => bid.productId == productId);
  }

  // Get user's live bid for a specific product
  UserBid? getUserBidForProduct(String productId) {
    try {
      return _liveBids.firstWhere((bid) => bid.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Get user's won bid for a specific product
  UserBid? getUserWonBidForProduct(String productId) {
    try {
      return _userBids.firstWhere((bid) => bid.productId == productId);
    } catch (e) {
      return null;
    }
  }

  void _initializeSocketListeners() {
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket?.connect();
    _socket?.onConnect((_) {
      print('Socket connected');
    });

    // Listen to new product
    _socket?.on('product:new', (data) {
      final newProduct = Product.fromJson(data);
      _products.add(newProduct);
      notifyListeners();
    });

    // Listen to bid restart
    for (var product in _products) {
      _socket?.on('product:bidRestart:${product.id}', (data) {
        final updated = Product.fromJson(data);
        final index = _products.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          _products[index] = updated;
          notifyListeners();
        }
      });

      // Listen to price updates
      _socket?.on('product:priceUpdate:${product.id}', (data) {
        debugPrint('📡 Price update received for product ${product.id}: $data');
        log("Full price update payload: ${data.toString()}");

        final index = _products.indexWhere((p) => p.id == data['productId']);
        if (index != -1) {
          final currentPrice = (data['currentPrice'] as num?)?.toDouble();
          final lastBiddedPrice = (data['lastBiddedPrice'] as num?)?.toDouble();

          _products[index] = _products[index].copyWith(
            currentPrice: currentPrice ?? _products[index].currentPrice,
            lastBiddedPrice:
                lastBiddedPrice ?? _products[index].lastBiddedPrice,
          );

          notifyListeners();
        } else {
          debugPrint('Product not found for update: ${data['productId']}');
        }
      });
    }
    debugPrint('Socket listeners initialized for products');
  }

  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
  }
}
