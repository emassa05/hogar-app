import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/widgets/app_text_field.dart';
import 'package:hogar_app/core/widgets/character_picker.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';

import '../core/n6_router_test.dart' show householdResponse, pumpRouter;
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

Finder field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is AppTextField && widget.label == label,
  ),
  matching: find.byType(TextField),
);

class IdentityServer {
  final user = userJson();
  String? nickname;
  bool accountFails = false;
  bool nicknameFails = false;
  Future<ResponseBody> respond(RequestOptions request) async {
    if (request.path == '/users/me') {
      if (accountFails) return apiError('SERVICE_UNAVAILABLE', 503);
      user.addAll(requestBody(request));
      return jsonResponse(user);
    }
    if (request.path.endsWith('/profile')) {
      if (request.method == 'PATCH') {
        if (nicknameFails) return apiError('SERVICE_UNAVAILABLE', 503);
        nickname = requestBody(request)['nickname'] as String?;
      }
      return jsonResponse(
        profileJson()
          ..['name'] = user['name']
          ..['avatar'] = user['avatar']
          ..['nickname'] = nickname,
      );
    }
    return householdResponse(request);
  }
}

Future<void> enterIdentity(WidgetTester tester) async {
  await tester.ensureVisible(field(HouseholdStrings.accountName));
  await tester.enterText(field(HouseholdStrings.accountName), 'María');
  await tester.ensureVisible(field(HouseholdStrings.householdNickname));
  await tester.enterText(field(HouseholdStrings.householdNickname), 'Mari');
  tester
      .widget<CharacterPicker>(find.byType(CharacterPicker))
      .onSelected(AvatarChoice.pink);
  await tester.pump();
}

void main() {
  testWidgets(
    'own overview edits only account identity and household nickname then returns to overview at 200 percent',
    (tester) async {
      final server = IdentityServer();
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/members/me/profile',
        scale: 2,
      );
      await tapText(tester, HouseholdStrings.editProfile);
      await enterIdentity(tester);
      expect(
        tester.widget<CharacterPicker>(find.byType(CharacterPicker)).enabled,
        isTrue,
      );
      expect(find.byType(Slider), findsNothing);
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(screen.location, '/households/household-1/members/me/profile');
      expect(find.text('María'), findsOneWidget);
      expect(find.text('Mari'), findsOneWidget);
      final writes = screen.harness.adapter.requests
          .where((request) => request.method == 'PATCH')
          .toList();
      expect(writes.length, 2);
      expect(writes[0].path, '/users/me');
      expect(requestBody(writes[0]), {'name': 'María', 'avatar': 'pink'});
      expect(writes[1].path, '/households/household-1/members/me/profile');
      expect(requestBody(writes[1]), {'nickname': 'Mari'});
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'partial account save is confirmed honestly and retry never repeats it',
    (tester) async {
      final server = IdentityServer()..nicknameFails = true;
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/profile/edit',
      );
      await enterIdentity(tester);
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(screen.location, '/households/household-1/profile/edit');
      expect(find.text(HouseholdStrings.accountIdentitySaved), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        screen.harness.container.read(sessionControllerProvider).user!.name,
        'María',
      );
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(find.text(HouseholdStrings.accountIdentitySaved), findsOneWidget);
      server.nicknameFails = false;
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(screen.location, '/households/household-1/members/me/profile');
      expect(
        screen.harness.adapter.requests
            .where((request) => request.path == '/users/me')
            .length,
        1,
      );
      expect(find.text('Mari'), findsOneWidget);
    },
  );
  testWidgets(
    'account failure never writes nickname or claims partial success',
    (tester) async {
      final server = IdentityServer()..accountFails = true;
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/profile/edit',
      );
      await enterIdentity(tester);
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(find.text(HouseholdStrings.accountIdentitySaved), findsNothing);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        screen.harness.adapter.requests
            .where((request) => request.method == 'PATCH')
            .length,
        1,
      );
      expect(
        screen.harness.container.read(sessionControllerProvider).user!.name,
        'Marta',
      );
    },
  );
  testWidgets(
    'logout during account save discards late confirmation and stops nickname write',
    (tester) async {
      final server = IdentityServer();
      final pending = Completer<ResponseBody>();
      final screen = await pumpRouter(
        tester,
        (request) async => request.path == '/users/me'
            ? pending.future
            : server.respond(request),
        path: '/households/household-1/profile/edit',
      );
      await enterIdentity(tester);
      await tapText(tester, HouseholdStrings.saveChanges);
      await tester.runAsync(
        () => screen.harness.container
            .read(sessionControllerProvider.notifier)
            .expire(),
      );
      await settle(tester);
      pending.complete(jsonResponse(userJson()..['name'] = 'Late name'));
      await settle(tester);
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .isAuthenticated,
        isFalse,
      );
      expect(
        screen.harness.adapter.requests
            .where((request) => request.method == 'PATCH')
            .length,
        1,
      );
      expect(screen.location, '/');
    },
  );
}
