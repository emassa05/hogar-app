import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/token_pair.dart';
import 'package:hogar_app/core/widgets/app_buttons.dart';
import 'package:hogar_app/core/widgets/app_text_field.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/notifications/data/notification_settings_repository.dart';
import 'package:hogar_app/features/notifications/domain/notification_settings.dart';
import 'package:hogar_app/features/notifications/presentation/notification_settings_controller.dart';
import 'package:hogar_app/features/notifications/presentation/notification_strings.dart';

import '../core/n6_router_test.dart' show pumpRouter, householdResponse;
import '../support/fake_http_adapter.dart';
import '../support/n2_harness.dart';
import '../support/n2_screen_harness.dart';

const settingsPath = '/users/me/notification-settings';
const pagePath = '/households/settings/notifications';

Map<String, Object?> settingsJson({int? lead = 30, bool quiet = true}) => {
  'muted': false,
  'muted_types': ['member_joined', 'swap_resolved'],
  'quiet_hours': quiet ? {'start': '22:30', 'end': '07:30'} : null,
  'reminder_lead_minutes': lead,
};

NotificationActor actor(N2Harness harness) => (
  userId: harness.container.read(sessionControllerProvider).user!.id,
  epoch: harness.container.read(sessionControllerProvider.notifier).epoch,
);

Future<void> toggle(WidgetTester tester, String key) async {
  final tile = tester.widget<SwitchListTile>(find.byKey(ValueKey(key)));
  tile.onChanged!(!tile.value);
  await tester.pump();
}

Future<void> enter(WidgetTester tester, String label, String value) async {
  final field = find.descendant(
    of: find.widgetWithText(AppTextField, label),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

void main() {
  test(
    'transport uses personal GET PUT and preserves full nullable payload',
    () async {
      final harness = N2Harness(
        (request) async => request.method == 'GET'
            ? jsonResponse(settingsJson(lead: null, quiet: false))
            : jsonResponse(requestBody(request)),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final repo = harness.container.read(
        notificationSettingsRepositoryProvider,
      );
      final loaded = await repo.load();
      expect(loaded, isA<Success<NotificationSettings>>());
      final value = (loaded as Success<NotificationSettings>).value;
      expect(value.reminderLeadMinutes, isNull);
      expect(value.quietHours, isNull);
      expect(await repo.save(value), isA<Success<NotificationSettings>>());
      expect(harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
      ]);
      expect(
        harness.adapter.requests.every(
          (request) => request.path == settingsPath,
        ),
        isTrue,
      );
      expect(
        requestBody(harness.adapter.requests.last),
        settingsJson(lead: null, quiet: false),
      );
    },
  );

  test(
    'DTO rejects missing fields malformed types times and limits without coercion',
    () {
      for (final lead in [5, 10080, null]) {
        expect(
          NotificationSettings.fromJson(settingsJson(lead: lead)).isValid,
          isTrue,
        );
      }
      for (final data in [
        null,
        <String, Object?>{},
        settingsJson()..remove('quiet_hours'),
        settingsJson()..remove('reminder_lead_minutes'),
        settingsJson()..['muted'] = 'false',
        settingsJson()..['muted_types'] = ['unknown'],
        settingsJson()..['muted_types'] = [1],
        settingsJson()..['reminder_lead_minutes'] = 30.0,
        settingsJson()..['reminder_lead_minutes'] = '30',
        settingsJson(lead: 4),
        settingsJson(lead: 10081),
        settingsJson()..['quiet_hours'] = {'start': '24:00', 'end': '07:30'},
        settingsJson()..['quiet_hours'] = {'start': '22:00', 'end': '7:30'},
        settingsJson()..['quiet_hours'] = {'start': '22:60', 'end': '07:30'},
      ]) {
        expect(
          () => NotificationSettings.fromJson(data),
          throwsFormatException,
        );
      }
    },
  );

  test('malformed GET and PUT return errors not fallback settings', () async {
    final harness = N2Harness(
      (request) async => jsonResponse({'muted': false}),
    );
    addTearDown(harness.dispose);
    final repo = harness.container.read(notificationSettingsRepositoryProvider);
    expect(await repo.load(), isA<Failure<NotificationSettings>>());
    expect(
      await repo.save(NotificationSettings.fromJson(settingsJson())),
      isA<Failure<NotificationSettings>>(),
    );
  });

  test(
    'timeout after PUT reconciles GET before confirming without duplicate PUT',
    () async {
      var server = settingsJson();
      final harness = N2Harness((request) async {
        if (request.method == 'GET') return jsonResponse(server);
        server = Map<String, Object?>.from(requestBody(request));
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.receiveTimeout,
        );
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = notificationSettingsControllerProvider(actor(harness));
      final subscription = harness.container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      final draft = NotificationSettings.fromJson(settingsJson(lead: 60));
      expect(await controller.save(draft), isNull);
      expect(harness.container.read(provider).requireValue.uncertain, isTrue);
      expect(harness.container.read(provider).requireValue.saved, isFalse);
      expect(await controller.save(draft), isNotNull);
      expect(harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
        'GET',
      ]);
      expect(harness.container.read(provider).requireValue.saved, isTrue);
    },
  );

  test(
    'failed reconciliation never issues another PUT and keeps uncertain outcome',
    () async {
      var loads = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'GET') {
          return ++loads == 1
              ? jsonResponse(settingsJson())
              : apiError('SERVICE_UNAVAILABLE', 503);
        }
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.receiveTimeout,
        );
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = notificationSettingsControllerProvider(actor(harness));
      final subscription = harness.container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      final draft = NotificationSettings.fromJson(settingsJson(lead: 60));
      await controller.save(draft);
      expect(await controller.save(draft), isNull);
      expect(harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
        'GET',
      ]);
      expect(harness.container.read(provider).requireValue.uncertain, isTrue);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .settings
            .reminderLeadMinutes,
        30,
      );
    },
  );

  testWidgets(
    'F3 entry opens global F5 and PUT preserves hidden supported types',
    (tester) async {
      final screen = await pumpRouter(tester, (request) async {
        if (request.path == settingsPath) {
          return jsonResponse(
            request.method == 'GET' ? settingsJson() : requestBody(request),
          );
        }
        return householdResponse(request);
      });
      await tapText(tester, NotificationStrings.entry);
      expect(screen.location, pagePath);
      expect(find.text(NotificationStrings.heading), findsOneWidget);
      expect(find.text('Solo prioridad alta'), findsNothing);
      expect(find.text('Resumen semanal'), findsNothing);
      await toggle(tester, 'task_due');
      await toggle(tester, 'muted');
      await tapText(tester, '1 h');
      await tapText(tester, NotificationStrings.save);
      final payload = requestBody(screen.harness.adapter.requests.last);
      expect(payload, {
        'muted': true,
        'muted_types': ['member_joined', 'swap_resolved', 'task_due'],
        'quiet_hours': {'start': '22:30', 'end': '07:30'},
        'reminder_lead_minutes': 60,
      });
      expect(find.text(NotificationStrings.saved), findsOneWidget);
      await tester.tap(find.byTooltip('Volver'));
      await settle(tester);
      expect(screen.location, '/households/settings');
    },
  );

  testWidgets(
    'GET404 exposes dependency retry and no editable defaults or fake save',
    (tester) async {
      var available = false;
      final screen = await pumpRouter(
        tester,
        (request) async => available
            ? jsonResponse(settingsJson(lead: null, quiet: false))
            : jsonResponse({'detail': 'Not Found'}, 404),
        path: pagePath,
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(NotificationStrings.dependency), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.byType(PrimaryButton), findsNothing);
      expect(screen.harness.adapter.requests.map((request) => request.method), [
        'GET',
      ]);
      available = true;
      await tapText(tester, 'Reintentar');
      expect(find.byType(SwitchListTile), findsNWidgets(9));
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '',
      );
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const ValueKey('quiet')))
            .value,
        isFalse,
      );
      await tapText(tester, NotificationStrings.save);
      expect(
        requestBody(screen.harness.adapter.requests.last)['quiet_hours'],
        isNull,
      );
      expect(
        requestBody(
          screen.harness.adapter.requests.last,
        )['reminder_lead_minutes'],
        isNull,
      );
    },
  );

  testWidgets(
    'save error preserves draft and prevents confirmation until server succeeds',
    (tester) async {
      var fail = true;
      final screen = await pumpRouter(tester, (request) async {
        if (request.method == 'GET') return jsonResponse(settingsJson());
        return fail
            ? apiError('VALIDATION_ERROR', 422)
            : jsonResponse(requestBody(request));
      }, path: pagePath);
      await toggle(tester, 'task_due');
      await enter(tester, NotificationStrings.lead, '10080');
      await enter(tester, NotificationStrings.start, '23:45');
      await enter(tester, NotificationStrings.end, '06:15');
      await tapText(tester, NotificationStrings.save);
      expect(find.text(NotificationStrings.saved), findsNothing);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const ValueKey('task_due')))
            .value,
        isFalse,
      );
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '10080',
      );
      fail = false;
      await tapText(tester, NotificationStrings.save);
      expect(find.text(NotificationStrings.saved), findsOneWidget);
      expect(requestBody(screen.harness.adapter.requests.last)['quiet_hours'], {
        'start': '23:45',
        'end': '06:15',
      });
    },
  );

  testWidgets(
    'invalid lead or quiet hours block PUT, disabling quiet sends null',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        (request) async => jsonResponse(
          request.method == 'GET' ? settingsJson() : requestBody(request),
        ),
        path: pagePath,
      );
      await enter(tester, NotificationStrings.lead, '4');
      await enter(tester, NotificationStrings.start, '24:00');
      await tapText(tester, NotificationStrings.save);
      expect(find.text(NotificationStrings.leadError), findsOneWidget);
      expect(find.text(NotificationStrings.timeError), findsOneWidget);
      expect(screen.harness.adapter.requests.length, 1);
      await enter(tester, NotificationStrings.lead, '');
      await toggle(tester, 'quiet');
      await tapText(tester, NotificationStrings.save);
      expect(
        requestBody(screen.harness.adapter.requests.last)['quiet_hours'],
        isNull,
      );
      expect(
        requestBody(
          screen.harness.adapter.requests.last,
        )['reminder_lead_minutes'],
        isNull,
      );
    },
  );

  testWidgets(
    'household switch keeps global draft without household GET or reset',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        (request) async => jsonResponse(settingsJson()),
        path: pagePath,
      );
      await enter(tester, NotificationStrings.lead, '45');
      final container = screen.harness.container;
      container
          .read(sessionControllerProvider.notifier)
          .confirmUser(
            container
                .read(sessionControllerProvider)
                .user!
                .copyWith(activeHouseholdId: 'household-2'),
          );
      await settle(tester);
      expect(screen.harness.adapter.requests.length, 1);
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '45',
      );
    },
  );

  testWidgets(
    'same-account new session discards draft and ignores late PUT success',
    (tester) async {
      final pending = Completer<ResponseBody>();
      var loads = 0;
      final screen = await pumpRouter(tester, (request) async {
        if (request.method == 'PUT') return pending.future;
        return jsonResponse(settingsJson(lead: ++loads == 1 ? 30 : 10));
      }, path: pagePath);
      await enter(tester, NotificationStrings.lead, '60');
      await tapText(tester, NotificationStrings.save);
      expect(
        tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
        isNull,
      );
      await tester.runAsync(screen.harness.signIn);
      await settle(tester);
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '10',
      );
      pending.complete(jsonResponse(settingsJson(lead: 60)));
      await settle(tester);
      expect(find.text(NotificationStrings.saved), findsNothing);
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '10',
      );
    },
  );

  testWidgets('F5 supports 200 percent text scale and accessible toggles', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpRouter(
        tester,
        (request) async => jsonResponse(settingsJson()),
        path: pagePath,
        scale: 2,
      );
      expect(tester.takeException(), isNull);
      final tile = find.byKey(const ValueKey('muted'));
      await tester.ensureVisible(tile);
      await tester.pump();
      expect(
        tester.getSemantics(tile).getSemanticsData().label,
        contains(NotificationStrings.muted),
      );
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      await tapText(tester, NotificationStrings.save);
      expect(tester.takeException(), isNull);
      expect(find.text(NotificationStrings.saved), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'PUT404 is an external dependency error and preserves the loaded draft',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        (request) async => request.method == 'GET'
            ? jsonResponse(settingsJson())
            : jsonResponse({'detail': 'Not Found'}, 404),
        path: pagePath,
      );
      await enter(tester, NotificationStrings.lead, '45');
      await tapText(tester, NotificationStrings.save);
      expect(find.text(NotificationStrings.dependency), findsOneWidget);
      expect(find.text(NotificationStrings.saved), findsNothing);
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.lead),
            )
            .controller!
            .text,
        '45',
      );
      expect(screen.harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
      ]);
    },
  );

  testWidgets(
    'malformed GET offers retry without rendering editable controls',
    (tester) async {
      await pumpRouter(
        tester,
        (request) async => jsonResponse({'muted': false}),
        path: pagePath,
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.text(NotificationStrings.save), findsNothing);
    },
  );

  testWidgets('Retry-After deadline re-enables save without losing draft', (
    tester,
  ) async {
    final screen = await pumpRouter(
      tester,
      (request) async => request.method == 'GET'
          ? jsonResponse(settingsJson())
          : apiError('RATE_LIMITED', 429, {'retry_after_seconds': 1}),
      path: pagePath,
    );
    await enter(tester, NotificationStrings.lead, '45');
    await tapText(tester, NotificationStrings.save);
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1200)),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<AppTextField>(
            find.widgetWithText(AppTextField, NotificationStrings.lead),
          )
          .controller!
          .text,
      '45',
    );
    expect(screen.harness.adapter.requests.length, 2);
  });

  testWidgets('late GET cannot reveal settings from another account', (
    tester,
  ) async {
    final old = Completer<ResponseBody>();
    var loads = 0;
    final screen = await pumpRouter(
      tester,
      (request) async => ++loads == 1
          ? old.future
          : jsonResponse(settingsJson(lead: 10, quiet: false)),
      path: pagePath,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);
    final container = screen.harness.container;
    final user = container
        .read(sessionControllerProvider)
        .user!
        .copyWith(id: 'user-2');
    await tester.runAsync(
      () => container
          .read(sessionControllerProvider.notifier)
          .establish(
            const TokenPair(
              accessToken: 'second',
              refreshToken: 'second-refresh',
              tokenType: 'bearer',
              expiresIn: 900,
            ),
            user,
          ),
    );
    await settle(tester);
    expect(
      tester
          .widget<AppTextField>(
            find.widgetWithText(AppTextField, NotificationStrings.lead),
          )
          .controller!
          .text,
      '10',
    );
    old.complete(jsonResponse(settingsJson(lead: 10080)));
    await settle(tester);
    expect(
      tester
          .widget<AppTextField>(
            find.widgetWithText(AppTextField, NotificationStrings.lead),
          )
          .controller!
          .text,
      '10',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout protects F5 route and never reuses previous settings', (
    tester,
  ) async {
    final screen = await pumpRouter(
      tester,
      (request) async => jsonResponse(settingsJson()),
      path: pagePath,
    );
    await tester.runAsync(
      () => screen.harness.container
          .read(sessionControllerProvider.notifier)
          .expire(),
    );
    await settle(tester);
    expect(screen.location, '/');
    screen.router.go(pagePath);
    await settle(tester);
    expect(screen.location, '/');
    expect(find.byType(SwitchListTile), findsNothing);
    expect(screen.harness.adapter.requests.length, 1);
  });

  testWidgets(
    'personal settings require authentication but no active household',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        (request) async => jsonResponse(settingsJson()),
        path: pagePath,
        activeId: null,
      );
      expect(screen.location, pagePath);
      expect(screen.harness.adapter.requests.single.path, settingsPath);
      expect(find.byType(SwitchListTile), findsNWidgets(9));
      await tester.tap(find.byTooltip('Volver'));
      await settle(tester);
      expect(screen.location, '/households/settings');
    },
  );

  testWidgets(
    'enabling quiet hours has no invented times and requires valid inputs',
    (tester) async {
      final screen = await pumpRouter(
        tester,
        (request) async => jsonResponse(
          request.method == 'GET'
              ? settingsJson(quiet: false)
              : requestBody(request),
        ),
        path: pagePath,
      );
      await toggle(tester, 'quiet');
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.start),
            )
            .controller!
            .text,
        '',
      );
      expect(
        tester
            .widget<AppTextField>(
              find.widgetWithText(AppTextField, NotificationStrings.end),
            )
            .controller!
            .text,
        '',
      );
      await tapText(tester, NotificationStrings.save);
      expect(find.text(NotificationStrings.timeError), findsNWidgets(2));
      expect(screen.harness.adapter.requests.length, 1);
      await enter(tester, NotificationStrings.start, '23:00');
      await enter(tester, NotificationStrings.end, '00:00');
      await tapText(tester, NotificationStrings.save);
      expect(requestBody(screen.harness.adapter.requests.last)['quiet_hours'], {
        'start': '23:00',
        'end': '00:00',
      });
    },
  );

  test(
    'rate-limited save retains confirmed data and blocks immediate retry',
    () async {
      final harness = N2Harness(
        (request) async => request.method == 'GET'
            ? jsonResponse(settingsJson())
            : apiError('RATE_LIMITED', 429, {'retry_after_seconds': 60}),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = notificationSettingsControllerProvider(actor(harness));
      final subscription = harness.container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      final draft = NotificationSettings.fromJson(settingsJson(lead: 60));
      expect(await controller.save(draft), isNull);
      final state = harness.container.read(provider).requireValue;
      expect(state.blocked, isTrue);
      expect(state.settings.reminderLeadMinutes, 30);
      expect(state.saved, isFalse);
      expect(await controller.save(draft), isNull);
      expect(harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
      ]);
    },
  );

  test(
    'reconciliation of a different saved value PUTs the current draft only after GET',
    () async {
      var server = settingsJson();
      var puts = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'GET') return jsonResponse(server);
        server = Map<String, Object?>.from(requestBody(request));
        if (++puts == 1) {
          throw DioException(
            requestOptions: request,
            type: DioExceptionType.receiveTimeout,
          );
        }
        return jsonResponse(server);
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = notificationSettingsControllerProvider(actor(harness));
      final subscription = harness.container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      expect(
        await controller.save(
          NotificationSettings.fromJson(settingsJson(lead: 60)),
        ),
        isNull,
      );
      final saved = await controller.save(
        NotificationSettings.fromJson(settingsJson(lead: 1440)),
      );
      expect(saved!.reminderLeadMinutes, 1440);
      expect(harness.adapter.requests.map((request) => request.method), [
        'GET',
        'PUT',
        'GET',
        'PUT',
      ]);
    },
  );
}
