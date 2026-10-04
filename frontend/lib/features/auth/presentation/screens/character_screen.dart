import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/character_picker.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_layout.dart';

class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final chosen = state.avatar != null;
    return AuthLayout(
      step: 4,
      sky: true,
      title: chosen ? AuthStrings.chosenTitle : AuthStrings.characterTitle,
      accent: chosen ? AuthStrings.chosenAccent : AuthStrings.characterAccent,
      description: chosen ? AuthStrings.chosenBody : AuthStrings.characterBody,
      onRetry: () => unawaited(controller.register()),
      footer: Column(
        children: [
          PrimaryButton(
            label: AuthStrings.createMyAccount,
            loading: state.busy,
            icon: Icons.arrow_forward,
            onPressed: chosen ? () => unawaited(controller.register()) : null,
          ),
          if (!chosen)
            TextLinkButton(
              label: AuthStrings.skipCharacter,
              loading: state.busy,
              onPressed: () => unawaited(controller.register(skipAvatar: true)),
            ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          MotionReveal(
            key: ValueKey(state.avatar),
            delight: chosen,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: chosen ? AppColors.brand : AppColors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  child: AvatarCircle(
                    avatar: state.avatar,
                    name: state.name,
                    size: 180,
                  ),
                ),
                if (chosen)
                  const Positioned(
                    right: 4,
                    bottom: 4,
                    child: CircleAvatar(
                      backgroundColor: AppColors.surface,
                      radius: 28,
                      child: CircleAvatar(
                        backgroundColor: AppColors.successSurface,
                        radius: 24,
                        child: Icon(Icons.check, color: AppColors.inverse),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (chosen) ...[
            Text(state.name, style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text(
              state.verification?.phone ?? '',
              style: AppTypography.dataSmall,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: AuthStrings.changeCharacter,
              icon: Icons.refresh,
              onPressed: state.busy
                  ? null
                  : () => controller.chooseAvatar(null),
            ),
          ] else ...[
            CharacterPicker(
              selected: state.avatar,
              enabled: !state.busy,
              onSelected: controller.chooseAvatar,
            ),
          ],
        ],
      ),
    );
  }
}
