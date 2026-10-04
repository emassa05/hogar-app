import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/phone_field.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';

const _statusBar = 50.0;

class AccountCreatedScreen extends ConsumerStatefulWidget {
  const AccountCreatedScreen({super.key});
  @override
  ConsumerState<AccountCreatedScreen> createState() =>
      _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends ConsumerState<AccountCreatedScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(AppHaptics.success());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider).user;
    final name = user?.name ?? '';
    return AppScaffold(
      background: AppGradients.celebration,
      halos: AppHalos.celebration,
      bodyPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      footer: PrimaryButton(
        label: AuthStrings.start,
        trailingIcon: AppIcons.arrowRight,
        onPressed: () {
          ref.read(authControllerProvider.notifier).dismissCelebration();
          context.goNamed(RouteNames.householdChoice);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FrameCanvas(
            height: 374 - _statusBar,
            originY: _statusBar,
            builder: (origin) => [
              FramePositioned(
                rect: const FrameRect(0, 0, 390, 420),
                origin: origin,
                child: MotionReveal(
                  delight: true,
                  child: SvgPicture.asset(
                    'assets/illustrations/confetti.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              FramePositioned(
                rect: const FrameRect(40, 90, 310, 310),
                origin: origin,
                child: const GlowDisc(middleStop: 0.6, middleOpacity: 0.5),
              ),
              FramePositioned(
                rect: const FrameRect(25, 92, 340, 209),
                origin: origin,
                child: MotionReveal(
                  delight: true,
                  child: Image.asset(
                    'assets/images/access/celebrate.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              FramePositioned(
                rect: const FrameRect(0, 298, 390, 52),
                origin: origin,
                child: Center(
                  child: MotionReveal(
                    index: 3,
                    delight: true,
                    child: _ProfilePill(
                      name: name,
                      phone: displayPhone(user?.phone ?? ''),
                      avatar: AvatarCircle(
                        avatar: user?.avatar,
                        name: name,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AccentTitle(
            text: AuthStrings.createdTitle,
            accent: AuthStrings.createdAccent,
            suffix: '\n$name!',
            centered: true,
            size: AccentTitleSize.celebration,
          ),
          const SizedBox(height: 12),
          const Text(
            AuthStrings.createdBody,
            style: AppTypography.introduction,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const _NextSteps(),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({
    required this.name,
    required this.phone,
    required this.avatar,
  });
  final String name;
  final String phone;
  final Widget avatar;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 10),
          blurRadius: 26,
          color: Color(0x1F1E1A5E),
        ),
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 4,
          color: Color(0x0D1E1A5E),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              avatar,
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.noScaling,
                      style: AppTypography.cardTitle,
                    ),
                    Text(
                      phone,
                      textScaler: TextScaler.noScaling,
                      style: AppTypography.dataSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                label: AuthStrings.verified,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(
                    AppIcons.check,
                    size: 14,
                    color: AppColors.inverse,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NextSteps extends StatelessWidget {
  const _NextSteps();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
      boxShadow: AppShadows.card,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(AuthStrings.next, style: AppTypography.overline),
        ),
        for (var index = 0; index < AuthStrings.nextSteps.length; index++)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: MotionReveal(
              index: index + 4,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      textScaler: TextScaler.noScaling,
                      style: AppTypography.dataSmall.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AuthStrings.nextSteps[index],
                      style: AppTypography.bodyMediumStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
