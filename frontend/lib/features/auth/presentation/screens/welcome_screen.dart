import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';

const _statusBar = 50.0;

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    background: AppGradients.celebration,
    halos: AppHalos.welcome,
    bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
    footer: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: AuthStrings.createAccount,
          trailingIcon: AppIcons.arrowRight,
          onPressed: () {
            ref.read(authControllerProvider.notifier).reset();
            unawaited(context.pushNamed(RouteNames.registerPhone));
          },
        ),
        const SizedBox(height: 8),
        TextLinkButton(
          label: AuthStrings.existingAccount,
          style: AppTypography.textAction,
          onPressed: () {
            ref
                .read(authControllerProvider.notifier)
                .reset(purpose: VerificationPurpose.registration);
            unawaited(context.pushNamed(RouteNames.login));
          },
        ),
        const SizedBox(height: 8),
        const _Legal(),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FrameCanvas(
          height: 462 - _statusBar,
          originY: _statusBar,
          builder: (origin) => [
            FramePositioned(
              rect: const FrameRect(45, 118, 300, 300),
              origin: origin,
              child: const GlowDisc(middleStop: 0.6),
            ),
            FramePositioned(
              rect: const FrameRect(29, 102, 332, 332),
              origin: origin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            FramePositioned(
              rect: const FrameRect(69, 142, 252, 252),
              origin: origin,
              child: Image.asset(
                'assets/images/access/orbit-welcome.png',
                fit: BoxFit.fill,
              ),
            ),
            for (final (rect, color) in const [
              (FrameRect(350.5, 245.5, 9, 9), Color(0xFF5B4FE0)),
              (FrameRect(29.5, 210.5, 7, 7), Color(0xFF17A968)),
              (FrameRect(193, 95, 6, 6), Color(0xFFE2701F)),
            ])
              FramePositioned(
                rect: rect,
                origin: origin,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        color: color.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                ),
              ),
            FramePositioned(
              rect: const FrameRect(147, 424, 96, 14),
              origin: origin,
              child: const BlurredEllipse(color: Color(0x383A3190), blur: 4),
            ),
            FramePositioned(
              rect: const FrameRect(7, 256, 376, 175),
              origin: origin,
              child: Image.asset(
                'assets/images/access/welcome.png',
                fit: BoxFit.cover,
              ),
            ),
            FramePositioned(
              rect: const FrameRect(18, 133, 198.27, 62.82),
              origin: origin,
              child: const _TaskChip(
                angle: -5,
                icon: AppIcons.cook,
                iconBackground: Color(0xFFFFF8E8),
                title: AuthStrings.dinner,
                subtitle: AuthStrings.dinnerDetails,
              ),
            ),
            FramePositioned(
              rect: const FrameRect(202.79, 196, 172.8, 57.75),
              origin: origin,
              child: const _TaskChip(
                angle: 4,
                icon: AppIcons.paw,
                iconBackground: Color(0xFFFDF0F6),
                title: AuthStrings.dogWalk,
                subtitle: AuthStrings.dogDetails,
              ),
            ),
            for (final spark in const [
              Spark(330, 140, 18, Color(0xFFF0BC4E)),
              Spark(44, 246, 14, Color(0xFF9AA4F4)),
              Spark(176, 132, 10, Color(0xFF5FD79B)),
              Spark(352, 300, 9, Color(0xFFE98BB4)),
            ])
              FramePositioned(
                rect: FrameRect(spark.left, spark.top, spark.size, spark.size),
                origin: origin,
                child: Sparkle(color: spark.color),
              ),
            FramePositioned(
              rect: const FrameRect(131, 60, 128, 28),
              origin: origin,
              child: const _Brand(),
            ),
          ],
        ),
        const _HeroTitle(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            AuthStrings.welcomeBody,
            textAlign: TextAlign.center,
            style: AppTypography.introduction.copyWith(
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: AppStrings.appName,
    excludeSemantics: true,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.logo),
          const SizedBox(width: 8),
          Text(
            AppStrings.appName,
            textScaler: TextScaler.noScaling,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.44,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({
    required this.angle,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });
  final double angle;
  final AppIcons icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => OverflowBox(
    maxWidth: double.infinity,
    maxHeight: double.infinity,
    child: Transform.rotate(
      angle: angle * pi / 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 10),
              blurRadius: 24,
              color: Color(0x1A1E1A5E),
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
              padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(icon),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textScaler: TextScaler.noScaling,
                        style: AppTypography.labelLarge.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        textScaler: TextScaler.noScaling,
                        style: AppTypography.dataSmall.copyWith(
                          fontSize: 10.5,
                          height: 13 / 10.5,
                        ),
                      ),
                    ],
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

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();
  @override
  Widget build(BuildContext context) {
    const title = AccentTitle(
      text: AuthStrings.welcomeStart,
      accent: AuthStrings.welcomeAccent,
      centered: true,
      size: AccentTitleSize.hero,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = AppTypography.hero.copyWith(
          fontSize: 50,
          height: 52 / 50,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
        );
        final accentStyle = AppTypography.accent.copyWith(
          fontSize: 62,
          height: 52 / 62,
          letterSpacing: -0.62,
        );
        final painter = TextPainter(
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: AuthStrings.welcomeStart),
              TextSpan(text: AuthStrings.welcomeAccent, style: accentStyle),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final start = AuthStrings.welcomeStart.length;
        final boxes = painter.getBoxesForSelection(
          TextSelection(
            baseOffset: start,
            extentOffset: start + AuthStrings.welcomeAccent.length,
          ),
        );
        painter.dispose();
        if (boxes.isEmpty) return title;
        final word = boxes.last.toRect();
        return Stack(
          clipBehavior: Clip.none,
          children: [
            title,
            Positioned(
              left: word.left + 4,
              width: max(word.width - 4, 0),
              top: word.bottom - 4,
              height: 16,
              child: ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/illustrations/underline.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Legal extends StatelessWidget {
  const _Legal();
  @override
  Widget build(BuildContext context) {
    const underline = TextStyle(decoration: TextDecoration.underline);
    return Text.rich(
      const TextSpan(
        children: [
          TextSpan(text: AuthStrings.legalStart),
          TextSpan(text: AuthStrings.legalTerms, style: underline),
          TextSpan(text: AuthStrings.legalJoin),
          TextSpan(text: AuthStrings.legalPrivacy, style: underline),
          TextSpan(text: AuthStrings.legalEnd),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        decorationColor: AppColors.textTertiary,
      ),
    );
  }
}
