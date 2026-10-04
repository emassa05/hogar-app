import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class HogarApp extends ConsumerWidget {
  const HogarApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: AppStrings.appName,
    debugShowCheckedModeBanner: false,
    locale: const Locale('es', 'CL'),
    supportedLocales: const [Locale('es', 'CL')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: AppTheme.light,
    routerConfig: ref.watch(appRouterProvider),
  );
}
