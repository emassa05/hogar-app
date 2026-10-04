import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hogar_app/core/router/route_names.dart';
import 'package:hogar_app/core/theme/app_theme.dart';

import 'fake_http_adapter.dart';
import 'n2_harness.dart';

const _destinations = {
  RouteNames.householdCreate: '/households/create',
  RouteNames.householdJoin: '/households/join',
  RouteNames.householdChoice: '/households/start',
  RouteNames.householdInvite: '/households/:householdId/invite',
  RouteNames.householdProfile: '/households/:householdId/profile',
  RouteNames.householdAvailability: '/households/:householdId/availability',
  RouteNames.householdPreferences: '/households/:householdId/preferences',
  RouteNames.householdTemplates: '/households/:householdId/templates',
  RouteNames.home: '/home',
};

class N2Screen {
  N2Screen(this.harness, this.router);
  final N2Harness harness;
  final GoRouter router;
  String get location =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
}

Future<void> settle(WidgetTester tester) async {
  for (var round = 0; round < 4; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<N2Screen> pumpN2Screen(
  WidgetTester tester,
  Widget screen,
  HttpResponder respond, {
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final harness = N2Harness(respond);
  addTearDown(harness.dispose);
  await tester.runAsync(harness.signIn);
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(path: '/screen', builder: (context, state) => screen),
      for (final entry in _destinations.entries)
        GoRoute(
          name: entry.key,
          path: entry.value,
          builder: (context, state) => Scaffold(body: Text(entry.key)),
        ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: harness.container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    ),
  );
  await settle(tester);
  return N2Screen(harness, router);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}
