import 'dart:async';

import 'package:flutter/material.dart' hide DayPeriod;

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../households/presentation/household_strings.dart';
import '../../domain/profile_entities.dart';

String slotKey(int weekday, DayPeriod period) => '$weekday:${period.name}';

class AvailabilityGrid extends StatelessWidget {
  const AvailabilityGrid({
    required this.selected,
    required this.onToggle,
    this.enabled = true,
    super.key,
  });
  final Set<String> selected;
  final void Function(int weekday, DayPeriod period) onToggle;
  final bool enabled;

  static const _periods = [
    (DayPeriod.morning, HouseholdStrings.morning),
    (DayPeriod.afternoon, HouseholdStrings.afternoon),
    (DayPeriod.evening, HouseholdStrings.evening),
  ];

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : MotionTokens.press;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 22),
                    for (final (_, label) in _periods)
                      SizedBox(
                        height: 32,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ExcludeSemantics(
                            child: Text(
                              label,
                              textScaler: TextScaler.noScaling,
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 22,
                        child: ExcludeSemantics(
                          child: Text(
                            HouseholdStrings.weekdayLetters[weekday],
                            textScaler: TextScaler.noScaling,
                            style: AppTypography.labelMedium,
                          ),
                        ),
                      ),
                      for (final (period, label) in _periods)
                        _Cell(
                          on: selected.contains(slotKey(weekday, period)),
                          duration: duration,
                          label:
                              '${HouseholdStrings.weekdays[weekday]}, ${label.toLowerCase()}',
                          onTap: enabled
                              ? () {
                                  unawaited(AppHaptics.selection());
                                  onToggle(weekday, period);
                                }
                              : null,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Legend(
                label: HouseholdStrings.available,
                dot: BoxDecoration(
                  color: AppColors.categoryOne,
                  shape: BoxShape.circle,
                ),
              ),
              _Legend(
                label: HouseholdStrings.unavailable,
                dot: BoxDecoration(
                  color: AppColors.sunken,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              ),
              const Text(
                HouseholdStrings.periodHelp,
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.on,
    required this.duration,
    required this.label,
    this.onTap,
  });
  final bool on;
  final Duration duration;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    toggled: on,
    enabled: onTap != null,
    label: label,
    value: on ? HouseholdStrings.available : HouseholdStrings.unavailable,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 32,
        child: Center(
          child: AnimatedContainer(
            duration: duration,
            curve: MotionTokens.easeOut,
            width: 30,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppColors.categoryOne : AppColors.sunken,
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(
                color: on ? AppColors.categoryOne : AppColors.border,
              ),
            ),
            child: AnimatedScale(
              duration: duration,
              curve: MotionTokens.easeOut,
              scale: on ? 1 : 0,
              child: const AppIcon(
                AppIcons.checkSmall,
                color: AppColors.inverse,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.dot});
  final String label;
  final BoxDecoration dot;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 9, height: 9, decoration: dot),
      const SizedBox(width: 6),
      Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}
