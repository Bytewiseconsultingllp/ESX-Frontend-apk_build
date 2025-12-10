import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/profile/models/address_model.dart';
import 'package:esx/features/profile/provider/user_provider.dart';
import 'package:esx/features/profile/view/add_address_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await context.read<UserProvider>().getUserAddress();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAddressScreen(),
                ),
              ).then((_) {
                _loadAddresses();
              });
            },
          )
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (userProvider.address == null || userProvider.address!.isEmpty)
              ? const Center(child: Text("No addresses found"))
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    itemCount: userProvider.address!.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final Address addr = userProvider.address![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addr.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(addr.email,
                                  style: TextStyle(
                                      color: ESXColors.textSecondary)),
                              Text(addr.phoneNumber),
                              if (addr.alternateNumber.isNotEmpty)
                                Text("Alt: ${addr.alternateNumber}"),
                              const SizedBox(height: 4),
                              Text("${addr.lane}, ${addr.city}, ${addr.state}"),
                              Text("${addr.country} - ${addr.pincode}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
