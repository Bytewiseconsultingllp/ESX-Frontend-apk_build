import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class TermsPolicyWidget extends StatelessWidget {
  const TermsPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ESXColors.lightGreyColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          text: "By verifying, you agree to our ",
          style: ESXTextStyles.footer.copyWith(
            fontSize: 12,
            color: ESXColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: ESXColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: ESXColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}