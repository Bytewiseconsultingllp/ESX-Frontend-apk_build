import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ESXColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
            'assets/icons/esx-logo.png',
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: 32),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [ESXColors.primary, ESXColors.tealColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            "Welcome Back",
            style: ESXTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your phone number to continue",
          style: ESXTextStyles.body.copyWith(
            color: ESXColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

