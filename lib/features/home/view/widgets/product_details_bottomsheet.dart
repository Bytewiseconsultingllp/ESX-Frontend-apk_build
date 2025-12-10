import 'package:esx/features/product/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:esx/features/dialog/bid_dialog.dart';
import 'package:esx/features/dialog/bid_success_dialog.dart';

class ProductDetailBottomSheet extends StatefulWidget {
  final Product product;
  final VoidCallback? onBidPressed;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
    this.onBidPressed,
  });

  @override
  State<ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel
                  if (product.productImage.isNotEmpty) ...[
                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: product.productImage.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.productImage[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Image indicators
                          if (product.productImage.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  product.productImage.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? Colors.blue
                                          : Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Price information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Current Price:",
                                style: TextStyle(fontSize: 14)),
                            Text(
                              "₹${product.currentPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Min Price:",
                                style: TextStyle(fontSize: 14)),
                            Text(
                              "₹${product.minPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Max Price:",
                                style: TextStyle(fontSize: 14)),
                            Text(
                              "₹${product.maxPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (product.lastBiddedPrice != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Last Bid:",
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                "₹${product.lastBiddedPrice!.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Product description
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.productDescription,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // Product details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Product Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                            "Units Available", product.noOfUnit.toString()),
                        _buildDetailRow(
                            "Categories", product.category.join(", ")),
                        _buildDetailRow("Bidding Date",
                            _formatDateTime(product.biddingDate)),
                        _buildDetailRow("Last Updated",
                            _formatDateTime(product.lastUpdatedAt)),
                        _buildDetailRow("Dimensions",
                            "${product.dimensions.length} × ${product.dimensions.width} × ${product.dimensions.height}"),
                        _buildDetailRow(
                            "Status",
                            product.isAvailable
                                ? "Available"
                                : "Not Available"),
                        if (product.isPriceFrozen) ...[
                          _buildDetailRow("Price Status", "Frozen"),
                          if (product.freezeExpiresAt != null)
                            _buildDetailRow("Freeze Expires",
                                _formatDateTime(product.freezeExpiresAt!)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Delivery details
                  if (product.deliveryDetails.shippingTime != "N/A") ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow("Shipping Time",
                              product.deliveryDetails.shippingTime),
                          _buildDetailRow("Delivery Charges",
                              "₹${product.deliveryDetails.deliveryCharges.toStringAsFixed(2)}"),
                          if (product
                              .deliveryDetails.deliveryOptions.isNotEmpty)
                            _buildDetailRow(
                                "Delivery Options",
                                product.deliveryDetails.deliveryOptions
                                    .join(", ")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Add to Wishlist"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.isAvailable && !product.isSold
                        ? () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => BidDialog(
                                product: product,
                                lowPrice: product.minPrice,
                                highPrice: product.maxPrice,
                                currentPrice: product.currentPrice,
                                noOfUnits: product.noOfUnit,
                                onBidPlaced: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => BidSuccessDialog(),
                                  );

                                  if (widget.onBidPressed != null) {
                                    widget.onBidPressed!();
                                  }
                                },
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.gavel),
                    label: Text(product.isSold ? "Sold Out" : "Place Bid"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: product.isAvailable && !product.isSold
                          ? Colors.blue
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
