import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/auth_entities.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/screens/account_created_screen.dart';
import '../../features/auth/presentation/screens/character_screen.dart';
import '../../features/auth/presentation/screens/code_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/name_screen.dart';
import '../../features/auth/presentation/screens/password_screen.dart';
import '../../features/auth/presentation/screens/phone_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/capacity/presentation/screens/capacity_screen.dart';
import '../../features/households/presentation/screens/home_placeholder_screen.dart';
import '../../features/households/presentation/screens/household_choice_screen.dart';
import '../../features/households/presentation/screens/household_create_screen.dart';
import '../../features/households/presentation/screens/household_edit_screen.dart';
import '../../features/households/presentation/screens/household_invite_screen.dart';
import '../../features/households/presentation/screens/household_join_screen.dart';
import '../../features/households/presentation/screens/household_settings_screen.dart';
import '../../features/households/presentation/screens/household_switch_screen.dart';
import '../../features/profile/presentation/screens/availability_screen.dart';
import '../../features/profile/presentation/screens/member_profile_screen.dart';
import '../../features/profile/presentation/screens/preferences_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/templates/presentation/screens/templates_screen.dart';
import '../l10n/app_strings.dart';
import '../session/session_controller.dart';
import '../session/session_state.dart';
import '../validation/validators.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/step_header.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionControllerProvider, (previous, next) => refresh.update());
  ref.listen(authControllerProvider, (previous, next) => refresh.update());
  final routes = <String, (String, String)>{
    RouteNames.capacity: ('/households/:householdId/capacity', AppStrings.home),
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
    RouteNames.householdSettings: ('/households/settings', AppStrings.home),
    RouteNames.householdSwitch: ('/households/switch', AppStrings.home),
    RouteNames.memberProfile: (
      '/households/:householdId/members/:userId/profile',
      AppStrings.profile,
    ),
    RouteNames.profileEdit: (
      '/households/:householdId/profile/edit',
      AppStrings.profile,
    ),
    RouteNames.householdEdit: (
      '/households/:householdId/settings/edit',
      AppStrings.home,
    ),
    RouteNames.settingsInvite: (
      '/households/:householdId/settings/invite',
      AppStrings.home,
    ),
  };
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, location) {
      final session = ref.read(sessionControllerProvider);
      final flow = ref.read(authControllerProvider);
      final path = location.uri.path;
      if (session.status == SessionStatus.restoring) return null;
      final protected = path.startsWith('/households') || path == '/home';
      final destination = session.user?.activeHouseholdId == null
          ? '/households/start'
          : '/home';
      if (!session.isAuthenticated &&
          (protected || path == '/account-created')) {
        return '/';
      }
      if (session.isAuthenticated && !protected) {
        if (flow.accountCreated) {
          return path == '/account-created' ? null : '/account-created';
        }
        return destination;
      }
      if (path.startsWith('/register/') && path != '/register/phone') {
        if (flow.purpose != VerificationPurpose.registration ||
            flow.verification == null) {
          return '/register/phone';
        }
        if (path != '/register/code' && flow.proof == null) {
          return '/register/phone';
        }
        if ((path == '/register/name' || path == '/register/character') &&
            PasswordValidator.validate(flow.password) != null) {
          return '/register/password';
        }
        if (path == '/register/character' &&
            NameValidator.validate(flow.name) != null) {
          return '/register/name';
        }
      }
      if (path == '/recover/code' &&
          (flow.purpose != VerificationPurpose.passwordReset ||
              flow.verification == null)) {
        return '/recover/phone';
      }
      if (path == '/recover/password' &&
          (flow.purpose != VerificationPurpose.passwordReset ||
              flow.proof == null)) {
        return '/recover/phone';
      }
      return null;
    },
    errorBuilder: (context, state) =>
        const AppScaffold(child: Text(AppStrings.foundation)),
    routes: routes.entries
        .map(
          (entry) => GoRoute(
            name: entry.key,
            path: entry.value.$1,
            builder: (context, state) => switch (entry.key) {
              RouteNames.capacity => CapacityScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.welcome => const WelcomeScreen(),
              RouteNames.registerPhone => const PhoneScreen(),
              RouteNames.registerCode => const CodeScreen(),
              RouteNames.registerPassword => const PasswordScreen(),
              RouteNames.registerName => const NameScreen(),
              RouteNames.registerCharacter => const CharacterScreen(),
              RouteNames.accountCreated => const AccountCreatedScreen(),
              RouteNames.login => const LoginScreen(),
              RouteNames.recoverPhone => const PhoneScreen(recovery: true),
              RouteNames.recoverCode => const CodeScreen(recovery: true),
              RouteNames.recoverPassword => const PasswordScreen(
                recovery: true,
              ),
              RouteNames.householdChoice => const HouseholdChoiceScreen(),
              RouteNames.householdCreate => const HouseholdCreateScreen(),
              RouteNames.householdJoin => const HouseholdJoinScreen(),
              RouteNames.householdInvite => HouseholdInviteScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.householdProfile => ProfileScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.householdAvailability => AvailabilityScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.householdPreferences => PreferencesScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.householdTemplates => TemplatesScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.home => const HomePlaceholderScreen(),
              RouteNames.householdSettings => const HouseholdSettingsScreen(),
              RouteNames.householdSwitch => const HouseholdSwitchScreen(),
              RouteNames.memberProfile => MemberProfileScreen(
                householdId: state.pathParameters['householdId']!,
                userId: state.pathParameters['userId']!,
              ),
              RouteNames.profileEdit => ProfileEditScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.householdEdit => HouseholdEditScreen(
                householdId: state.pathParameters['householdId']!,
              ),
              RouteNames.settingsInvite => HouseholdInviteScreen(
                householdId: state.pathParameters['householdId']!,
                settingsMode: true,
              ),
              _ => AppScaffold(
                header: StepHeader(title: entry.value.$2),
                child: const Text(AppStrings.foundation),
              ),
            },
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
