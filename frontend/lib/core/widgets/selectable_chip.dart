import 'dart:async';

import 'package:flutter/material.dart';

import '../motion/app_haptics.dart';
import '../motion/motion_tokens.dart';
import '../motion/pressable_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

enum ChipTone { brand, success, danger }

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.label,
    required this.selected,
    this.onSelected,
    this.tone = ChipTone.brand,
    super.key,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final ChipTone tone;

  (Color, Color, Color) get _colors => switch (tone) {
    ChipTone.brand => (
      AppColors.brandSubtle,
      AppColors.borderSelected,
      AppColors.brand,
    ),
    ChipTone.success => (
      AppColors.successSubtle,
      AppColors.borderSuccess,
      AppColors.success,
    ),
    ChipTone.danger => (
      AppColors.dangerSubtle,
      AppColors.borderDanger,
      AppColors.danger,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = _colors;
    final enabled = onSelected != null;
    return Semantics(
      button: true,
      toggled: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        enabled: enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  unawaited(AppHaptics.selection());
                  onSelected!(!selected);
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              widthFactor: 1,
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : MotionTokens.press,
                constraints: const BoxConstraints(minHeight: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? background : AppColors.sunken,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: selected ? border : AppColors.sunken,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected) ...[
                      AppIcon(AppIcons.checkSmall, color: foreground),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: AppTypography.labelMedium.copyWith(
                          color: selected
                              ? foreground
                              : enabled
                              ? AppColors.textTertiary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
