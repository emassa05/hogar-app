import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/step_header.dart';

void householdBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.goNamed(RouteNames.householdChoice);
  }
}

class HouseholdLayout extends StatelessWidget {
  const HouseholdLayout({
    required this.title,
    required this.child,
    this.footer,
    this.step,
    this.trailing,
    this.onBack,
    this.busy = false,
    this.showBack = true,
    super.key,
  });
  final String title;
  final Widget child;
  final Widget? footer;
  final int? step;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool busy;
  final bool showBack;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AppScaffold(
      variant: ScaffoldVariant.household,
      header: StepHeader(
        title: title,
        step: step,
        total: step == null ? null : 3,
        trailing: trailing,
        onBack: !showBack || busy
            ? null
            : onBack ?? () => householdBack(context),
      ),
      footer: footer,
      child: child,
    ),
  );
}

class ScreenIntro extends StatelessWidget {
  const ScreenIntro({required this.title, required this.body, super.key});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: AppTypography.titleLarge),
      ),
      const SizedBox(height: 18),
      Text(body, style: AppTypography.bodySmall.copyWith(height: 18 / 13)),
    ],
  );
}

class SaveFeedback extends StatelessWidget {
  const SaveFeedback({
    required this.error,
    required this.savedPart,
    this.onRetry,
    super.key,
  });
  final AppException? error;
  final String savedPart;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (savedPart.isNotEmpty) ...[
        InfoBanner(message: savedPart, tone: BannerTone.warning),
        const SizedBox(height: 12),
      ],
      if (error != null) ErrorBanner(error: error!, onRetry: onRetry),
    ],
  );
}

class FooterActions extends StatelessWidget {
  const FooterActions({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(10) >= 15;
    if (large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(height: 10),
            child,
          ],
        ],
      );
    }
    return Row(
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ],
    );
  }
}

class LoadPlaceholder extends StatelessWidget {
  const LoadPlaceholder({
    required this.error,
    required this.onRetry,
    super.key,
  });
  final AppException? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => error == null
      ? Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Semantics(
              label: AppStrings.loading,
              child: const CircularProgressIndicator(),
            ),
          ),
        )
      : ErrorBanner(error: error!, onRetry: onRetry);
}

AppException asAppException(Object? error) =>
    error is AppException ? error : const UnexpectedException();
