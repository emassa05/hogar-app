import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/motion/pressable_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../households/presentation/household_strings.dart';
import '../../domain/template_entities.dart';

typedef TemplateTone = (Color subtle, Color solid);

const _tones = <TemplateTone>[
  (AppColors.categoryTwoSubtle, AppColors.categoryTwo),
  (AppColors.categoryThreeSubtle, AppColors.categoryThree),
  (AppColors.categoryOneSubtle, AppColors.categoryOne),
  (AppColors.categorySixSubtle, AppColors.categorySix),
  (AppColors.categoryFourSubtle, AppColors.categoryFour),
];

AppIcons templateIcon(String key) {
  if (key.contains('pet')) return AppIcons.pawOutline;
  if (key.contains('famil') || key.contains('child')) return AppIcons.baby;
  if (key.contains('care')) return AppIcons.handHeart;
  if (key.contains('couple')) return AppIcons.heart;
  if (key.contains('share') || key.contains('flat') || key.contains('room')) {
    return AppIcons.building;
  }
  return AppIcons.template;
}

TemplateTone templateTone(String key, int index) {
  if (key.contains('pet')) return _tones[1];
  if (key.contains('famil') || key.contains('child')) return _tones[0];
  return _tones[index % _tones.length];
}

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    required this.template,
    required this.index,
    required this.selected,
    this.onToggle,
    super.key,
  });
  final TemplateSummary template;
  final int index;
  final bool selected;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final (subtle, solid) = templateTone(template.key, index);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : MotionTokens.press;
    return Semantics(
      checked: selected,
      enabled: onToggle != null,
      label:
          '${template.name}, ${HouseholdStrings.taskCount(template.taskCount)}',
      excludeSemantics: true,
      child: PressableScale(
        enabled: onToggle != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle == null
              ? null
              : () {
                  unawaited(AppHaptics.selection());
                  onToggle!();
                },
          child: AnimatedContainer(
            duration: duration,
            constraints: const BoxConstraints(minHeight: 114),
            padding: EdgeInsets.all(selected ? 13.5 : 14),
            decoration: BoxDecoration(
              color: selected ? subtle : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: selected ? solid : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.surface : AppColors.sunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppIcon(
                        templateIcon(template.key),
                        size: 18,
                        color: selected ? solid : AppColors.iconSecondary,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: duration,
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? solid : AppColors.surface,
                        borderRadius: BorderRadius.circular(7),
                        border: selected
                            ? null
                            : Border.all(
                                color: AppColors.borderStrong,
                                width: 1.5,
                              ),
                      ),
                      child: AnimatedScale(
                        duration: duration,
                        curve: MotionTokens.easeOut,
                        scale: selected ? 1 : 0,
                        child: const AppIcon(
                          AppIcons.checkBox,
                          color: AppColors.inverse,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(template.name, style: AppTypography.titleSmall),
                const SizedBox(height: 2),
                Text(
                  HouseholdStrings.taskCount(template.taskCount),
                  style: AppTypography.dataSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TemplateTaskRow extends StatelessWidget {
  const TemplateTaskRow({required this.task, required this.color, super.key});
  final TemplateTask task;
  final Color color;
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name, style: AppTypography.bodyMediumStrong),
                const SizedBox(height: 2),
                Text(
                  '${task.recurrenceLabel} · ${task.distribution == TaskDistribution.rotating ? HouseholdStrings.rotating : HouseholdStrings.fixed}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
