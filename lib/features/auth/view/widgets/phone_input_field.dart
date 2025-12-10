import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController phoneController;
  final String countryCode;
  final List<Map<String, String>> countryCodes;
  final void Function(String) onCountryCodeChanged;
  final bool isPhoneValid;
  final String? Function(String?) validator;
  final String Function() getHintText;

  const PhoneInputField({
    super.key,
    required this.phoneController,
    required this.countryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    required this.isPhoneValid,
    required this.validator,
    required this.getHintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phone Number",
            style: ESXTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: ESXColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: ESXColors.lightGreyColor, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: countryCode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: ESXColors.primary),
                  items: countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(country['flag']!, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(country['code']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) onCountryCodeChanged(newValue);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    hintText: getHintText(),
                    hintStyle: TextStyle(color: ESXColors.textSecondary.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ESXColors.lightGreyColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ESXColors.lightGreyColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ESXColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    suffixIcon: isPhoneValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
