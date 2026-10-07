import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/widgets/app_buttons.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/profile/presentation/widgets/availability_grid.dart';

import '../core/n6_router_test.dart' show householdResponse, pumpRouter;
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

Future<ResponseBody> profileResponse(RequestOptions request) async {
  if (request.path.endsWith('/profile')) {
    final own = request.path.contains('/me/');
    return jsonResponse(
      profileJson()
        ..['user_id'] = own ? 'user-1' : 'user-2'
        ..['name'] = own ? 'Marta' : 'Pablo'
        ..['nickname'] = own ? 'Marti' : 'Pau'
        ..['role'] = own ? 'admin' : 'member'
        ..['is_me'] = own
        ..['approved_capacity_percent'] = own ? null : 35,
    );
  }
  return householdResponse(request);
}

void main() {
  for (final own in [true, false]) {
    testWidgets(
      'member navigation reads ${own ? 'own' : 'foreign'} profile at 200 percent without mutations',
      (tester) async {
        final screen = await pumpRouter(tester, profileResponse, scale: 2);
        await tapText(tester, own ? 'Marta' : 'Pablo');
        expect(
          screen.location,
          '/households/household-1/members/${own ? 'me' : 'user-2'}/profile',
        );
        expect(find.text(own ? 'Marti' : 'Pau'), findsOneWidget);
        expect(
          find.text(own ? HouseholdStrings.capacityUnset : '35 %'),
          findsOneWidget,
        );
        expect(find.byType(Slider), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(PrimaryButton), findsNothing);
        expect(
          tester
              .widget<AvailabilityGrid>(find.byType(AvailabilityGrid))
              .enabled,
          isFalse,
        );
        expect(
          screen.harness.adapter.requests.every(
            (request) => request.method == 'GET',
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'foreign inactive member error is retryable and stays read-only for admin',
    (tester) async {
      var loads = 0;
      final screen = await pumpRouter(tester, (request) async {
        if (request.path.endsWith('/profile') && ++loads == 1) {
          return apiError('MEMBER_NOT_FOUND', 404);
        }
        return profileResponse(request);
      }, path: '/households/household-1/members/user-2/profile');
      expect(find.byType(ErrorBanner), findsOneWidget);
      await tapText(tester, HouseholdStrings.retry);
      expect(find.text('Pau'), findsOneWidget);
      expect(
        screen.harness.adapter.requests.every(
          (request) => request.method == 'GET',
        ),
        isTrue,
      );
    },
  );
  testWidgets(
    'late foreign profile cannot overwrite own profile or switched household',
    (tester) async {
      final old = Completer<ResponseBody>();
      final screen = await pumpRouter(tester, (request) async {
        if (request.path.contains('/user-2/')) return old.future;
        return profileResponse(request);
      }, path: '/households/household-1/members/user-2/profile');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      screen.router.go('/households/household-1/members/me/profile');
      await settle(tester);
      old.complete(jsonResponse(profileJson()..['name'] = 'Old foreign'));
      await settle(tester);
      expect(find.text('Marta'), findsOneWidget);
      expect(find.text('Old foreign'), findsNothing);
      screen.harness.container
          .read(sessionControllerProvider.notifier)
          .confirmUser(
            screen.harness.container
                .read(sessionControllerProvider)
                .user!
                .copyWith(activeHouseholdId: 'household-2'),
          );
      await settle(tester);
      expect(find.text('Marta'), findsNothing);
      expect(find.text(HouseholdStrings.inactiveHousehold), findsOneWidget);
    },
  );
}
