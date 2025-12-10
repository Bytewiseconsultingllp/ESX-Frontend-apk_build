import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class VerificationHeaderWidget extends StatelessWidget {
  final String phoneNumber;

  const VerificationHeaderWidget({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Verification Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ESXColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.verified_user,
            color: ESXColors.primary,
            size: 40,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          "Enter Verification Code",
          style: ESXTextStyles.heading.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Description
        Text.rich(
          TextSpan(
            text: "We've sent a 6-digit verification code to\n",
            style: ESXTextStyles.body.copyWith(
              color: ESXColors.textSecondary,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: phoneNumber,
                style: const TextStyle(
                  color: ESXColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}