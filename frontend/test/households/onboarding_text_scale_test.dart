import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/features/households/presentation/screens/home_placeholder_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_choice_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_create_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_invite_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_join_screen.dart';
import 'package:hogar_app/features/profile/presentation/screens/availability_screen.dart';
import 'package:hogar_app/features/profile/presentation/screens/preferences_screen.dart';
import 'package:hogar_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:hogar_app/features/templates/presentation/screens/templates_screen.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

Future<ResponseBody> _respond(RequestOptions request) async {
  final path = request.path;
  if (path == '/households/household-1') return jsonResponse(householdJson());
  if (path.endsWith('/invitation')) return jsonResponse(invitationJson());
  if (path.endsWith('/members/me/profile')) {
    return jsonResponse(
      profileJson(
        restrictions: [
          restrictionJson(kind: 'temporary', endsOn: '2027-03-30'),
        ],
      ),
    );
  }
  if (path == '/catalog/activities') return jsonResponse(activitiesJson());
  if (path == '/catalog/task-categories') return jsonResponse(categoriesJson());
  if (path == '/household-templates') {
    return jsonResponse([templateJson(), templateJson(key: 'pets', count: 6)]);
  }
  if (path.startsWith('/household-templates/')) {
    final key = path.split('/').last;
    return jsonResponse(templateJson(key: key, detail: true));
  }
  if (path.startsWith('/invitations/')) return jsonResponse(previewJson());
  if (path == '/households') return jsonResponse([summaryJson()]);
  return jsonResponse(<String, dynamic>{});
}

void main() {
  final screens = <String, Widget>{
    'A2': const HouseholdChoiceScreen(),
    'A3': const HouseholdCreateScreen(),
    'A4': const HouseholdInviteScreen(householdId: 'household-1'),
    'A5': const ProfileScreen(householdId: 'household-1'),
    'A6': const AvailabilityScreen(householdId: 'household-1'),
    'A7': const PreferencesScreen(householdId: 'household-1'),
    'A9': const TemplatesScreen(householdId: 'household-1'),
    'A10': const HouseholdJoinScreen(),
    'home': const HomePlaceholderScreen(),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key} lays out at 200 percent text', (tester) async {
      await pumpN2Screen(tester, entry.value, _respond, scale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
