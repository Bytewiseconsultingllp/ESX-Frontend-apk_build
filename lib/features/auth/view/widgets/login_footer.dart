import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextButton(
        //   onPressed: () {
        //     HapticFeedback.selectionClick();
        //   },
        //   child: Text.rich(
        //     TextSpan(
        //       text: "Don't have an account? ",
        //       style: ESXTextStyles.body.copyWith(
        //         color: ESXColors.textSecondary,
        //       ),
        //       children: [
        //         TextSpan(
        //           text: "Create Account",
        //           style: ESXTextStyles.link.copyWith(
        //             fontWeight: FontWeight.w600,
        //             color: ESXColors.primary,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ESXColors.lightGreyColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              text: "By continuing, you agree to our ",
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
        ),
      ],
    );
  }
}
