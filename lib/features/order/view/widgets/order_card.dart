import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/order/models/order_model.dart';
import 'package:esx/features/order/view/order_details_page.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF2F2F2),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                const SizedBox(width: 16),
                Expanded(child: _buildProductDetails()),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        order.imageUrl ?? '',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 80,
          height: 80,
          color: ESXColors.lightGreyColor.withOpacity(0.2),
          child: Icon(
            Icons.phone_iphone,
            size: 40,
            color: ESXColors.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    const double fontSize = 13;

    TextStyle labelStyle = TextStyle(
      fontSize: fontSize,
      color: ESXColors.textSecondary.withOpacity(0.8),
      fontWeight: FontWeight.w500,
    );

    TextStyle valueStyle = const TextStyle(
      fontSize: fontSize,
      color: ESXColors.blackColor,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.name ?? "Unknown Product",
          style: valueStyle.copyWith(fontSize: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text('Order ID - ${order.productId}', style: labelStyle),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Status - ', style: labelStyle),
            Text(
              order.orderStatus,
              style: valueStyle.copyWith(color: _getStatusColor()),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('ETA - ${order.expectedDeliveryTime}', style: labelStyle),
        Text('Shipment - ${order.shipmentProvider ?? "Blue Dart"}',
            style: labelStyle),
        Text('Tracking ID - N/A', style: labelStyle),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          'View Details',
          Colors.black,
          Colors.white,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(order: order),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          'Download Invoice',
          ESXColors.lightGreyColor,
          ESXColors.textPrimary,
          () {
            // implement invoice download
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          'Track Order',
          ESXColors.lightGreyColor,
          ESXColors.textPrimary,
          () {
            // implement order tracking
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, Color bg, Color fg, VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        height: 36,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: bg == ESXColors.lightGreyColor
                  ? BorderSide(color: ESXColors.textSecondary.withOpacity(0.3))
                  : BorderSide.none,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.orderStatus.toLowerCase()) {
      case 'pending':
      case 'preparing':
      case 'being prepared':
        return Colors.orange.shade600;
      case 'confirmed':
      case 'processing':
        return Colors.blue.shade600;
      case 'shipped':
      case 'out for delivery':
        return Colors.purple.shade600;
      case 'delivered':
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
      case 'returned':
        return Colors.red.shade600;
      default:
        return ESXColors.textSecondary;
    }
  }
}
