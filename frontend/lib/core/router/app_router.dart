import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l10n/app_strings.dart';
import '../session/session_controller.dart';
import '../session/session_state.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/step_header.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionControllerProvider, (previous, next) => refresh.update());
  final routes = <String, (String, String)>{
    RouteNames.welcome: ('/', AppStrings.appName),
    RouteNames.registerPhone: ('/register/phone', AppStrings.register),
    RouteNames.registerCode: ('/register/code', AppStrings.register),
    RouteNames.registerPassword: ('/register/password', AppStrings.register),
    RouteNames.registerName: ('/register/name', AppStrings.register),
    RouteNames.registerCharacter: ('/register/character', AppStrings.register),
    RouteNames.accountCreated: ('/account-created', AppStrings.register),
    RouteNames.login: ('/login', AppStrings.login),
    RouteNames.recoverPhone: ('/recover/phone', AppStrings.recover),
    RouteNames.recoverCode: ('/recover/code', AppStrings.recover),
    RouteNames.recoverPassword: ('/recover/password', AppStrings.recover),
    RouteNames.householdChoice: (
      '/households/start',
      AppStrings.chooseHousehold,
    ),
    RouteNames.householdCreate: (
      '/households/create',
      AppStrings.chooseHousehold,
    ),
    RouteNames.householdInvite: (
      '/households/:householdId/invite',
      AppStrings.chooseHousehold,
    ),
    RouteNames.householdProfile: (
      '/households/:householdId/profile',
      AppStrings.profile,
    ),
    RouteNames.householdAvailability: (
      '/households/:householdId/availability',
      AppStrings.availability,
    ),
    RouteNames.householdPreferences: (
      '/households/:householdId/preferences',
      AppStrings.preferences,
    ),
    RouteNames.householdTemplates: (
      '/households/:householdId/templates',
      AppStrings.templates,
    ),
    RouteNames.householdJoin: ('/households/join', AppStrings.chooseHousehold),
    RouteNames.home: ('/home', AppStrings.home),
  };
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      if (session.status == SessionStatus.restoring) return null;
      final protected =
          state.uri.path.startsWith('/households') || state.uri.path == '/home';
      if (!session.isAuthenticated && protected) return '/';
      if (session.isAuthenticated &&
          !protected &&
          state.uri.path != '/account-created')
        return session.user?.activeHouseholdId == null
            ? '/households/start'
            : '/home';
      return null;
    },
    routes: routes.entries
        .map(
          (entry) => GoRoute(
            name: entry.key,
            path: entry.value.$1,
            builder: (context, state) => AppScaffold(
              header: StepHeader(title: entry.value.$2),
              child: Text(
                entry.key == RouteNames.home
                    ? AppStrings.comingSoon
                    : AppStrings.foundation,
              ),
            ),
          ),
        )
        .toList(),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}

class _RouterRefresh extends ChangeNotifier {
  void update() => notifyListeners();
}
