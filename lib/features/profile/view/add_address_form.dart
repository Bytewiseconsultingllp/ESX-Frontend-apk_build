import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/profile/models/address_model.dart';
import 'package:esx/features/profile/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _laneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pinCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _alternateNumberController.dispose();
    _laneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        alternateNumber: _alternateNumberController.text,
        lane: _laneController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        pincode: int.tryParse(_pinCodeController.text) ?? 0,
      );

      final success =
          await context.read<UserProvider>().addUserAddress(address: address);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Address added successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add address")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: ESXColors.lightGreyColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );

    return Scaffold(
      backgroundColor: ESXColors.background,
      appBar: AppBar(
        title: const Text('Shipping'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Enter Your Shipping Details',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help us deliver your order smoothly',
                style: TextStyle(fontSize: 14, color: ESXColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildLabel("Name"),
              TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  decoration: inputDecoration),
              const SizedBox(height: 16),
              _buildLabel("Email"),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    inputDecoration.copyWith(hintText: "XXXXXXX@gmail.com"),
              ),
              const SizedBox(height: 16),
              _buildLabel("Phone Number"),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: inputDecoration.copyWith(hintText: "98490XXXXX"),
              ),
              const SizedBox(height: 16),
              _buildLabel("Alternate Number"),
              TextFormField(
                controller: _alternateNumberController,
                keyboardType: TextInputType.phone,
                decoration: inputDecoration.copyWith(hintText: "98490XXXXX"),
              ),
              const SizedBox(height: 16),
              _buildLabel("Lane / Street"),
              TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _laneController,
                  decoration: inputDecoration),
              const SizedBox(height: 16),
              _buildLabel("City"),
              TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _cityController,
                  decoration: inputDecoration),
              const SizedBox(height: 16),
              _buildLabel("State"),
              TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _stateController,
                  decoration: inputDecoration),
              const SizedBox(height: 16),
              _buildLabel("Country"),
              TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _countryController,
                  decoration: inputDecoration),
              const SizedBox(height: 16),
              _buildLabel("Pin Code"),
              TextFormField(
                controller: _pinCodeController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(hintText: "XXX XXX"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ESXColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}
