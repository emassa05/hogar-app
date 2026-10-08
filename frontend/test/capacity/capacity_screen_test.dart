import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/widgets/app_buttons.dart';
import 'package:hogar_app/core/widgets/error_banner.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_strings.dart';
import 'package:hogar_app/features/capacity/presentation/widgets/capacity_distribution_card.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/profile/presentation/widgets/capacity_card.dart';

import '../core/n6_router_test.dart' show pumpRouter;
import '../support/fake_http_adapter.dart';
import '../support/n2_screen_harness.dart';
import 'capacity_fixtures.dart';

void setCapacity(WidgetTester tester, String key, int value) {
  final slider = tester.widget<Slider>(
    find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(Slider),
    ),
  );
  slider.onChanged!(value.toDouble());
}

void main() {
  testWidgets(
    'direct-route loading error back returns to settings without onboarding',
    (tester) async {
      final server = CapacityServer()..capacityFails = true;
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/capacity',
      );
      expect(find.byType(ErrorBanner), findsOneWidget);
      await tester.tap(find.byTooltip('Volver'));
      await settle(tester);
      expect(screen.location, '/households/settings');
    },
  );
  testWidgets('F3 entry opens F9 and members edit only own proposal', (
    tester,
  ) async {
    final server = CapacityServer()
      ..role = 'member'
      ..own = null;
    final screen = await pumpRouter(tester, server.respond);
    await tapText(tester, CapacityStrings.entry);
    expect(screen.location, '/households/household-1/capacity');
    expect(find.text(CapacityStrings.unconfigured), findsOneWidget);
    expect(find.text(CapacityStrings.noUpcoming), findsOneWidget);
    expect(find.byType(CapacityCard), findsOneWidget);
    expect(find.text(CapacityStrings.approve), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(
      tester.widget<CapacityCard>(find.byType(CapacityCard)).compact,
      isTrue,
    );
    expect(find.text(HouseholdStrings.capacityUnset), findsOneWidget);
    expect(find.text('70 %'), findsOneWidget);
    setCapacity(tester, 'own-capacity', 27);
    await tester.pump();
    await tapText(tester, CapacityStrings.saveProposal);
    expect(find.text(CapacityStrings.proposalSaved), findsOneWidget);
    final request = screen.harness.adapter.requests.firstWhere(
      (value) => value.method == 'PATCH',
    );
    expect(requestBody(request), {'proposed_capacity_percent': 27});
    expect(screen.location, '/households/household-1/capacity');
    await tester.tap(find.byTooltip('Volver'));
    await settle(tester);
    expect(screen.location, '/households/settings');
  });
  testWidgets(
    'admin approval is distinct from proposals and requires full sum100',
    (tester) async {
      final server = CapacityServer()
        ..current = distributionJson(
          id: 'current',
          own: 20,
          date: '2026-10-05',
        );
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/capacity',
      );
      expect(find.text(CapacityStrings.current), findsOneWidget);
      expect(find.byType(CapacityCard), findsNWidgets(3));
      setCapacity(tester, 'own-capacity', 27);
      setCapacity(tester, 'approval-user-1', 40);
      setCapacity(tester, 'approval-user-2', 50);
      await tester.pump();
      var approve = tester
          .widgetList<PrimaryButton>(find.byType(PrimaryButton))
          .firstWhere((value) => value.label == CapacityStrings.approve);
      expect(approve.onPressed, isNull);
      expect(find.text(CapacityStrings.total(90)), findsOneWidget);
      setCapacity(tester, 'approval-user-2', 60);
      await tester.pump();
      approve = tester
          .widgetList<PrimaryButton>(find.byType(PrimaryButton))
          .firstWhere((value) => value.label == CapacityStrings.approve);
      expect(approve.onPressed, isNotNull);
      expect(find.text(CapacityStrings.total(100)), findsOneWidget);
      expect(
        find.text('Suma 100 %. El reparto debe sumar 100 %.'),
        findsNothing,
      );
      await tapText(tester, CapacityStrings.approve);
      expect(find.text(CapacityStrings.upcoming), findsOneWidget);
      expect(
        find.textContaining(CapacityStrings.approvalSaved),
        findsOneWidget,
      );
      expect(server.own, 30);
      expect(server.other, 70);
      expect(
        tester
            .widget<CapacityCard>(find.byKey(const ValueKey('own-capacity')))
            .value,
        27,
      );
      expect(
        screen.harness.adapter.requests.where(
          (value) => value.method == 'PATCH',
        ),
        isEmpty,
      );
      final cards = tester.widgetList<CapacityDistributionCard>(
        find.byType(CapacityDistributionCard),
      );
      expect(cards.first.distribution.allocations.first.percent, 20);
      expect(cards.last.distribution.allocations.first.percent, 40);
      expect(
        find.text(CapacityStrings.effective('2026-10-12')),
        findsOneWidget,
      );
      expect(find.text(CapacityStrings.approver('Marta')), findsNWidgets(2));
    },
  );
  testWidgets(
    'compact readonly proposals distinguish unset capacity from zero',
    (tester) async {
      final server = CapacityServer()
        ..role = 'member'
        ..own = null
        ..other = null;
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/capacity',
        scale: 2,
      );
      expect(find.text(HouseholdStrings.capacityUnset), findsOneWidget);
      expect(find.text(CapacityStrings.unset), findsOneWidget);
      expect(find.text('0 %'), findsNothing);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text(CapacityStrings.approve), findsNothing);
      expect(
        screen.harness.adapter.requests.every(
          (request) => request.method == 'GET',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('N2 capacity card default keeps its explanatory scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CapacityCard(value: 35, onChanged: (_) {})),
      ),
    );
    expect(
      tester.widget<CapacityCard>(find.byType(CapacityCard)).compact,
      isFalse,
    );
    expect(find.text(HouseholdStrings.less), findsOneWidget);
    expect(find.text(HouseholdStrings.more), findsOneWidget);
    expect(find.text(HouseholdStrings.capacityHelp), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).divisions, 20);
  });
  testWidgets(
    'loading failure retries without fake data and history has empty paginated states',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final server = CapacityServer()..role = 'member';
      var first = true;
      await pumpRouter(tester, (request) async {
        if (request.path.endsWith('/capacity') && first) {
          first = false;
          return pending.future;
        }
        return server.respond(request);
      }, path: '/households/household-1/capacity');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CapacityCard), findsNothing);
      pending.complete(apiError('SERVICE_UNAVAILABLE', 503));
      await settle(tester);
      expect(find.byType(ErrorBanner), findsOneWidget);
      await tapText(tester, CapacityStrings.retry);
      expect(find.byType(CapacityCard), findsOneWidget);
      await tapText(tester, CapacityStrings.showHistory);
      expect(find.text(CapacityStrings.emptyHistory), findsOneWidget);
    },
  );
  testWidgets(
    'history shows percentages dates and former members with cursor load-more',
    (tester) async {
      final old = distributionJson(id: 'old')
        ..['approved_by'] = capacityMemberJson(active: false);
      ((old['allocations'] as List<dynamic>).last
          as Map<String, dynamic>)['member'] = capacityMemberJson(
        id: 'user-2',
        active: false,
      );
      final server = CapacityServer()
        ..role = 'member'
        ..records = [distributionJson(id: 'new'), old];
      final screen = await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/capacity',
      );
      await tapText(tester, CapacityStrings.showHistory);
      await tapText(tester, CapacityStrings.moreHistory);
      expect(find.textContaining(CapacityStrings.former), findsOneWidget);
      expect(find.byType(CapacityDistributionCard), findsNWidgets(2));
      expect(screen.harness.adapter.requests.last.queryParameters, {
        'cursor': '1',
      });
    },
  );
  testWidgets(
    'proposal errors keep draft and never claim saved until confirmed',
    (tester) async {
      final server = CapacityServer()
        ..role = 'member'
        ..proposalFails = true;
      await pumpRouter(
        tester,
        server.respond,
        path: '/households/household-1/capacity',
      );
      setCapacity(tester, 'own-capacity', 0);
      await tester.pump();
      await tapText(tester, CapacityStrings.saveProposal);
      expect(find.text(CapacityStrings.proposalSaved), findsNothing);
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        tester
            .widget<CapacityCard>(find.byKey(const ValueKey('own-capacity')))
            .value,
        0,
      );
      server.proposalFails = false;
      await tapText(tester, CapacityStrings.saveProposal);
      expect(find.text(CapacityStrings.proposalSaved), findsOneWidget);
    },
  );
  testWidgets(
    'pending mutation gates buttons and stale success cannot appear after household switch',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final server = CapacityServer();
      final screen = await pumpRouter(tester, (request) async {
        if (request.method == 'PATCH') return pending.future;
        return server.respond(request);
      }, path: '/households/household-1/capacity');
      setCapacity(tester, 'own-capacity', 0);
      await tester.pump();
      await tapText(tester, CapacityStrings.saveProposal);
      expect(
        tester
            .widgetList<PrimaryButton>(find.byType(PrimaryButton))
            .every((value) => value.onPressed == null),
        isTrue,
      );
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
      expect(find.text(CapacityStrings.unavailable), findsOneWidget);
      pending.complete(
        await server.respond(
          screen.harness.adapter.requests.firstWhere(
            (request) => request.method == 'PATCH',
          ),
        ),
      );
      await settle(tester);
      expect(find.text(CapacityStrings.proposalSaved), findsNothing);
      expect(find.byType(CapacityCard), findsNothing);
    },
  );
  for (final role in ['admin', 'member']) {
    testWidgets(
      'F9 $role supports 200 percent text scale and slider semantics without overflow',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          final server = CapacityServer()
            ..role = role
            ..current = distributionJson(own: 0);
          await pumpRouter(
            tester,
            server.respond,
            path: '/households/household-1/capacity',
            scale: 2,
          );
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
            find.byKey(const ValueKey('own-capacity')),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          final slider = find.descendant(
            of: find.byKey(const ValueKey('own-capacity')),
            matching: find.byType(Slider),
          );
          var hasAccessibleSlider = false;
          tester.getSemantics(slider).visitChildren((node) {
            final data = node.getSemanticsData();
            if (data.value == '30 %' &&
                data.increasedValue == '31 %' &&
                data.decreasedValue == '29 %') {
              hasAccessibleSlider = true;
            }
            return true;
          });
          expect(hasAccessibleSlider, isTrue);
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, -1600),
          );
          await settle(tester);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
