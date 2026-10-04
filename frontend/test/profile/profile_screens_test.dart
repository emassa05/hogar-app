import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide DayPeriod;
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/router/route_names.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/profile/presentation/screens/availability_screen.dart';
import 'package:hogar_app/features/profile/presentation/screens/preferences_screen.dart';
import 'package:hogar_app/features/profile/presentation/screens/profile_screen.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

const _profilePath = '/households/household-1/members/me/profile';

Future<ResponseBody> Function(RequestOptions) _profileResponder(
  List<RequestOptions> writes, {
  Map<String, dynamic>? profile,
  ResponseBody Function(RequestOptions)? onWrite,
}) => (request) async {
  if (request.method != 'GET') {
    writes.add(request);
    if (onWrite != null) return onWrite(request);
  }
  if (request.path == _profilePath) {
    return jsonResponse(profile ?? profileJson());
  }
  if (request.path.endsWith('/availability')) {
    return jsonResponse(requestBody(request));
  }
  if (request.path.endsWith('/preferences')) {
    return jsonResponse(requestBody(request));
  }
  if (request.path.endsWith('/restrictions')) {
    return jsonResponse({
      ...restrictionJson(id: 'new', key: 'laundry', type: 'category'),
      'target_name': 'Ropa',
    }, 201);
  }
  if (request.path == '/catalog/activities') {
    return jsonResponse(activitiesJson());
  }
  if (request.path == '/catalog/task-categories') {
    return jsonResponse(categoriesJson());
  }
  if (request.path == '/households/household-1') {
    return jsonResponse(householdJson());
  }
  return jsonResponse(<String, dynamic>{});
};

void main() {
  testWidgets('A5 saves nickname and capacity without a free-text field', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const ProfileScreen(householdId: 'household-1'),
      _profileResponder(writes),
    );
    expect(find.text('Algo que el hogar deba saber'), findsNothing);
    expect(find.text(HouseholdStrings.capacityUnset), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'Martita');
    final slider = find.byType(Slider);
    await tester.ensureVisible(slider);
    await tester.tapAt(tester.getTopLeft(slider) + const Offset(80, 24));
    await tester.pump();
    expect(find.textContaining(' %'), findsOneWidget);
    await tapText(tester, HouseholdStrings.saveAndContinue);
    final patch = writes.singleWhere((request) => request.method == 'PATCH');
    expect(requestBody(patch)['nickname'], 'Martita');
    expect(requestBody(patch)['proposed_capacity_percent'], isA<int>());
    expect(find.text(RouteNames.householdAvailability), findsOneWidget);
  });

  testWidgets('A5 keeps the draft and shows the server field error', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const ProfileScreen(householdId: 'household-1'),
      _profileResponder(
        writes,
        onWrite: (request) => apiError('VALIDATION_ERROR', 422, {
          'fields': [
            {'field': 'body.nickname', 'code': 'too_long', 'message': 'x'},
          ],
        }),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'Marta');
    await tapText(tester, HouseholdStrings.saveAndContinue);
    expect(find.text('El texto supera el máximo permitido.'), findsOneWidget);
    expect(find.text(RouteNames.householdAvailability), findsNothing);
    expect(find.text('Marta'), findsWidgets);
  });

  testWidgets('A6 toggles slots and replaces availability on save', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const AvailabilityScreen(householdId: 'household-1'),
      _profileResponder(writes),
    );
    await tester.tap(find.bySemanticsLabel('Lunes, mañana'));
    await tester.tap(find.bySemanticsLabel('Domingo, noche'));
    await tester.pump();
    await tapText(tester, HouseholdStrings.save);
    final put = writes.singleWhere((request) => request.method == 'PUT');
    expect(requestBody(put)['slots'], [
      {'weekday': 0, 'period': 'morning'},
      {'weekday': 6, 'period': 'evening'},
    ]);
    expect(find.text(RouteNames.householdPreferences), findsOneWidget);
  });

  testWidgets('A6 adds a catalog restriction from the editor', (tester) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const AvailabilityScreen(householdId: 'household-1'),
      _profileResponder(writes),
    );
    expect(find.text(HouseholdStrings.noRestrictions), findsOneWidget);
    await tapText(tester, HouseholdStrings.addRestriction);
    await tapText(tester, 'Ropa');
    await tapText(tester, HouseholdStrings.save);
    final post = writes.singleWhere((request) => request.method == 'POST');
    expect(requestBody(post), {
      'target': {'type': 'category', 'key': 'laundry'},
      'kind': 'permanent',
    });
    expect(find.text('Ropa'), findsOneWidget);
    expect(find.text(HouseholdStrings.permanent), findsOneWidget);
  });

  testWidgets('A6 never leaves the screen when saving fails', (tester) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const AvailabilityScreen(householdId: 'household-1'),
      _profileResponder(
        writes,
        onWrite: (request) => apiError('SERVICE_UNAVAILABLE', 503),
      ),
    );
    await tapText(tester, HouseholdStrings.save);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text(RouteNames.householdPreferences), findsNothing);
  });

  testWidgets('A7 moves an activity between preferred and unable', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const PreferencesScreen(householdId: 'household-1'),
      _profileResponder(writes, profile: profileJson(preferred: ['dog_walk'])),
    );
    expect(find.text(HouseholdStrings.preferred), findsOneWidget);
    await tapText(tester, 'Pasear al perro');
    await tapText(tester, HouseholdStrings.savePreferences);
    final post = writes.where((request) => request.method == 'POST');
    expect(requestBody(post.single), {
      'target': {'type': 'activity', 'key': 'dog_walk'},
      'kind': 'permanent',
    });
    final put = writes.lastWhere((request) => request.method == 'PUT');
    expect(requestBody(put)['preferred_activity_keys'], isEmpty);
  });
}
