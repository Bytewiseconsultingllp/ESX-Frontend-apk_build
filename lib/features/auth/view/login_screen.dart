// File: login_screen.dart
import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import 'otp_screen.dart';
import 'widgets/login_header.dart';
import 'widgets/login_footer.dart';
import 'widgets/phone_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '91';
  bool _isLoading = false;
  bool _isPhoneValid = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '62', 'country': 'Indonesia', 'flag': '🇮🇩'},
    {'code': '1', 'country': 'USA', 'flag': '🇺🇸'},
    {'code': '44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '86', 'country': 'China', 'flag': '🇨🇳'},
    {'code': '81', 'country': 'Japan', 'flag': '🇯🇵'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phoneLength = _phoneController.text.length;
    bool isValid = false;

    switch (_countryCode) {
      case '+91':
      case '+1':
      case '+44':
        isValid = phoneLength == 10;
        break;
      case '+62':
        isValid = phoneLength >= 9 && phoneLength <= 12;
        break;
      default:
        isValid = phoneLength >= 8 && phoneLength <= 15;
    }

    if (isValid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = isValid;
      });
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[0-9]+$').hasMatch(value))
      return 'Please enter only numbers';

    final phoneLength = value.length;
    switch (_countryCode) {
      case '+91':
      case '+1':
      case '+44':
        if (phoneLength != 10) return 'Please enter a valid 10-digit number';
        break;
      case '+62':
        if (phoneLength < 9 || phoneLength > 12)
          return 'Invalid Indonesian number';
        break;
      default:
        if (phoneLength < 8 || phoneLength > 15) return 'Invalid phone number';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phone = '$_countryCode${_phoneController.text}';
    debugPrint("Sending OTP to $phone");
    bool success = await authProvider.sendOtp(phone);
    debugPrint("OTP sent: $success");
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone)),
      );
    } else {
      final error = authProvider.error ?? "Something went wrong";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String _getHintText() {
    switch (_countryCode) {
      case '+91':
        return '9876543210';
      case '+62':
        return '81234567890';
      case '+1':
        return '5551234567';
      case '+44':
        return '7912345678';
      default:
        return 'Enter phone number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ESXColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const LoginHeader(),
                const SizedBox(height: 48),
                PhoneInputField(
                  phoneController: _phoneController,
                  countryCode: _countryCode,
                  countryCodes: _countryCodes,
                  onCountryCodeChanged: (code) => setState(() {
                    _countryCode = code;
                    _validatePhone();
                  }),
                  isPhoneValid: _isPhoneValid,
                  validator: _validatePhoneNumber,
                  getHintText: _getHintText,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhoneValid
                          ? ESXColors.primary
                          : ESXColors.buttonDisabled,
                      foregroundColor: _isPhoneValid
                          ? Colors.white
                          : ESXColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isPhoneValid ? 2 : 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Send OTP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const LoginFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
