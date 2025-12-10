import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class AlternativeOptionsWidget extends StatelessWidget {
  const AlternativeOptionsWidget({super.key});

  Widget _buildAlternativeOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ESXColors.whiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ESXColors.lightGreyColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ESXColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: ESXColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallOption(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Calling you now...'),
        backgroundColor: ESXColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showEmailOption(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP sent to your email'),
        backgroundColor: ESXColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ESXColors.lightGreyColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Having trouble receiving the code?",
            style: ESXTextStyles.body.copyWith(
              color: ESXColors.textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAlternativeOption(
                icon: Icons.call,
                label: "Call Me",
                onTap: () => _showCallOption(context),
              ),
              Container(
                width: 1,
                height: 30,
                color: ESXColors.lightGreyColor,
              ),
              _buildAlternativeOption(
                icon: Icons.email,
                label: "Email OTP",
                onTap: () => _showEmailOption(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}