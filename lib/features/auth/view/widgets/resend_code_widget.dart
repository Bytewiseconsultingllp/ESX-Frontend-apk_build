import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class ResendCodeWidget extends StatelessWidget {
  final bool isResendEnabled;
  final int resendTimer;
  final VoidCallback onResendCode;

  const ResendCodeWidget({
    super.key,
    required this.isResendEnabled,
    required this.resendTimer,
    required this.onResendCode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: ESXTextStyles.body.copyWith(
            color: ESXColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: isResendEnabled ? onResendCode : null,
          child: Text(
            isResendEnabled
                ? "Resend Code"
                : "Resend in ${resendTimer}s",
            style: TextStyle(
              color: isResendEnabled
                  ? ESXColors.primary
                  : ESXColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: isResendEnabled
                  ? TextDecoration.underline
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}