import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';

import '../core/n6_router_test.dart' show householdResponse, pumpRouter;
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

class LeaveServer {
  bool departed = false;
  bool empty = false;
  bool blocked = false;
  bool soleMember = false;
  bool listFails = false;
  bool networkFails = false;
  bool lostResponse = false;
  int departures = 0;
  Completer<ResponseBody>? pending;

  Future<ResponseBody> respond(RequestOptions request) async {
    if (request.path == '/households/household-1') {
      return jsonResponse(
        householdJson(role: blocked ? 'admin' : 'member')
          ..['members'] = [
            memberJson(role: blocked ? 'admin' : 'member'),
            if (!soleMember)
              memberJson(
                id: 'user-2',
                isMe: false,
                role: blocked ? 'member' : 'admin',
              ),
          ],
      );
    }
    if (request.path.endsWith('/leave')) {
      departures++;
      if (pending != null) return pending!.future;
      if (blocked) return apiError('LAST_ADMIN_MUST_TRANSFER', 409);
      if (networkFails || lostResponse) {
        if (lostResponse) departed = true;
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        );
      }
      departed = true;
      return jsonResponse(null, 204);
    }
    if (request.path == '/users/me' && request.method == 'GET') {
      return apiError('SERVICE_UNAVAILABLE', 503);
    }
    if (request.path == '/households') {
      if (listFails) return apiError('SERVICE_UNAVAILABLE', 503);
      return jsonResponse([
        if (!departed) summaryJson(),
        if (!empty)
          summaryJson()
            ..['id'] = 'household-2'
            ..['name'] = 'Casa del Mar',
      ]);
    }
    return householdResponse(request);
  }
}

Future<void> confirmLeave(WidgetTester tester) async {
  await tapText(tester, HouseholdStrings.leaveHousehold('Casa Los Robles'));
  expect(find.byType(AlertDialog), findsOneWidget);
  await tapText(tester, HouseholdStrings.leaveHousehold('Casa Los Robles'));
  await settle(tester);
}

void main() {
  testWidgets('the sole administrator and sole member cannot leave', (
    tester,
  ) async {
    final server = LeaveServer()
      ..blocked = true
      ..soleMember = true;
    final screen = await pumpRouter(tester, server.respond);
    await confirmLeave(tester);
    expect(server.departed, isFalse);
    expect(find.text(HouseholdStrings.transferBeforeLeaving), findsOneWidget);
    expect(
      screen.harness.container
          .read(sessionControllerProvider)
          .user!
          .activeHouseholdId,
      'household-1',
    );
    expect(screen.location, '/households/settings');
  });
  for (final duringRequest in [false, true]) {
    testWidgets(
      'a new session epoch cancels the old leave ${duringRequest ? 'request' : 'confirmation'} even for the same account',
      (tester) async {
        final server = LeaveServer();
        if (duringRequest) server.pending = Completer<ResponseBody>();
        final screen = await pumpRouter(tester, server.respond);
        await tapText(
          tester,
          HouseholdStrings.leaveHousehold('Casa Los Robles'),
        );
        if (duringRequest) {
          await tapText(
            tester,
            HouseholdStrings.leaveHousehold('Casa Los Robles'),
          );
        }
        await tester.runAsync(screen.harness.signIn);
        await settle(tester);
        if (duringRequest) {
          server.pending!.complete(jsonResponse(null, 204));
          await settle(tester);
        } else {
          await tapText(
            tester,
            HouseholdStrings.leaveHousehold('Casa Los Robles'),
          );
        }
        expect(screen.location, '/households/settings');
        expect(
          screen.harness.container
              .read(sessionControllerProvider)
              .user!
              .activeHouseholdId,
          'household-1',
        );
        expect(
          screen.harness.container.read(householdControllerProvider).savedPart,
          isEmpty,
        );
        expect(server.departures, duringRequest ? 1 : 0);
      },
    );
  }
  testWidgets(
    'membership reconciliation failure cannot fabricate a departure or repeat the mutation',
    (tester) async {
      final server = LeaveServer()..lostResponse = true;
      final screen = await pumpRouter(tester, server.respond);
      await confirmLeave(tester);
      server.listFails = true;
      await confirmLeave(tester);
      expect(screen.location, '/households/settings');
      expect(server.departures, 1);
      expect(find.text(HouseholdStrings.leaveConfirmed), findsNothing);
      expect(find.byType(ErrorBanner), findsOneWidget);
      server.listFails = false;
      await confirmLeave(tester);
      expect(screen.location, '/households/switch');
      expect(server.departures, 1);
    },
  );
  testWidgets('leave cannot target a non-active household', (tester) async {
    final server = LeaveServer();
    final screen = await pumpRouter(tester, server.respond);
    final result = await screen.harness.container
        .read(householdControllerProvider.notifier)
        .leave('household-2');
    expect(result, isFalse);
    expect(server.departures, 0);
    expect(
      screen.harness.container
          .read(sessionControllerProvider)
          .user!
          .activeHouseholdId,
      'household-1',
    );
  });
  testWidgets('cancel leaves membership and requests untouched', (
    tester,
  ) async {
    final server = LeaveServer();
    final screen = await pumpRouter(tester, server.respond);
    await tapText(tester, HouseholdStrings.leaveHousehold('Casa Los Robles'));
    expect(find.textContaining(HouseholdStrings.leaveHelp), findsOneWidget);
    await tapText(tester, HouseholdStrings.cancel);
    expect(server.departures, 0);
    expect(screen.location, '/households/settings');
    expect(
      screen.harness.container
          .read(sessionControllerProvider)
          .user!
          .activeHouseholdId,
      'household-1',
    );
  });

  testWidgets(
    '204 clears active membership without a fallible account refresh and requires manual selection at 200 percent',
    (tester) async {
      final server = LeaveServer();
      final screen = await pumpRouter(tester, server.respond, scale: 2);
      await confirmLeave(tester);
      expect(screen.location, '/households/switch');
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        isNull,
      );
      expect(
        screen.harness.container.read(householdControllerProvider).household,
        isNull,
      );
      expect(find.text('Casa Los Robles'), findsNothing);
      expect(find.text('Casa del Mar'), findsOneWidget);
      expect(find.text(HouseholdStrings.leaveConfirmed), findsOneWidget);
      expect(
        screen.harness.adapter.requests.where(
          (request) => request.path == '/users/me',
        ),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tapText(tester, HouseholdStrings.switchHousehold);
      expect(screen.location, '/households/settings');
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-2',
      );
      expect(server.departures, 1);
    },
  );

  testWidgets(
    'confirmed zero memberships opens the existing create or join choice',
    (tester) async {
      final server = LeaveServer()..empty = true;
      final screen = await pumpRouter(tester, server.respond);
      await confirmLeave(tester);
      expect(screen.location, '/households/start');
      expect(find.text(HouseholdStrings.chooseTitle), findsOneWidget);
      expect(find.text(HouseholdStrings.create), findsOneWidget);
      expect(find.text(HouseholdStrings.join), findsOneWidget);
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        isNull,
      );
    },
  );

  testWidgets(
    '409 keeps membership and directs the last admin to existing member administration',
    (tester) async {
      final server = LeaveServer()..blocked = true;
      final screen = await pumpRouter(tester, server.respond);
      await confirmLeave(tester);
      expect(screen.location, '/households/settings');
      expect(find.text(HouseholdStrings.transferBeforeLeaving), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(HouseholdStrings.leaveConfirmed), findsNothing);
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-1',
      );
      await tapText(tester, HouseholdStrings.manageMembers);
      expect(tester.takeException(), isNull);
      expect(
        screen.harness.adapter.requests.where(
          (request) => request.method == 'PATCH',
        ),
        isEmpty,
      );
    },
  );

  for (final empty in [false, true]) {
    testWidgets(
      'list reload failure preserves confirmed departure, not a fabricated empty list ($empty)',
      (tester) async {
        final server = LeaveServer()
          ..empty = empty
          ..listFails = true;
        final screen = await pumpRouter(tester, server.respond);
        await confirmLeave(tester);
        expect(screen.location, '/households/switch');
        expect(find.text(HouseholdStrings.leaveConfirmed), findsOneWidget);
        expect(find.byType(ErrorBanner), findsOneWidget);
        expect(find.text(HouseholdStrings.noHouseholds), findsNothing);
        expect(
          screen.harness.container
              .read(sessionControllerProvider)
              .user!
              .activeHouseholdId,
          isNull,
        );
        server.listFails = false;
        await tapText(tester, HouseholdStrings.retry);
        expect(
          screen.location,
          empty ? '/households/start' : '/households/switch',
        );
        expect(server.departures, 1);
      },
    );
  }

  for (final lostResponse in [false, true]) {
    testWidgets(
      'unknown network outcome reconciles membership before retry ($lostResponse)',
      (tester) async {
        final server = LeaveServer()
          ..networkFails = !lostResponse
          ..lostResponse = lostResponse;
        final screen = await pumpRouter(tester, server.respond);
        await confirmLeave(tester);
        expect(screen.location, '/households/settings');
        expect(find.text(HouseholdStrings.leaveUncertain), findsOneWidget);
        expect(find.text(HouseholdStrings.leaveConfirmed), findsNothing);
        expect(
          screen.harness.container
              .read(sessionControllerProvider)
              .user!
              .activeHouseholdId,
          'household-1',
        );
        server.networkFails = false;
        server.lostResponse = false;
        await tapText(tester, HouseholdStrings.retry);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapText(
          tester,
          HouseholdStrings.leaveHousehold('Casa Los Robles'),
        );
        await settle(tester);
        expect(screen.location, '/households/switch');
        expect(server.departures, lostResponse ? 1 : 2);
        expect(
          screen.harness.container
              .read(sessionControllerProvider)
              .user!
              .activeHouseholdId,
          isNull,
        );
      },
    );
  }

  for (final accountChange in [false, true]) {
    for (final duringRequest in [false, true]) {
      testWidgets(
        'stale ${accountChange ? 'account' : 'household'} during ${duringRequest ? 'request' : 'confirmation'} cannot navigate or clear the new identity',
        (tester) async {
          final server = LeaveServer();
          if (duringRequest) server.pending = Completer<ResponseBody>();
          final screen = await pumpRouter(tester, server.respond);
          await tapText(
            tester,
            HouseholdStrings.leaveHousehold('Casa Los Robles'),
          );
          if (duringRequest) {
            await tapText(
              tester,
              HouseholdStrings.leaveHousehold('Casa Los Robles'),
            );
          }
          final session = screen.harness.container.read(
            sessionControllerProvider.notifier,
          );
          final user = screen.harness.container
              .read(sessionControllerProvider)
              .user!;
          session.confirmUser(
            accountChange
                ? user.copyWith(id: 'new-user')
                : user.copyWith(activeHouseholdId: 'household-2'),
          );
          await settle(tester);
          if (duringRequest) {
            server.pending!.complete(jsonResponse(null, 204));
            await settle(tester);
          } else {
            await tapText(
              tester,
              HouseholdStrings.leaveHousehold('Casa Los Robles'),
            );
          }
          expect(server.departures, duringRequest ? 1 : 0);
          expect(screen.location, '/households/settings');
          expect(
            screen.harness.container
                .read(sessionControllerProvider)
                .user!
                .activeHouseholdId,
            accountChange ? 'household-1' : 'household-2',
          );
          expect(
            screen.harness.container
                .read(householdControllerProvider)
                .savedPart,
            isEmpty,
          );
          expect(
            screen.harness.container.read(householdControllerProvider).busy,
            isFalse,
          );
        },
      );
    }
  }
}
