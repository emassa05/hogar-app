import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../validation/validators.dart';
import 'app_text_field.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({
    this.controller,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: AppStrings.phone,
    controller: controller,
    onChanged: onChanged,
    errorText: errorText,
    enabled: enabled,
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.next,
    autofillHints: const [AutofillHints.telephoneNumberNational],
    validator: PhoneValidator.validate,
    prefix: Semantics(
      label: AppStrings.countryChile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 20,
                height: 14,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Colors.white),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 7,
                      child: ColoredBox(color: Color(0xFFD52B1E)),
                    ),
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: 8,
                      height: 7,
                      child: ColoredBox(
                        color: Color(0xFF0039A6),
                        child: Icon(Icons.star, size: 6, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('+56', style: AppTypography.bodyMedium),
            const SizedBox(width: 12),
            const SizedBox(
              height: 24,
              child: VerticalDivider(width: 1, color: AppColors.border),
            ),
          ],
        ),
      ),
    ),
  );
}
