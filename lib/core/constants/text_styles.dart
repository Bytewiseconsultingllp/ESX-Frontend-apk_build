import 'package:flutter/material.dart';
import 'colors.dart';

class ESXTextStyles {
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ESXColors.blackColor,
  );
  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ESXColors.greyColor,
  );
  static const body = TextStyle(
    fontSize: 16,
    color: ESXColors.textSecondary,
  );

  static const link = TextStyle(
    fontSize: 14,
    color: ESXColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static const footer = TextStyle(
    fontSize: 13,
    color: ESXColors.textSecondary,
  );
}
