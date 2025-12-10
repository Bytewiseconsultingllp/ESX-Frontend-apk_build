import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/bids/widgets/product_card.dart';
import 'package:esx/features/order/models/order_model.dart';
import 'package:esx/features/order/provider/order_provider.dart';
import 'package:esx/features/product/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({super.key});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final wonBids = provider.wonProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : wonBids.isEmpty
                  ? const Center(child: Text('No products won yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: wonBids.length,
                      itemBuilder: (context, index) {
                        final item = wonBids[index];
                        return ProductCard(
                            productWithBidStatus: item,
                            isWinner: true,
                            onBidTap: () async {
                              final orderProvider = Provider.of<OrderProvider>(
                                  context,
                                  listen: false);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getString('userId');

                              if (userId == null) {
                                Fluttertoast.showToast(
                                    msg: 'User ID not found');
                                return;
                              }

                              try {
                                await orderProvider.createOrder(Order(
                                  id: '', // ID will be set by backend
                                  userId: userId,
                                  productId: item.product.id,
                                  totalAmount: item?.userBid?.totalAmount ?? 0,
                                  advanceAmount:
                                      item?.userBid?.advanceAmount ?? 0,
                                  deliveryStatus: 'accepted',
                                  orderStatus: 'confirmed',
                                  expectedDeliveryTime: '7 days',
                                  deliveryAddress: 'Default Address',
                                  createdAt: DateTime.now(),
                                ));

                                Fluttertoast.showToast(
                                    msg: 'Order placed successfully');
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: 'Failed to place order');
                              }
                            });
                      },
                    ),
    );
  }
}
