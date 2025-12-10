import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/order/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch order details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      provider.getOrderById(widget.order.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ESXColors.background,
      appBar: AppBar(
        backgroundColor: ESXColors.primary,
        foregroundColor: ESXColors.whiteColor,
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ESXColors.primary,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading order details',
                    style: TextStyle(
                      fontSize: 16,
                      color: ESXColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ESXColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.getOrderById(widget.order.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ESXColors.primary,
                      foregroundColor: ESXColors.whiteColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = widget.order;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header Card
                _buildOrderHeaderCard(order),
                const SizedBox(height: 16),

                // Order Status Card
                _buildOrderStatusCard(order),
                const SizedBox(height: 16),

                // Order Summary Card
                _buildOrderSummaryCard(order),
                const SizedBox(height: 16),

                // Delivery Information Card
                _buildDeliveryInfoCard(order),
                const SizedBox(height: 16),

                // Payment Information Card
                _buildPaymentInfoCard(order),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeaderCard(Order order) {
    return Card(
      elevation: 2,
      color: ESXColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: ESXColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Placed on ${_formatDate(order.createdAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ESXColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: ESXColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expected delivery: ${order.expectedDeliveryTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ESXColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(Order order) {
    return Card(
      elevation: 2,
      color: ESXColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ESXColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(order.orderStatus),
                    color: _getStatusColor(order.orderStatus),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderStatus}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(order.orderStatus),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Delivery Status: ${order.deliveryStatus}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ESXColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Order order) {
    final remainingAmount = order.totalAmount - order.advanceAmount;

    return Card(
      elevation: 2,
      color: ESXColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ESXColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ESXColors.lightGreyColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ESXColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: ESXColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product ID: ${order.productId.substring(0, 8)}...',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ESXColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: 1',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ESXColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ESXColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: ESXColors.lightGreyColor),
            const SizedBox(height: 8),
            _buildSummaryRow(
                'Subtotal', '₹${order.totalAmount.toStringAsFixed(0)}'),
            _buildSummaryRow(
                'Advance Paid', '₹${order.advanceAmount.toStringAsFixed(0)}',
                isHighlight: true),
            _buildSummaryRow(
                'Remaining Amount', '₹${remainingAmount.toStringAsFixed(0)}',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? ESXColors.primary : ESXColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? ESXColors.primary : ESXColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(Order order) {
    return Card(
      elevation: 2,
      color: ESXColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ESXColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ESXColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: ESXColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 12,
                          color: ESXColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ESXColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ESXColors.tealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: ESXColors.tealColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expected Delivery',
                        style: TextStyle(
                          fontSize: 12,
                          color: ESXColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.expectedDeliveryTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ESXColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard(Order order) {
    final remainingAmount = order.totalAmount - order.advanceAmount;

    return Card(
      elevation: 2,
      color: ESXColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ESXColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ESXColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ESXColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advance Paid',
                        style: TextStyle(
                          fontSize: 14,
                          color: ESXColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${order.advanceAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ESXColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ESXColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${remainingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ESXColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    final remainingAmount = order.totalAmount - order.advanceAmount;

    return Column(
      children: [
        if (remainingAmount > 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle payment
                _handlePayment(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ESXColors.primary,
                foregroundColor: ESXColors.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pay Remaining ₹${remainingAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Handle track order
              _trackOrder(order);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: ESXColors.primary,
              side: const BorderSide(color: ESXColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Track Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // Handle contact support
              _contactSupport(order);
            },
            style: TextButton.styleFrom(
              foregroundColor: ESXColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'delivered':
        return ESXColors.primary;
      case 'cancelled':
        return Colors.red;
      default:
        return ESXColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.hourglass_empty;
      case 'delivered':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _handlePayment(Order order) {
    // Implement payment logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment feature will be implemented'),
        backgroundColor: ESXColors.primary,
      ),
    );
  }

  void _trackOrder(Order order) {
    // Implement order tracking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order tracking feature will be implemented'),
        backgroundColor: ESXColors.primary,
      ),
    );
  }

  void _contactSupport(Order order) {
    // Implement contact support logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support feature will be implemented'),
        backgroundColor: ESXColors.primary,
      ),
    );
  }
}
