import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/step_header.dart';
import '../auth_controller.dart';

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
    this.illustration,
    this.recovery = false,
    this.step,
    this.onRetry,
    this.onBack,
    this.sky = false,
    super.key,
  });
  final String title;
  final String accent;
  final String description;
  final Widget child;
  final Widget footer;
  final Widget? illustration;
  final bool recovery;
  final int? step;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final bool sky;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    return PopScope(
      canPop: !state.busy,
      child: AppScaffold(
        sky: sky,
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
          onBack: state.busy ? null : onBack ?? () => authBack(context),
        ),
        footer: footer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 12),
            ],
            AccentTitle(text: title, accent: accent),
            const SizedBox(height: 8),
            Text(description, style: AppTypography.introduction),
            const SizedBox(height: 24),
            child,
            if (state.error != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(
                error: state.error!,
                onRetry: state.busy ? null : onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
