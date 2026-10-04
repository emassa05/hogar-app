import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/errors/app_exception.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_buttons.dart';
import 'core/widgets/app_scaffold.dart';
import 'core/widgets/error_banner.dart';
import 'features/auth/presentation/session_bootstrap.dart';

class HogarApp extends ConsumerWidget {
  const HogarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(sessionBootstrapProvider);
    if (!startup.hasValue) {
      return MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'CL'),
        supportedLocales: const [Locale('es', 'CL')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.light,
        home: AppScaffold(
          child: startup.hasError
              ? Column(
                  children: [
                    ErrorBanner(
                      error: startup.error is AppException
                          ? startup.error! as AppException
                          : const UnexpectedException(),
                      onRetry: () => ref.invalidate(sessionBootstrapProvider),
                    ),
                    TextLinkButton(
                      label: AppStrings.login,
                      onPressed: () => unawaited(_clearSession(ref)),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CL'),
      supportedLocales: const [Locale('es', 'CL')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }

  Future<void> _clearSession(WidgetRef ref) async {
    try {
      await ref.read(sessionControllerProvider.notifier).expire();
    } on Object {
      return;
    }
    ref.invalidate(sessionBootstrapProvider);
  }
}
