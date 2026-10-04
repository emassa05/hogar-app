import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({
    required this.title,
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
                tween: Tween(end: index < step! ? 1 : 0),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : MotionTokens.entrance,
                curve: MotionTokens.easeOut,
                builder: (context, value, child) => Transform.scale(
                  scaleX: value,
                  alignment: Alignment.centerLeft,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: IconButton(
                  tooltip: AppStrings.back,
                  onPressed: onBack,
                  icon: const Icon(Icons.chevron_left),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  if (large && progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: progress,
                    ),
                ],
              ),
            ),
            if (!large && progress != null) ...[
              const SizedBox(width: 8),
              progress,
            ],
            if (trailing != null) trailing!,
          ],
        ),
        if (step != null) ...[
          const SizedBox(height: 12),
          Semantics(
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
        ],
      ],
    );
  }
}
