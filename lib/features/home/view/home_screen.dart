import 'package:esx/core/constants/text_styles.dart';
import 'package:esx/core/widgets/app_header.dart';
import 'package:esx/features/product/models/product_model.dart';
import 'package:esx/features/product/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:esx/features/dialog/bid_dialog.dart';
import 'package:esx/features/dialog/bid_success_dialog.dart';
import 'package:esx/features/home/view/home_drawer.dart';
import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/home/view/widgets/category_card.dart';
import 'package:esx/features/home/view/widgets/brand_icon.dart';
import 'package:esx/features/home/view/widgets/product_row.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String selectedBrand = "All";
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final List<String> categories = [
    "All",
    "Televisions",
    "Laptops",
    "Refrigerators",
    "Office",
    "Gaming",
    "iPads",
    "Mobile",
    "Smartphone",
    "Electronics"
  ];

  final List<String> brands = [
    "All",
    "Samsung",
    "LG",
    "Sony",
    "Apple",
    "DELL",
    "Panasonic",
    "OnePlus",
    "Xiaomi",
    "Realme"
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }

  @override
  void dispose() {
    ProductProvider productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.disposeSocket();
    super.dispose();
  }

  List<Product> getFilteredProducts(List<Product> products) {
    return products.where((product) {
      bool categoryMatch = selectedCategory == "All" ||
          product.category.any((cat) =>
              cat.toLowerCase().contains(selectedCategory.toLowerCase()));

      bool brandMatch = selectedBrand == "All" ||
          product.productName
              .toLowerCase()
              .contains(selectedBrand.toLowerCase());

      bool searchMatch = searchQuery.isEmpty ||
          product.productName.toLowerCase().contains(searchQuery.toLowerCase());

      return categoryMatch &&
          brandMatch &&
          searchMatch &&
          product.isAvailable &&
          !product.isSold;
    }).toList();
  }

  String extractBrandFromProductName(String productName) {
    String lowerName = productName.toLowerCase();
    for (String brand in brands) {
      if (brand != "All" && lowerName.contains(brand.toLowerCase())) {
        return brand;
      }
    }
    return "Other";
  }

  Map<String, List<Product>> groupProductsByBrand(List<Product> products) {
    Map<String, List<Product>> groupedProducts = {};

    for (Product product in products) {
      String brand = extractBrandFromProductName(product.productName);
      if (!groupedProducts.containsKey(brand)) {
        groupedProducts[brand] = [];
      }
      groupedProducts[brand]!.add(product);
    }

    return groupedProducts;
  }

  Color getBrandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'apple':
        return Colors.blue;
      case 'samsung':
        return Colors.orange;
      case 'lg':
        return Colors.red;
      case 'sony':
        return Colors.purple;
      case 'dell':
        return Colors.indigo;
      case 'oneplus':
        return Colors.green;
      case 'xiaomi':
        return Colors.amber;
      case 'realme':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      endDrawer: const HomeDrawer(),
      backgroundColor: ESXColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppHeader(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProductProvider>(context, listen: false)
              .fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : const Icon(Icons.mic, color: Colors.grey),
                    hintText: "Search for gadgets, brands, or categories...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Categories Section
              // Category Row Header (unchanged)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 16, // Slightly smaller
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (selectedCategory != "All")
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = "All";
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child:
                          const Text("Clear", style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12, // 🔽 smaller font
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Repeat similar tweaks for Brands
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Brands",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (selectedBrand != "All")
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedBrand = "All";
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child:
                          const Text("Clear", style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    final isSelected = selectedBrand == brand;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBrand = brand;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? getBrandColor(brand) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? getBrandColor(brand)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            brand,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Product Header
              Container(
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
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          "High",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          "Low",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          "Current",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          "Bid",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Products List
              if (productProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (productProvider.products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text(
                      "No products available",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else ...[
                Builder(
                  builder: (context) {
                    final filteredProducts =
                        getFilteredProducts(productProvider.products);

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Text(
                            "No products match your filters",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    final groupedProducts =
                        groupProductsByBrand(filteredProducts);

                    return Column(
                      children: groupedProducts.entries.map((entry) {
                        final brand = entry.key;
                        final products = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: getBrandColor(brand),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    brand,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${products.length} product${products.length > 1 ? 's' : ''}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...products
                                  .map((product) => ProductRow(
                                        title: product.productName,
                                        highPrice:
                                            product.maxPrice.toStringAsFixed(0),
                                        lowPrice:
                                            product.minPrice.toStringAsFixed(0),
                                        originalPrice: (product.maxPrice * 1.5)
                                            .toStringAsFixed(0),
                                        currentPrice: product.currentPrice
                                            .toStringAsFixed(0),
                                        product: product,
                                        onBidPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => BidDialog(
                                              product: product,
                                              lowPrice: product.minPrice,
                                              highPrice: product.maxPrice,
                                              currentPrice:
                                                  product.currentPrice,
                                              noOfUnits: product.noOfUnit,
                                              onBidPlaced: () {
                                                // You can add your logic here, e.g. refresh products or show a success dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      BidSuccessDialog(),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ))
                                  .toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
