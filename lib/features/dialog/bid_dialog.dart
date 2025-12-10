import 'package:esx/features/bid/provider/bid_provider.dart';
import 'package:esx/features/product/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Add your BidProvider import here
// import 'package:esx/providers/bid_provider.dart';

class BidDialog extends StatefulWidget {
  final Product product;
  final double lowPrice;
  final double highPrice;
  final double currentPrice;
  final int noOfUnits;
  // Callback to notify when bid is placed successfully
  final VoidCallback? onBidPlaced;

  const BidDialog(
      {super.key,
      required this.product,
      required this.lowPrice,
      required this.highPrice,
      required this.currentPrice,
      required this.noOfUnits,
      required this.onBidPlaced});

  @override
  _BidDialogState createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  final TextEditingController _bidController = TextEditingController();
  String? _userId;
  int _quantity = 1;
  double _pricePerUnit = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  void _submitBid() async {
    String bidText = _bidController.text.trim();
    if (bidText.isEmpty) {
      _showSnackBar('Please enter a unit bid amount', Colors.red);
      return;
    }

    double? unitBid = double.tryParse(bidText);
    double low = widget.lowPrice;
    double high = widget.highPrice;

    if (unitBid == null || unitBid <= 0) {
      _showSnackBar('Please enter a valid unit bid amount', Colors.red);
      return;
    }

    if (unitBid < low || unitBid > high) {
      _showSnackBar(
        'Unit bid must be between ₹${low.toStringAsFixed(2)} and ₹${high.toStringAsFixed(2)}',
        Colors.red,
      );
      return;
    }

    if (_userId == null) {
      _showSnackBar('User not logged in', Colors.red);
      return;
    }

    int totalAmount = (unitBid * _quantity).round();
    int advanceAmount = (totalAmount * 0.1).round();

    final bidProvider = Provider.of<BidProvider>(context, listen: false);

    try {
      await bidProvider.placeBid(
        productId: widget.product.id,
        userId: _userId!,
        totalAmount: totalAmount,
        advanceAmount: advanceAmount,
        paymentId: '', // Replace with actual paymentId if available
        quantity: _quantity,
        pricePerUnit: unitBid.round(),
      );

      if (bidProvider.error != null) {
        _showSnackBar(bidProvider.error!, Colors.red);
      } else if (bidProvider.successMessage != null) {
        _showSnackBar(bidProvider.successMessage!, Colors.green);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onBidPlaced?.call();
        }
      }
    } catch (e) {
      _showSnackBar('Failed to place bid. Please try again.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BidProvider>(
      builder: (context, bidProvider, child) {
        double? unitBid = double.tryParse(_bidController.text.trim());
        int total = (unitBid != null) ? (unitBid * _quantity).round() : 0;
        int advance = (total * 0.1).round();

        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black,
                child: Icon(Icons.gavel, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Bid range: ₹${widget.lowPrice} - ₹${widget.highPrice}',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bidController,
                      enabled: !bidProvider.isLoading,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Unit bid amount',
                        prefixText: '₹ ',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _quantity,
                    onChanged: bidProvider.isLoading
                        ? null
                        : (val) => setState(() => _quantity = val!),
                    items: List.generate(
                      widget.noOfUnits,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1} unit(s)'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (unitBid != null)
                Column(
                  children: [
                    Text('Total: ₹$total'),
                    Text('Advance (10%): ₹$advance'),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: bidProvider.isLoading ? null : _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: bidProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Submit"),
              ),
              const SizedBox(height: 12),
              if (bidProvider.error != null ||
                  bidProvider.successMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bidProvider.error != null
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: bidProvider.error != null
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    bidProvider.error ?? bidProvider.successMessage ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bidProvider.error != null
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text(
                  '💡 10% of the total bid amount must be paid in advance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
