import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class OtpInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String, int) onOtpChange;

  const OtpInputWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onOtpChange,
  });

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controllers[index].text.isNotEmpty
              ? ESXColors.primary
              : ESXColors.lightGreyColor,
          width: 2,
        ),
        color: controllers[index].text.isNotEmpty
            ? ESXColors.primary.withOpacity(0.05)
            : ESXColors.whiteColor,
      ),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: controllers[index].text.isNotEmpty
              ? ESXColors.primary
              : ESXColors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => onOtpChange(value, index),
        onTap: () {
          controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: controllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) => _buildOtpBox(i)),
    );
  }
}