import 'package:esx/features/product/models/bid_product_model.dart';
import 'package:flutter/material.dart';
import 'package:esx/features/product/models/product_model.dart';
import 'package:esx/core/constants/colors.dart';
import 'package:esx/core/constants/text_styles.dart';

class ProductCard extends StatelessWidget {
  final ProductWithBidStatus productWithBidStatus;
  final bool isWinner;
  final VoidCallback? onTap;
  final VoidCallback? onBidTap;

  const ProductCard({
    super.key,
    required this.productWithBidStatus,
    this.isWinner = false,
    this.onTap,
    this.onBidTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = productWithBidStatus.product;
    final userBid = productWithBidStatus.userBid;
    final bool isBiddedByUser = productWithBidStatus.isBiddedByUser;
    final bool isPaymentWindowExpired = isWinner &&
        userBid != null &&
        DateTime.now()
            .isAfter(userBid.createdAt.add(const Duration(hours: 48)));

    double remainingAmount = 0;
    if (isWinner && userBid != null) {
      remainingAmount = userBid.totalAmount - userBid.advanceAmount;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Product Info Section ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[100],
                      child: product.productImage.isNotEmpty
                          ? Image.network(
                              product.productImage.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.productDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (product.category.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: product.category.take(2).map((cat) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ESXColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ESXColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// --- Bid Quantity & Price Section ---
              if (isBiddedByUser && userBid != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No. of Units',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${userBid.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price per Unit',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '₹${userBid.pricePerUnit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              /// --- Bid or Payment Details ---
              if (isWinner && userBid != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You won this bid!',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Advance Paid: ₹${userBid.advanceAmount.toStringAsFixed(2)}'),
                          Text(
                              'Remaining: ₹${remainingAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in: ${_timeLeft(userBid.createdAt)}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message:
                                'Bid will be invalid after 48 hours and you will lose the advance amount.',
                            child: Icon(Icons.info_outline,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ] else if (isBiddedByUser && userBid != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ESXColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Your Bid: ₹${userBid.totalAmount.toStringAsFixed(2)}'),
                      Text(
                          'Advance: ₹${userBid.advanceAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                )
              ],

              const SizedBox(height: 12),

              /// --- Status + Button Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (product.isSold) _statusBadge('SOLD', Colors.red),
                      if (product.isPriceFrozen && !product.isSold)
                        _statusBadge('FROZEN', Colors.blue),
                      if (!product.isSold && !product.isPriceFrozen)
                        _statusBadge('LIVE', Colors.green),
                    ],
                  ),
                  if (!product.isSold && product.isAvailable)
                    ElevatedButton(
                      onPressed: isPaymentWindowExpired ? null : onBidTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ESXColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isWinner
                            ? 'Complete Payment'
                            : (isBiddedByUser ? 'Edit Bid' : 'Bid Now'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _priceColumn(String label, double amount, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? ESXColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _timeLeft(DateTime from) {
    final expiration = from.add(const Duration(hours: 48));
    final diff = expiration.difference(DateTime.now());

    if (diff.isNegative) return "Expired";

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return "${hours}h ${minutes}m";
  }
}
