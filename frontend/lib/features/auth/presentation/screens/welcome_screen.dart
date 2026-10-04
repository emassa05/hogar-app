import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    sky: true,
    footer: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: AuthStrings.createAccount,
          icon: Icons.arrow_forward,
          onPressed: () {
            ref.read(authControllerProvider.notifier).reset();
            unawaited(context.pushNamed(RouteNames.registerPhone));
          },
        ),
        const SizedBox(height: 8),
        TextLinkButton(
          label: AuthStrings.existingAccount,
          onPressed: () {
            ref
                .read(authControllerProvider.notifier)
                .reset(purpose: VerificationPurpose.registration);
            unawaited(context.pushNamed(RouteNames.login));
          },
        ),
        const SizedBox(height: 12),
        const Text(
          AuthStrings.legal,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.segment, color: AppColors.brand, size: 30),
            SizedBox(width: 8),
            Text(AppStrings.appName, style: AppTypography.titleLarge),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 330,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/welcome-seesaw.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              const Positioned(
                top: 24,
                left: 0,
                child: _TaskPreview(
                  icon: Icons.soup_kitchen_outlined,
                  title: AuthStrings.dinner,
                  subtitle: AuthStrings.dinnerDetails,
                ),
              ),
              const Positioned(
                top: 94,
                right: 0,
                child: _TaskPreview(
                  icon: Icons.pets_outlined,
                  title: AuthStrings.dogWalk,
                  subtitle: AuthStrings.dogDetails,
                ),
              ),
            ],
          ),
        ),
        const AccentTitle(
          text: AuthStrings.welcomeStart,
          accent: AuthStrings.welcomeAccent,
          centered: true,
          large: true,
        ),
        const SizedBox(height: 20),
        const Text(
          AuthStrings.welcomeBody,
          style: AppTypography.introduction,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    constraints: const BoxConstraints(maxWidth: 230),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      boxShadow: AppShadows.elevationMedium,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.brand),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              Text(subtitle, style: AppTypography.dataSmall),
            ],
          ),
        ),
      ],
    ),
  );
}
