import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../validation/validators.dart';
import 'app_icon.dart';

class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({
    required this.password,
    this.showRules = true,
    super.key,
  });
  final String password;
  final bool showRules;
  @override
  Widget build(BuildContext context) {
    final rules = PasswordRules(password);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced ? Duration.zero : MotionTokens.entrance;
    final items = [
      (AppStrings.passwordMinimum, rules.hasLength),
      (AppStrings.passwordCapital, rules.hasUppercase),
      (AppStrings.passwordNumber, rules.hasDigitOrSymbol),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: duration,
                  curve: MotionTokens.easeOut,
                  height: 6,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < rules.score
                        ? AppColors.borderSuccess
                        : AppColors.neutral,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          label:
              '${AppStrings.safePassword}: ${AppStrings.passwordScore(rules.score)}',
          excludeSemantics: true,
          child: Row(
            children: [
              AppIcon(
                AppIcons.shieldCheck,
                color: rules.isValid
                    ? AppColors.iconSuccess
                    : AppColors.iconTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.safePassword,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: rules.isValid
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                AppStrings.passwordScore(rules.score),
                style: AppTypography.dataSmall,
              ),
            ],
          ),
        ),
        if (showRules) ...[
          const SizedBox(height: 16),
          for (final (index, (label, checked)) in items.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
              child: Semantics(
                label: label,
                checked: checked,
                excludeSemantics: true,
                child: Row(
                  children: [
                    _RuleMark(checked: checked, duration: duration),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label, style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _RuleMark extends StatelessWidget {
  const _RuleMark({required this.checked, required this.duration});
  final bool checked;
  final Duration duration;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: duration,
    curve: MotionTokens.easeOut,
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: checked ? AppColors.successSurface : AppColors.surface,
      border: Border.all(
        color: checked ? AppColors.successSurface : AppColors.border,
        width: 1.5,
      ),
    ),
    child: AnimatedScale(
      duration: duration,
      curve: MotionTokens.easeOut,
      scale: checked ? 1 : 0,
      child: const AppIcon(AppIcons.check, color: AppColors.inverse),
    ),
  );
}
