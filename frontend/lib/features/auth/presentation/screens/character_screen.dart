import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/character_picker.dart';
import '../../../../core/widgets/phone_field.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
import '../widgets/auth_layout.dart';

const _origin = 202.0;
const _sky = Color(0xFF12A2BF);

class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  void _choose(WidgetRef ref, AvatarChoice avatar) {
    unawaited(AppHaptics.success());
    ref.read(authControllerProvider.notifier).chooseAvatar(avatar);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final avatar = state.avatar;
    final error = state.error;
    final expired =
        error is ApiException &&
        error.code == ApiErrorCode.invalidVerificationToken;
    return AuthLayout(
      step: 4,
      haloAccent: AppHalos.sky,
      contentGap: 0,
      title: avatar == null
          ? AuthStrings.characterTitle
          : AuthStrings.chosenTitle,
      accent: avatar == null
          ? AuthStrings.characterAccent
          : AuthStrings.chosenAccent,
      description: TextSpan(
        text: avatar == null
            ? AuthStrings.characterBody
            : AuthStrings.chosenBody,
      ),
      bannerError: error,
      onRetry: expired
          ? () => context.goNamed(RouteNames.registerPhone)
          : () => unawaited(controller.register(skipAvatar: avatar == null)),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: AuthStrings.createMyAccount,
            loading: state.busy && avatar != null,
            trailingIcon: avatar == null ? null : AppIcons.arrowRight,
            onPressed: avatar == null || expired
                ? null
                : () => unawaited(controller.register()),
          ),
          if (avatar == null)
            TextLinkButton(
              label: AuthStrings.skipCharacter,
              loading: state.busy,
              onPressed: expired
                  ? null
                  : () => unawaited(controller.register(skipAvatar: true)),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Preview(avatar: avatar),
          if (avatar == null)
            CharacterPicker(
              enabled: !state.busy,
              onSelected: (value) => _choose(ref, value),
            )
          else ...[
            MergeSemantics(
              child: Column(
                children: [
                  Text(
                    state.name,
                    style: AppTypography.displayName,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayPhone(state.verification?.phone ?? ''),
                    style: AppTypography.dataMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SecondaryButton(
              label: AuthStrings.changeCharacter,
              pill: true,
              expand: false,
              leadingIcon: AppIcons.refresh,
              onPressed: state.busy
                  ? null
                  : () => controller.chooseAvatar(null),
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.avatar});
  final AvatarChoice? avatar;

  @override
  Widget build(BuildContext context) {
    final chosen = avatar != null;
    return FrameCanvas(
      height: 262,
      originY: _origin,
      builder: (origin) => [
        FramePositioned(
          rect: const FrameRect(65, 226, 260, 240),
          origin: origin,
          child: const BlurredEllipse(color: Color(0xE6A5E3EF), blur: 30),
        ),
        FramePositioned(
          rect: const FrameRect(95, 246, 200, 200),
          origin: origin,
          child: chosen
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand.withValues(alpha: 0.9),
                      width: 2,
                    ),
                  ),
                )
              : Image.asset(
                  'assets/images/access/ring-sky.png',
                  fit: BoxFit.fill,
                ),
        ),
        FramePositioned(
          rect: const FrameRect(105, 256, 180, 180),
          origin: origin,
          child: chosen
              ? MotionReveal(
                  key: ValueKey(avatar),
                  delight: true,
                  child: AvatarCircle(
                    avatar: avatar,
                    size: 180,
                    borderWidth: 4,
                    shadows: AppShadows.avatarHero,
                  ),
                )
              : Semantics(
                  label: AuthStrings.noCharacter,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.avatarPreview,
                      border: Border.all(color: AppColors.surface, width: 4),
                      boxShadow: AppShadows.avatarHero,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '?',
                      textScaler: TextScaler.noScaling,
                      style: AppTypography.accent.copyWith(
                        fontSize: 104,
                        height: 1,
                        color: const Color(0x7312A2BF),
                      ),
                    ),
                  ),
                ),
        ),
        if (chosen)
          FramePositioned(
            rect: const FrameRect(238, 390, 48, 48),
            origin: origin,
            child: MotionReveal(
              key: ValueKey('badge-$avatar'),
              index: 4,
              delight: true,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successSurface,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: AppShadows.badge,
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.check,
                  size: 22,
                  color: AppColors.inverse,
                ),
              ),
            ),
          ),
        if (!chosen) ...[
          FramePositioned(
            rect: const FrameRect(300, 258, 14, 14),
            origin: origin,
            child: const Sparkle(color: _sky),
          ),
          FramePositioned(
            rect: const FrameRect(80, 396, 11, 11),
            origin: origin,
            child: const Sparkle(color: Color(0xFFF0BC4E)),
          ),
        ],
      ],
    );
  }
}
