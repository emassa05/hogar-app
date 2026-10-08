import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/router/app_router.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/theme/app_colors.dart';
import 'package:hogar_app/core/theme/app_theme.dart';
import 'package:hogar_app/core/widgets/app_buttons.dart';
import 'package:hogar_app/core/widgets/app_card.dart';
import 'package:hogar_app/core/widgets/avatar_circle.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/core/widgets/section_label.dart';
import 'package:hogar_app/core/widgets/step_header.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_strings.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/households/presentation/widgets/household_settings_row.dart';
import 'package:hogar_app/features/households/presentation/widgets/member_tile.dart';
import 'package:hogar_app/features/notifications/presentation/notification_strings.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';
import '../support/n2_screen_harness.dart';

Map<String, dynamic> secondHousehold() => householdJson(name: 'Casa del Mar')
  ..['id'] = 'household-2'
  ..['members'] = [memberJson(id: 'user-2', isMe: false, role: 'member')];

Future<N2Screen> pumpRouter(
  WidgetTester tester,
  HttpResponder respond, {
  String path = '/households/settings',
  String? activeId = 'household-1',
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final harness = N2Harness(respond);
  addTearDown(harness.dispose);
  await tester.runAsync(() => harness.signIn(householdId: activeId));
  final router = harness.container.read(appRouterProvider);
  router.go(path);
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

Future<ResponseBody> householdResponse(RequestOptions request) async {
  if (request.path == '/households') {
    return jsonResponse([
      summaryJson(),
      summaryJson()
        ..['id'] = 'household-2'
        ..['name'] = 'Casa del Mar',
    ]);
  }
  if (request.path == '/users/me' && request.method == 'PATCH') {
    return jsonResponse(
      userJson(
        householdId: requestBody(request)['active_household_id'] as String,
      ),
    );
  }
  if (request.path == '/households/household-2') {
    return jsonResponse(secondHousehold());
  }
  if (request.path == '/households/household-1') {
    return jsonResponse(
      householdJson()
        ..['members'] = [
          memberJson(),
          memberJson(id: 'user-2', isMe: false, role: 'member'),
        ],
    );
  }
  throw StateError('Unexpected request: ${request.method} ${request.path}');
}

void main() {
  testWidgets(
    'home enters read-only settings and persists switching before returning',
    (tester) async {
      final patch = Completer<ResponseBody>();
      final screen = await pumpRouter(tester, (request) async {
        if (request.path == '/users/me') return patch.future;
        return householdResponse(request);
      }, path: '/home');
      await tapText(tester, HouseholdStrings.household);
      expect(screen.location, '/households/settings');
      expect(find.byType(MemberTile), findsNWidgets(2));
      expect(find.text(HouseholdStrings.you), findsOneWidget);
      expect(find.text(HouseholdStrings.roleAdmin), findsOneWidget);
      expect(find.text(HouseholdStrings.member), findsOneWidget);
      expect(find.byType(PopupMenuButton<MemberAction>), findsOneWidget);
      expect(
        tester.widgetList<MemberTile>(find.byType(MemberTile)).first.onAction,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byType(StepHeader),
          matching: find.byType(AvatarCircle),
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Casa Los Robles');
      expect(screen.location, '/households/switch');
      expect(find.text('Perteneces a 2 hogares'), findsOneWidget);
      expect(find.text(HouseholdStrings.profileLocal), findsOneWidget);
      final activeCard = find.ancestor(
        of: find.text('Casa Los Robles'),
        matching: find.byType(AppCard),
      );
      expect(tester.widget<AppCard>(activeCard).borderColor, AppColors.brand);
      expect(
        tester
            .widget<Semantics>(
              find.ancestor(
                of: activeCard,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Semantics && widget.properties.selected == true,
                ),
              ),
            )
            .properties
            .selected,
        isTrue,
      );
      await tapText(tester, 'Casa del Mar');
      expect(screen.location, '/households/switch');
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final request = screen.harness.adapter.requests.last;
      expect(request.method, 'PATCH');
      expect(request.path, '/users/me');
      expect(requestBody(request), {'active_household_id': 'household-2'});
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-1',
      );
      expect(
        tester
            .widgetList<SecondaryButton>(find.byType(SecondaryButton))
            .every((button) => button.onPressed == null),
        isTrue,
      );
      expect(
        tester
            .widgetList<HouseholdSettingsRow>(find.byType(HouseholdSettingsRow))
            .every((row) => row.onPressed == null),
        isTrue,
      );
      patch.complete(jsonResponse(userJson(householdId: 'household-2')));
      await settle(tester);
      expect(screen.location, '/households/settings');
      expect(find.text('Casa del Mar'), findsOneWidget);
      expect(find.text('Casa Los Robles'), findsNothing);
      expect(find.text('Marta'), findsNothing);
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-2',
      );
      expect(
        screen.harness.adapter.requests.any(
          (request) => request.path.contains('/invitation'),
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'failed selection keeps the confirmed household and permits retry',
    (tester) async {
      var patches = 0;
      final screen = await pumpRouter(tester, (request) async {
        if (request.path == '/users/me' && ++patches == 1) {
          return apiError('SERVICE_UNAVAILABLE', 503);
        }
        return householdResponse(request);
      }, path: '/households/switch');
      await tapText(tester, HouseholdStrings.switchHousehold);
      expect(screen.location, '/households/switch');
      expect(find.byType(ErrorBanner), findsOneWidget);
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
      await tapText(tester, HouseholdStrings.switchHousehold);
      expect(screen.location, '/households/settings');
      expect(find.text('Casa del Mar'), findsOneWidget);
      expect(patches, 2);
    },
  );

  testWidgets(
    'settings loading then error retries without an onboarding redirect',
    (tester) async {
      final response = Completer<ResponseBody>();
      var loads = 0;
      final screen = await pumpRouter(tester, (request) async {
        loads++;
        return loads == 1 ? response.future : householdResponse(request);
      });
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MemberTile), findsNothing);
      expect(find.byType(AvatarCircle), findsNothing);
      response.complete(apiError('HOUSEHOLD_NOT_FOUND', 404));
      await settle(tester);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.byType(AvatarCircle), findsNothing);
      expect(screen.location, '/households/settings');
      expect(
        screen.harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-1',
      );
      await tapText(tester, HouseholdStrings.retry);
      expect(find.byType(MemberTile), findsNWidgets(2));
      expect(loads, 2);
    },
  );

  testWidgets('inaccessible selection never patches the active household', (
    tester,
  ) async {
    final screen = await pumpRouter(tester, (request) async {
      if (request.path == '/households/household-2') {
        return apiError('HOUSEHOLD_NOT_FOUND', 404);
      }
      return householdResponse(request);
    }, path: '/households/switch');
    await tapText(tester, HouseholdStrings.switchHousehold);
    expect(screen.location, '/households/switch');
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(
      screen.harness.adapter.requests.any(
        (request) => request.method == 'PATCH',
      ),
      isFalse,
    );
    expect(
      screen.harness.container
          .read(sessionControllerProvider)
          .user!
          .activeHouseholdId,
      'household-1',
    );
  });

  testWidgets('switch reload hides the previous members and header avatar', (
    tester,
  ) async {
    final response = Completer<ResponseBody>();
    final screen = await pumpRouter(tester, (request) async {
      if (request.path == '/households/household-2') return response.future;
      return householdResponse(request);
    });
    expect(
      find.descendant(
        of: find.byType(StepHeader),
        matching: find.byType(AvatarCircle),
      ),
      findsOneWidget,
    );
    screen.harness.container
        .read(sessionControllerProvider.notifier)
        .confirmUser(
          screen.harness.container
              .read(sessionControllerProvider)
              .user!
              .copyWith(activeHouseholdId: 'household-2'),
        );
    await settle(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Casa Los Robles'), findsNothing);
    expect(find.byType(MemberTile), findsNothing);
    expect(find.byType(AvatarCircle), findsNothing);
    response.complete(jsonResponse(secondHousehold()));
    await settle(tester);
    expect(find.text('Casa del Mar'), findsOneWidget);
    expect(find.byType(MemberTile), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StepHeader),
        matching: find.byType(AvatarCircle),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'settings with no active household offers selection without fetching detail',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        householdResponse,
        activeId: null,
      );
      expect(find.text(HouseholdStrings.noActiveHousehold), findsOneWidget);
      expect(screen.harness.adapter.requests, isEmpty);
      await tapText(tester, HouseholdStrings.myHouseholds);
      expect(screen.location, '/households/switch');
      expect(find.text('Casa del Mar'), findsOneWidget);
    },
  );

  testWidgets('empty member collection has an explicit read-only state', (
    tester,
  ) async {
    await pumpRouter(
      tester,
      (request) async =>
          jsonResponse(householdJson()..['members'] = <Map<String, dynamic>>[]),
    );
    expect(find.text(HouseholdStrings.noMembers), findsOneWidget);
    expect(find.text('0 integrantes'), findsOneWidget);
    expect(find.byType(MemberTile), findsNothing);
  });

  testWidgets(
    'switch loading and list error can retry into an empty collection',
    (tester) async {
      final response = Completer<ResponseBody>();
      var loads = 0;
      final screen = await pumpRouter(tester, (request) async {
        loads++;
        return loads == 1 ? response.future : jsonResponse([]);
      }, path: '/households/switch');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      response.complete(apiError('SERVICE_UNAVAILABLE', 503));
      await settle(tester);
      expect(find.byType(ErrorBanner), findsOneWidget);
      await tapText(tester, HouseholdStrings.retry);
      expect(find.text(HouseholdStrings.noHouseholds), findsOneWidget);
      expect(find.text('Perteneces a 0 hogares'), findsOneWidget);
      expect(screen.location, '/households/switch');
    },
  );

  for (final entry in {
    HouseholdStrings.create: '/households/create',
    HouseholdStrings.join: '/households/join',
  }.entries) {
    testWidgets('switch reuses ${entry.value} and back returns to switching', (
      tester,
    ) async {
      final screen = await pumpRouter(
        tester,
        householdResponse,
        path: '/households/switch',
      );
      await tapText(tester, entry.key);
      expect(screen.location, entry.value);
      screen.router.pop();
      await settle(tester);
      expect(screen.location, '/households/switch');
    });
  }

  for (final path in ['/households/settings', '/households/switch']) {
    testWidgets('$path supports 200 percent text scale and direct-route back', (
      tester,
    ) async {
      final screen = await pumpRouter(
        tester,
        householdResponse,
        path: path,
        scale: 2,
      );
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -900),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      final back = find.byTooltip('Volver');
      expect(back, findsOneWidget);
      await tester.tap(back);
      await settle(tester);
      expect(
        screen.location,
        path.endsWith('switch') ? '/households/settings' : '/home',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'late detail from previous household cannot bleed into a new active household',
    (tester) async {
      final old = Completer<ResponseBody>();
      final current = Completer<ResponseBody>();
      final screen = await pumpRouter(
        tester,
        (request) async =>
            request.path.endsWith('household-1') ? old.future : current.future,
      );
      screen.harness.container
          .read(sessionControllerProvider.notifier)
          .confirmUser(
            screen.harness.container
                .read(sessionControllerProvider)
                .user!
                .copyWith(activeHouseholdId: 'household-2'),
          );
      await settle(tester);
      current.complete(jsonResponse(secondHousehold()));
      await settle(tester);
      expect(find.text('Casa del Mar'), findsOneWidget);
      old.complete(jsonResponse(householdJson()));
      await settle(tester);
      expect(find.text('Casa del Mar'), findsOneWidget);
      expect(find.text('Casa Los Robles'), findsNothing);
    },
  );
  testWidgets(
    'members precede compact settings and backed characters fall back to initials',
    (tester) async {
      await pumpRouter(
        tester,
        (request) async => jsonResponse(
          householdJson()
            ..['members'] = [
              memberJson()..['avatar'] = 'pink',
              memberJson(id: 'user-2', isMe: false, role: 'member')
                ..['avatar'] = null,
            ],
        ),
      );
      final tiles = tester
          .widgetList<MemberTile>(find.byType(MemberTile))
          .toList();
      expect(tiles.every((tile) => tile.showCharacter), isTrue);
      expect(
        find.descendant(
          of: find.byType(MemberTile).first,
          matching: find.byType(AvatarCircle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MemberTile).last,
          matching: find.byType(AvatarCircle),
        ),
        findsNothing,
      );
      expect(
        find.text(AvatarCircle.initialsOf(tiles.last.member.displayName)),
        findsOneWidget,
      );
      final label = tester.widget<SectionLabel>(find.byType(SectionLabel));
      expect(label.count, 2);
      final memberY = tester.getTopLeft(find.byType(MemberTile).last).dy;
      expect(
        memberY,
        lessThan(tester.getTopLeft(find.text(NotificationStrings.entry)).dy),
      );
      expect(
        memberY,
        lessThan(tester.getTopLeft(find.text(CapacityStrings.entry)).dy),
      );
    },
  );
  testWidgets(
    'N2 member tiles retain initials even when a character is backed',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberTile(
              member: Member(
                userId: 'user-1',
                name: 'Marta',
                nickname: null,
                avatar: AvatarChoice.pink,
                role: MemberRole.admin,
                joinedAt: DateTime.utc(2026, 10, 1),
                isMe: true,
              ),
              index: 0,
            ),
          ),
        ),
      );
      expect(find.byType(AvatarCircle), findsNothing);
      expect(find.text('M'), findsOneWidget);
    },
  );
  testWidgets('late whole-card selection cannot replace a changed account', (
    tester,
  ) async {
    final pending = Completer<ResponseBody>();
    final screen = await pumpRouter(tester, (request) async {
      if (request.path == '/users/me') return pending.future;
      return householdResponse(request);
    }, path: '/households/switch');
    await tapText(tester, 'Casa del Mar');
    final container = screen.harness.container;
    container
        .read(sessionControllerProvider.notifier)
        .confirmUser(
          container
              .read(sessionControllerProvider)
              .user!
              .copyWith(id: 'new-user'),
        );
    await settle(tester);
    pending.complete(jsonResponse(userJson(householdId: 'household-2')));
    await settle(tester);
    expect(container.read(sessionControllerProvider).user!.id, 'new-user');
    expect(
      container.read(sessionControllerProvider).user!.activeHouseholdId,
      'household-1',
    );
    expect(screen.location, '/households/switch');
  });
}
