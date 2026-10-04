import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/router/route_names.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/households/presentation/screens/household_choice_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_create_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_invite_screen.dart';
import 'package:hogar_app/features/households/presentation/screens/household_join_screen.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

Map<String, dynamic> _household() => {
  ...householdJson(),
  'members': [
    memberJson(),
    {...memberJson(id: 'user-2', role: 'member', isMe: false)},
  ],
};

void main() {
  testWidgets('A2 offers create and join with a per-household profile note', (
    tester,
  ) async {
    await pumpN2Screen(
      tester,
      const HouseholdChoiceScreen(),
      (request) async => jsonResponse(<String, dynamic>{}),
    );
    expect(find.text(HouseholdStrings.profileLocal), findsOneWidget);
    expect(find.textContaining('viaja contigo'), findsNothing);
    await tapText(tester, HouseholdStrings.join);
    expect(find.text(RouteNames.householdJoin), findsOneWidget);
  });

  testWidgets('A3 validates the name and creates the household idempotently', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    await pumpN2Screen(tester, const HouseholdCreateScreen(), (request) async {
      if (request.method == 'POST') requests.add(request);
      return jsonResponse(householdJson(), 201);
    });
    await tapText(tester, HouseholdStrings.continueLabel);
    expect(find.text('Completa este campo.'), findsOneWidget);
    expect(requests, isEmpty);
    await tester.enterText(find.byType(EditableText), 'Casa Los Robles');
    await tester.pump();
    expect(find.text('15/40'), findsOneWidget);
    await tapText(tester, HouseholdStrings.continueLabel);
    expect(requests.single.headers['Idempotency-Key'], isNotNull);
    expect(requestBody(requests.single)['name'], 'Casa Los Robles');
    expect(find.text(RouteNames.householdInvite), findsOneWidget);
  });

  testWidgets('A3 maps field validation errors from the contract', (
    tester,
  ) async {
    await pumpN2Screen(
      tester,
      const HouseholdCreateScreen(),
      (request) async => apiError('VALIDATION_ERROR', 422, {
        'fields': [
          {'field': 'body.name', 'code': 'too_long', 'message': 'x'},
        ],
      }),
    );
    await tester.enterText(find.byType(EditableText), 'Casa');
    await tapText(tester, HouseholdStrings.continueLabel);
    expect(find.text('El texto supera el máximo permitido.'), findsOneWidget);
    expect(find.text(RouteNames.householdInvite), findsNothing);
  });

  testWidgets('A4 lists members, copies the code and lets admins manage', (
    tester,
  ) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpN2Screen(
      tester,
      const HouseholdInviteScreen(householdId: 'household-1'),
      (request) async => request.path.endsWith('/invitation')
          ? jsonResponse(invitationJson())
          : jsonResponse(_household()),
    );
    expect(find.text('Marta'), findsOneWidget);
    expect(find.text('Pablo'), findsOneWidget);
    expect(find.text('7QK2-M9XA'), findsOneWidget);
    await tapText(tester, HouseholdStrings.copy);
    expect(clipboard, '7QK2-M9XA');
    expect(find.text(HouseholdStrings.copied), findsOneWidget);
    expect(find.byTooltip(HouseholdStrings.memberOptions('Pablo')), findsOne);
    expect(
      find.byTooltip(HouseholdStrings.memberOptions('Marta')),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tapText(tester, HouseholdStrings.continueLabel);
    expect(find.text(RouteNames.householdProfile), findsOneWidget);
  });

  testWidgets('A4 shows a retry when the household cannot load', (
    tester,
  ) async {
    var calls = 0;
    await pumpN2Screen(
      tester,
      const HouseholdInviteScreen(householdId: 'household-1'),
      (request) async {
        calls++;
        return calls == 1
            ? apiError('SERVICE_UNAVAILABLE', 503)
            : request.path.endsWith('/invitation')
            ? jsonResponse(invitationJson())
            : jsonResponse(_household());
      },
    );
    expect(find.text('Reintentar'), findsOneWidget);
    await tapText(tester, 'Reintentar');
    expect(find.text('Pablo'), findsOneWidget);
  });

  testWidgets('A10 formats the code, previews and joins', (tester) async {
    final paths = <String>[];
    await pumpN2Screen(tester, const HouseholdJoinScreen(), (request) async {
      paths.add('${request.method} ${request.path}');
      return request.method == 'POST'
          ? jsonResponse(householdJson())
          : jsonResponse(previewJson());
    });
    await tester.enterText(find.byType(EditableText), '7qk2m9xa');
    await settle(tester);
    expect(find.text('7QK2-M9XA'), findsOneWidget);
    expect(find.text('Casa Los Robles'), findsOneWidget);
    expect(find.text(HouseholdStrings.memberCount(4)), findsOneWidget);
    await tapText(tester, HouseholdStrings.joinHome);
    expect(paths, contains('POST /invitations/7QK2-M9XA/accept'));
    expect(find.text(RouteNames.home), findsOneWidget);
  });

  testWidgets('A10 shows an expired invitation on the field', (tester) async {
    await pumpN2Screen(
      tester,
      const HouseholdJoinScreen(),
      (request) async => apiError('INVITATION_EXPIRED', 410),
    );
    await tester.enterText(find.byType(EditableText), '7QK2M9XA');
    await settle(tester);
    expect(
      find.text(
        'La invitación expiró. Pide un código nuevo a quien administra el hogar.',
      ),
      findsOneWidget,
    );
    expect(find.text(HouseholdStrings.joinHome), findsNothing);
  });
}
