import 'package:esx/features/bids/widgets/product_card.dart';
import 'package:esx/features/product/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveBidsPage extends StatefulWidget {
  const LiveBidsPage({super.key});

  @override
  State<LiveBidsPage> createState() => _LiveBidsPageState();
}

class _LiveBidsPageState extends State<LiveBidsPage> {
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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final liveBids = productProvider.biddedProducts;

        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error != null) {
          return Center(child: Text(productProvider.error!));
        }

        if (liveBids.isEmpty) {
          return const Center(child: Text("You don't have any live bids."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: liveBids.length,
          itemBuilder: (context, index) {
            final productWithBid = liveBids[index];
            return ProductCard(productWithBidStatus: productWithBid);
          },
        );
      },
    );
  }
}
