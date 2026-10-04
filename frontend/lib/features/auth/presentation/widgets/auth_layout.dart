import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/step_header.dart';
import '../auth_controller.dart';
import 'access_illustration.dart';

void authBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}

class AuthLayout extends ConsumerWidget {
  const AuthLayout({
    required this.title,
    required this.accent,
    required this.description,
    required this.child,
    required this.footer,
    this.scene,
    this.haloAccent = AppHalos.mint,
    this.recovery = false,
    this.step,
    this.onRetry,
    this.onBack,
    this.bannerError,
    this.contentGap = 24,
    this.topSpacing = 14,
    super.key,
  });
  final String title;
  final String accent;
  final InlineSpan description;
  final Widget child;
  final Widget footer;
  final AccessScene? scene;
  final Color haloAccent;
  final bool recovery;
  final int? step;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final AppException? bannerError;
  final double contentGap;
  final double topSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      authControllerProvider.select((state) => state.busy),
    );
    final illustrated =
        scene != null && MediaQuery.textScalerOf(context).scale(10) < 15;
    return PopScope(
      canPop: !busy,
      child: AppScaffold(
        halos: AppHalos.access(haloAccent),
        bodyPadding: EdgeInsets.fromLTRB(
          24,
          illustrated ? 0 : topSpacing,
          24,
          24,
        ),
        header: StepHeader(
          title: step == null
              ? ''
              : recovery
              ? AppStrings.recover
              : AppStrings.register,
          step: step,
          total: step == null
              ? null
              : recovery
              ? 3
              : 4,
          onBack: busy ? null : onBack ?? () => authBack(context),
        ),
        footer: footer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (illustrated) AccessIllustration(scene: scene!),
            AccentTitle(text: title, accent: accent),
            const SizedBox(height: 8),
            Text.rich(description, style: AppTypography.introduction),
            SizedBox(height: contentGap),
            child,
            if (bannerError != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(error: bannerError!, onRetry: busy ? null : onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

bool isNetworkOrServerError(AppException? error) =>
    error is NetworkException ||
    error is UnexpectedException ||
    (error is ApiException && error.statusCode >= 500);
