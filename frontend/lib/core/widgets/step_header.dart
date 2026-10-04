import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/motion_tokens.dart';
import '../motion/pressable_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({
    this.title = '',
    this.step,
    this.total,
    this.onBack,
    this.trailing,
    super.key,
  }) : assert(
         (step == null && total == null) ||
             (step != null && total != null && step > 0 && step <= total),
       );
  final String title;
  final int? step;
  final int? total;
  final VoidCallback? onBack;
  final Widget? trailing;

  Widget _segment(BuildContext context, int index) => Expanded(
    child: Padding(
      padding: EdgeInsets.only(right: index == total! - 1 ? 0 : 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          height: 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.borderSubtle),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: index == step! - 1 ? 0 : (index < step! ? 1 : 0),
                  end: index < step! ? 1 : 0,
                ),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : MotionTokens.entrance,
                curve: MotionTokens.easeOut,
                builder: (context, value, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: child,
                ),
                child: const ColoredBox(color: AppColors.brand),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final progress = step == null
        ? null
        : Text(AppStrings.step(step!, total!), style: AppTypography.dataSmall);
    final large = MediaQuery.textScalerOf(context).scale(14) > 20;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        onBack == null ? 20 : 16,
        2,
        20,
        step == null ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                if (onBack != null) ...[
                  HeaderIconButton(
                    icon: AppIcons.chevronLeft,
                    tooltip: AppStrings.back,
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: AppTypography.titleMedium),
                      ),
                      if (large && progress != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: progress,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                if (!large && progress != null) ...[
                  const SizedBox(width: 12),
                  progress,
                ],
              ],
            ),
          ),
          if (step != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.only(left: onBack == null ? 0 : 4),
              child: Semantics(
                label: AppStrings.step(step!, total!),
                child: ExcludeSemantics(
                  child: Row(
                    children: List.generate(
                      total!,
                      (index) => _segment(context, index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    super.key,
  });
  final AppIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      excludeSemantics: true,
      child: PressableScale(
        enabled: onPressed != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: AppIcon(
                  icon,
                  size: 20,
                  color: onPressed == null
                      ? AppColors.textDisabled
                      : AppColors.iconPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
