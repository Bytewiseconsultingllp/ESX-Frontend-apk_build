// lib/features/order/view/user_orders_page.dart
import 'package:esx/core/widgets/app_header.dart';
import 'package:esx/features/order/view/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esx/features/order/provider/order_provider.dart';
import 'package:esx/features/order/models/order_model.dart';
import 'package:esx/core/constants/colors.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.orders;

    return Scaffold(
      backgroundColor: ESXColors.background,
      appBar: AppBar(
        title: AppHeader(),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ESXColors.whiteColor),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              'Your Orders',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 20,
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Track your purchases and stay updated on delivery status.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 10,
                height: 1.0,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: provider.orders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      return OrderCard(order: order);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
