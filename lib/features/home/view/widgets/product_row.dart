import 'package:esx/features/home/view/widgets/product_details_bottomsheet.dart';
import 'package:esx/features/product/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:esx/features/dialog/bid_dialog.dart';
import 'package:esx/features/dialog/bid_success_dialog.dart';

class ProductRow extends StatelessWidget {
  final String title;
  final String highPrice;
  final String lowPrice;
  final String originalPrice;
  final String currentPrice;
  final Product product;
  final VoidCallback? onBidPressed;

  const ProductRow({
    super.key,
    required this.title,
    required this.highPrice,
    required this.lowPrice,
    required this.originalPrice,
    required this.currentPrice,
    required this.product,
    this.onBidPressed,
  });

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailBottomSheet(
        product: product,
        onBidPressed: onBidPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProductDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // First row: Product name only
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "${product.noOfUnit} unit${product.noOfUnit > 1 ? 's' : ''}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Second row: Image, prices, and bid button (same as original)
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: product.productImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            product.productImage[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      "₹$highPrice",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      "₹$lowPrice",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹$originalPrice",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "₹$currentPrice",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => BidDialog(
                          product: product,
                          lowPrice: double.parse(lowPrice),
                          highPrice: double.parse(highPrice),
                          currentPrice: double.parse(currentPrice),
                          noOfUnits: product.noOfUnit,
                          onBidPlaced: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => BidSuccessDialog(),
                            );

                            if (onBidPressed != null) {
                              onBidPressed!();
                            }
                          },
                        ),
                        // builder: (context) => BidDialog(
                        //   product: product,
                        //   onBidPlaced: () {
                        //     showDialog(
                        //       context: context,
                        //       barrierDismissible: false,
                        //       builder: (context) => BidSuccessDialog(),
                        //     );

                        //     if (onBidPressed != null) {
                        //       onBidPressed!();
                        //     }
                        //   },
                        // ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    child: const Text(
                      "Bid",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
