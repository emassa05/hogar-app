import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../validation/validators.dart';

class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({required this.password, super.key});
  final String password;
  @override
  Widget build(BuildContext context) {
    final rules = PasswordRules(password);
    final items = [
      (AppStrings.passwordMinimum, rules.hasLength),
      (AppStrings.passwordCapital, rules.hasUppercase),
      (AppStrings.passwordNumber, rules.hasDigitOrSymbol),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: index < rules.score
                      ? AppColors.successSurface
                      : AppColors.neutral,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          children: [
            Text(
              AppStrings.safePassword,
              style: AppTypography.labelLarge.copyWith(
                color: rules.isValid
                    ? AppColors.success
                    : AppColors.textTertiary,
              ),
            ),
            Text(
              AppStrings.passwordScore(rules.score),
              style: AppTypography.dataSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (label, checked) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              label: label,
              checked: checked,
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: MotionTokens.press,
                      reverseDuration: MotionTokens.press,
                      child: Icon(
                        checked ? Icons.check_circle : Icons.circle_outlined,
                        key: ValueKey(checked),
                        color: checked
                            ? AppColors.successSurface
                            : AppColors.iconTertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label, style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
