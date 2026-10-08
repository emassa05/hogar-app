import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_strings.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/households/presentation/widgets/member_tile.dart';

import '../capacity/capacity_fixtures.dart';
import '../core/n6_router_test.dart' show householdResponse, pumpRouter;
import '../profile/n6_profile_edit_test.dart' show field;
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

class HouseholdServer {
  String name = 'Casa Los Robles';
  int version = 1;
  String ownRole = 'admin';
  String otherRole = 'member';
  bool removed = false;
  bool conflict = false;
  bool followUpFails = false;
  bool mutationConfirmed = false;
  bool roleFails = false;
  Future<ResponseBody> respond(RequestOptions request) async {
    if (request.path.endsWith('/invitation')) {
      return jsonResponse(invitationJson());
    }
    if (request.path.endsWith('/regenerate')) {
      return jsonResponse(invitationJson(code: '8QK2-M9XA'));
    }
    if (request.path.contains('/members/')) {
      if (request.method == 'PATCH' && roleFails) {
        return apiError('LAST_ADMIN_MUST_TRANSFER', 409);
      }
      mutationConfirmed = true;
      if (request.method == 'DELETE') {
        removed = true;
        return jsonResponse(null, 204);
      }
      otherRole = requestBody(request)['role'] as String;
      return jsonResponse(
        memberJson(id: 'user-2', isMe: false, role: otherRole),
      );
    }
    if (request.path == '/households/household-1') {
      if (request.method == 'PATCH') {
        if (conflict) {
          conflict = false;
          version = 2;
          name = 'Nombre ajeno';
          return apiError('VERSION_CONFLICT', 412);
        }
        name = requestBody(request)['name'] as String;
        version++;
      }
      if (followUpFails && mutationConfirmed) {
        return apiError('SERVICE_UNAVAILABLE', 503);
      }
      return jsonResponse(
        householdJson(name: name, version: version, role: ownRole)
          ..['members'] = [
            memberJson(role: ownRole),
            if (!removed)
              memberJson(id: 'user-2', isMe: false, role: otherRole),
          ],
      );
    }
    return householdResponse(request);
  }
}

Future<void> openMemberOptions(WidgetTester tester) async {
  await tester.ensureVisible(
    find.byTooltip(HouseholdStrings.memberOptions('Pablo')),
  );
  await tester.tap(find.byTooltip(HouseholdStrings.memberOptions('Pablo')));
  await settle(tester);
}

void main() {
  testWidgets(
    'members see profiles but no administration actions or editable household',
    (tester) async {
      final server = HouseholdServer()..ownRole = 'member';
      final screen = await pumpRouter(tester, server.respond);
      expect(find.byType(PopupMenuButton<MemberAction>), findsNothing);
      expect(find.text(HouseholdStrings.editHousehold), findsNothing);
      expect(find.text(HouseholdStrings.invite), findsNothing);
      expect(find.text(CapacityStrings.entry), findsOneWidget);
      screen.router.go('/households/household-1/settings/edit');
      await settle(tester);
      expect(find.text(HouseholdStrings.adminHelp), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(
        screen.harness.adapter.requests.every(
          (request) => request.method == 'GET',
        ),
        isTrue,
      );
    },
  );
  testWidgets('F8 model entry preserves the unsaved name on navigation back', (
    tester,
  ) async {
    final server = CapacityServer();
    final screen = await pumpRouter(tester, server.respond);
    await tapText(tester, HouseholdStrings.editHousehold);
    await tester.enterText(
      field(HouseholdStrings.householdName),
      'Nombre pendiente',
    );
    expect(find.text(CapacityStrings.distribution), findsOneWidget);
    await tapText(tester, CapacityStrings.entry);
    expect(screen.location, '/households/household-1/capacity');
    await tester.tap(find.byTooltip('Volver'));
    await settle(tester);
    expect(screen.location, '/households/household-1/settings/edit');
    expect(
      tester
          .widget<TextField>(field(HouseholdStrings.householdName))
          .controller!
          .text,
      'Nombre pendiente',
    );
    expect(
      screen.harness.adapter.requests.every(
        (request) => request.method == 'GET',
      ),
      isTrue,
    );
  });
  testWidgets(
    'rename 412 keeps draft and retries only with current version at 200 percent',
    (tester) async {
      final server = HouseholdServer()..conflict = true;
      final screen = await pumpRouter(tester, server.respond, scale: 2);
      await tapText(tester, HouseholdStrings.editHousehold);
      await tester.enterText(
        field(HouseholdStrings.householdName),
        'Casa nueva',
      );
      await tapText(tester, HouseholdStrings.saveChanges);
      expect(screen.location, '/households/household-1/settings/edit');
      expect(find.text(HouseholdStrings.currentVersionLoaded), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      await tapText(tester, HouseholdStrings.saveChanges);
      final patches = screen.harness.adapter.requests
          .where((request) => request.method == 'PATCH')
          .toList();
      expect(requestBody(patches.first), {'version': 1, 'name': 'Casa nueva'});
      expect(requestBody(patches.last), {'version': 2, 'name': 'Casa nueva'});
      expect(screen.location, '/households/settings');
      expect(find.text('Casa nueva'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'admin promotes another member then removal requires confirmation and preserves history copy',
    (tester) async {
      final server = HouseholdServer();
      final screen = await pumpRouter(tester, server.respond);
      expect(
        tester.widgetList<MemberTile>(find.byType(MemberTile)).first.onAction,
        isNull,
      );
      await openMemberOptions(tester);
      await tapText(tester, HouseholdStrings.makeAdmin);
      expect(server.otherRole, 'admin');
      expect(find.text(HouseholdStrings.roleAdmin), findsNWidgets(2));
      await openMemberOptions(tester);
      await tapText(tester, HouseholdStrings.removeMember);
      expect(
        find.textContaining(HouseholdStrings.historyPreserved),
        findsOneWidget,
      );
      await tapText(tester, HouseholdStrings.cancel);
      expect(server.removed, isFalse);
      await openMemberOptions(tester);
      await tapText(tester, HouseholdStrings.removeMember);
      await tapText(tester, HouseholdStrings.confirm);
      expect(server.removed, isTrue);
      expect(find.text('Pablo'), findsNothing);
      expect(
        screen.harness.adapter.requests
            .where((request) => request.method == 'DELETE')
            .length,
        1,
      );
    },
  );
  testWidgets('confirmed removal stays visible when follow-up detail fails', (
    tester,
  ) async {
    final server = HouseholdServer()..followUpFails = true;
    await pumpRouter(tester, server.respond);
    await openMemberOptions(tester);
    await tapText(tester, HouseholdStrings.removeMember);
    await tapText(tester, HouseholdStrings.confirm);
    expect(find.text('Pablo'), findsNothing);
    expect(find.text(HouseholdStrings.memberRemoved), findsOneWidget);
    expect(find.byType(ErrorBanner), findsOneWidget);
    await tapText(tester, HouseholdStrings.retry);
    expect(find.text('Pablo'), findsNothing);
    expect(find.text(HouseholdStrings.memberRemoved), findsOneWidget);
    server.followUpFails = false;
    await tapText(tester, HouseholdStrings.retry);
    expect(find.text('Pablo'), findsNothing);
    expect(find.byType(ErrorBanner), findsNothing);
  });
  testWidgets(
    'backend role rejection leaves permissions unchanged and reports action error',
    (tester) async {
      final server = HouseholdServer()..roleFails = true;
      await pumpRouter(tester, server.respond);
      await openMemberOptions(tester);
      await tapText(tester, HouseholdStrings.makeAdmin);
      expect(server.otherRole, 'member');
      expect(find.text(HouseholdStrings.member), findsOneWidget);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(HouseholdStrings.memberRoleSaved), findsNothing);
    },
  );
  testWidgets(
    'settings invitation regenerates code and returns without onboarding',
    (tester) async {
      final server = HouseholdServer();
      final screen = await pumpRouter(tester, server.respond);
      await tapText(tester, HouseholdStrings.invite);
      expect(screen.location, '/households/household-1/settings/invite');
      expect(find.text(HouseholdStrings.invitationRevocation), findsOneWidget);
      expect(find.text(HouseholdStrings.continueLabel), findsNothing);
      await tapText(tester, HouseholdStrings.regenerate);
      expect(
        screen.harness.adapter.requests.any(
          (request) =>
              request.path.endsWith('/regenerate') && request.method == 'POST',
        ),
        isTrue,
      );
      await tapText(tester, HouseholdStrings.done);
      expect(screen.location, '/households/settings');
      expect(
        screen.harness.adapter.requests.any(
          (request) => request.path.contains('/profile'),
        ),
        isFalse,
      );
    },
  );
  testWidgets(
    'account change reloads same household and cancels an old removal confirmation',
    (tester) async {
      final server = HouseholdServer();
      final screen = await pumpRouter(tester, server.respond);
      await openMemberOptions(tester);
      await tapText(tester, HouseholdStrings.removeMember);
      server.ownRole = 'member';
      screen.harness.container
          .read(sessionControllerProvider.notifier)
          .confirmUser(
            screen.harness.container
                .read(sessionControllerProvider)
                .user!
                .copyWith(id: 'user-new'),
          );
      await settle(tester);
      await tapText(tester, HouseholdStrings.confirm);
      expect(server.removed, isFalse);
      expect(
        screen.harness.adapter.requests.any(
          (request) => request.method == 'DELETE',
        ),
        isFalse,
      );
      expect(find.byType(PopupMenuButton<MemberAction>), findsNothing);
    },
  );
}
