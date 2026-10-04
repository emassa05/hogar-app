import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../validation/validators.dart';
import 'app_icon.dart';
import 'app_text_field.dart';

String displayPhone(String phone) =>
    phone.startsWith(PhoneValidator.defaultCountryCode)
    ? '${PhoneValidator.defaultCountryCode} ${ChileanPhoneFormatter.format(phone.substring(PhoneValidator.defaultCountryCode.length))}'
    : phone;

class PhoneField extends StatelessWidget {
  const PhoneField({
    this.controller,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.focusNode,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    super.key,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: AppStrings.phone,
    controller: controller,
    onChanged: onChanged,
    errorText: errorText,
    helperText: helperText,
    helperIcon: helperText == null ? null : AppIcons.shieldCheck,
    enabled: enabled,
    focusNode: focusNode,
    onSubmitted: onSubmitted,
    keyboardType: TextInputType.phone,
    textInputAction: textInputAction,
    autofillHints: const [AutofillHints.telephoneNumberNational],
    inputFormatters: [ChileanPhoneFormatter()],
    validator: PhoneValidator.validate,
    prefix: Semantics(
      label: AppStrings.countryChile,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.flagChile),
          const SizedBox(width: 10),
          Text(
            PhoneValidator.defaultCountryCode,
            style: AppTypography.fieldInput.copyWith(
              fontSize: 16,
              letterSpacing: 0,
              color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            height: 24,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    ),
  );
}

class ChileanPhoneFormatter extends TextInputFormatter {
  static String format(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index == 1 || index == 5) buffer.write(' ');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 9 && raw.startsWith('56')
        ? raw.substring(2)
        : raw;
    final limited = digits.length > 9 ? digits.substring(0, 9) : digits;
    final text = format(limited);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
