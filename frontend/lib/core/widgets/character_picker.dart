import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/app_haptics.dart';
import '../motion/pressable_scale.dart';
import '../session/session_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'avatar_circle.dart';
import 'section_label.dart';

class CharacterPicker extends StatelessWidget {
  const CharacterPicker({
    required this.onSelected,
    this.selected,
    this.enabled = true,
    this.showSelectionCheck = false,
    this.label,
    super.key,
  });
  final ValueChanged<AvatarChoice> onSelected;
  final AvatarChoice? selected;
  final bool enabled;
  final bool showSelectionCheck;
  final String? label;

  Widget _option(AvatarChoice avatar) => Semantics(
    button: true,
    inMutuallyExclusiveGroup: true,
    selected: avatar == selected,
    enabled: enabled,
    label: AppStrings.character(AvatarCircle.names[avatar]!),
    excludeSemantics: true,
    child: PressableScale(
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                unawaited(AppHaptics.selection());
                onSelected(avatar);
              }
            : null,
        child: Stack(
          children: [
            AvatarCircle(
              avatar: avatar,
              size: 72,
              borderWidth: 3,
              borderColor: avatar == selected
                  ? AppColors.brand
                  : AppColors.surface,
              shadows: AppShadows.avatarOption,
            ),
            if (showSelectionCheck && avatar == selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.inverse,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const choices = AvatarChoice.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label == null)
          const OverlineDivider(label: AppStrings.characterPicker)
        else
          Semantics(
            header: true,
            child: Text(label!, style: AppTypography.fieldLabel),
          ),
        const SizedBox(height: 16),
        for (var row = 0; row < choices.length; row += 3) ...[
          if (row > 0) const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = row; index < row + 3; index++) ...[
                if (index > row) const SizedBox(width: 28),
                _option(choices[index]),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
