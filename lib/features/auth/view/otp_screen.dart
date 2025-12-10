import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:esx/features/auth/view/registration_page.dart';
import 'package:esx/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../root/view/root_screen.dart';
import 'widgets/otp_input_widget.dart';
import 'widgets/verification_header_widget.dart';
import 'widgets/resend_code_widget.dart';
import 'widgets/alternative_options_widget.dart';
import 'widgets/terms_policy_widget.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _isResendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChange(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _submitOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    _checkAllFieldsFilled();
  }

  void _checkAllFieldsFilled() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      // Small delay before auto-submit
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _submitOtp();
      });
    }
  }

  Future<void> _submitOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phoneNumber = widget.phoneNumber;

      final result = await authProvider.verifyOtp(phoneNumber, otp);

      if (result['success'] == true) {
        HapticFeedback.selectionClick();

        if (mounted) {
          final isNewUser = result['isNewUser'] ?? false;

          if (!isNewUser) {
            // Navigate to HomePage if profile is complete
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const RootView(),
              ),
              (route) => false, // Remove all previous routes
            );
          } else {
            // Navigate to RegistrationPage if profile is incomplete
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationPage(
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          // Show specific error message
          final errorMessage =
              result['error'] ?? 'Invalid OTP. Please try again.';
          _showError(errorMessage);
          _clearOtp();

          // Add haptic feedback for error
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Something went wrong. Please try again.');
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendCode() async {
    if (!_isResendEnabled) return;

    HapticFeedback.selectionClick();

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP code resent successfully'),
            backgroundColor: ESXColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to resend code. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ESXColors.background,
      appBar: AppBar(
        backgroundColor: ESXColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ESXColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Phone Verification",
          style: ESXTextStyles.heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Verification Header
            VerificationHeaderWidget(phoneNumber: widget.phoneNumber),

            const SizedBox(height: 40),

            // OTP Input Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ESXColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // OTP Input Boxes
                  OtpInputWidget(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onOtpChange: _onOtpChange,
                  ),

                  const SizedBox(height: 24),

                  // Resend Code Section
                  ResendCodeWidget(
                    isResendEnabled: _isResendEnabled,
                    resendTimer: _resendTimer,
                    onResendCode: _resendCode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ESXColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                        "Verify & Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Alternative Options
            const AlternativeOptionsWidget(),

            const SizedBox(height: 40),

            // Terms and Policy
            const TermsPolicyWidget(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
