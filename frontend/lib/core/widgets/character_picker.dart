import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/app_haptics.dart';
import '../motion/pressable_scale.dart';
import '../session/session_user.dart';
import '../theme/app_typography.dart';
import 'avatar_circle.dart';

class CharacterPicker extends StatelessWidget {
  const CharacterPicker({
    required this.onSelected,
    this.selected,
    this.enabled = true,
    super.key,
  });
  final ValueChanged<AvatarChoice> onSelected;
  final AvatarChoice? selected;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        AppStrings.characterPicker,
        style: AppTypography.dataSmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 28,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: AvatarChoice.values
            .map(
              (avatar) => Semantics(
                button: true,
                selected: avatar == selected,
                label: AppStrings.character(AvatarCircle.names[avatar]!),
                child: ExcludeSemantics(
                  child: PressableScale(
                    enabled: enabled,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: enabled
                          ? () {
                              unawaited(AppHaptics.selection());
                              onSelected(avatar);
                            }
                          : null,
                      child: AvatarCircle(
                        avatar: avatar,
                        size: 72,
                        selected: avatar == selected,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}
