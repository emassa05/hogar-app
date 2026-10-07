import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_controller.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_strings.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';
import 'capacity_fixtures.dart';

Future<N2Harness> capacityHarness(HttpResponder responder) async {
  final harness = N2Harness(responder);
  addTearDown(harness.dispose);
  await harness.signIn();
  final subscription = harness.container.listen(
    capacityControllerProvider('household-1'),
    (_, _) {},
  );
  addTearDown(subscription.close);
  await harness.container.read(
    capacityControllerProvider('household-1').future,
  );
  return harness;
}

void main() {
  final provider = capacityControllerProvider('household-1');
  for (final response in [
    profileJson()..['proposed_capacity_percent'] = 30.5,
    profileJson()..['approved_capacity_percent'] = '30',
    profileJson()
      ..['user_id'] = 'user-2'
      ..['is_me'] = false,
  ]) {
    test(
      'malformed or foreign own-profile response cannot confirm a proposal: ${response['user_id']} ${response['proposed_capacity_percent']} ${response['approved_capacity_percent']}',
      () async {
        final server = CapacityServer();
        final harness = await capacityHarness(
          (request) async => request.method == 'PATCH'
              ? jsonResponse(response)
              : server.respond(request),
        );
        expect(
          await harness.container.read(provider.notifier).saveProposal(40),
          isFalse,
        );
        final state = harness.container.read(provider).requireValue;
        expect(state.savedPart, isEmpty);
        expect(state.overview.proposals.first.proposedCapacityPercent, 30);
        expect(state.overview.proposals.last.proposedCapacityPercent, 70);
      },
    );
  }
  test(
    'proposal saves only own proposal and does not change approved distribution',
    () async {
      final server = CapacityServer()..current = distributionJson(own: 20);
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.saveProposal(0), isTrue);
      final state = harness.container.read(provider).requireValue;
      expect(state.overview.current!.allocations.first.percent, 20);
      expect(state.overview.proposals.first.proposedCapacityPercent, 0);
      expect(state.savedPart, CapacityStrings.proposalSaved);
      expect(requestBody(harness.adapter.requests.last), {
        'proposed_capacity_percent': 0,
      });
    },
  );
  test(
    'proposal failure does not claim success and retries same value',
    () async {
      final server = CapacityServer()..proposalFails = true;
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.saveProposal(40), isFalse);
      expect(harness.container.read(provider).requireValue.savedPart, isEmpty);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .overview
            .proposals
            .first
            .proposedCapacityPercent,
        30,
      );
      server.proposalFails = false;
      expect(await controller.saveProposal(40), isTrue);
    },
  );
  test(
    'member cannot approve and admin cannot send incomplete or invalid sums',
    () async {
      final server = CapacityServer()..role = 'member';
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.approve({'user-1': 40, 'user-2': 60}), isFalse);
      server.role = 'admin';
      await controller.reload();
      for (final payload in [
        {'user-1': 100},
        {'user-1': 30, 'user-2': 60},
        {'user-1': -1, 'user-2': 101},
      ]) {
        expect(await controller.approve(payload), isFalse);
      }
      expect(
        harness.adapter.requests.where((request) => request.method == 'POST'),
        isEmpty,
      );
    },
  );
  test(
    'approval retries same intent with same key and changed payload gets new key',
    () async {
      final server = CapacityServer()..approvalError = 'SERVICE_UNAVAILABLE';
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.approve({'user-1': 40, 'user-2': 60}), isFalse);
      expect(await controller.approve({'user-1': 40, 'user-2': 60}), isFalse);
      expect(await controller.approve({'user-1': 50, 'user-2': 50}), isFalse);
      final requests = harness.adapter.requests
          .where((request) => request.method == 'POST')
          .toList();
      expect(
        requests[0].headers['Idempotency-Key'],
        requests[1].headers['Idempotency-Key'],
      );
      expect(
        requests[2].headers['Idempotency-Key'],
        isNot(requests[1].headers['Idempotency-Key']),
      );
      expect(harness.container.read(provider).requireValue.savedPart, isEmpty);
    },
  );
  test(
    'confirmed approval is kept when subsequent overview load fails and refresh never repeats approval',
    () async {
      final server = CapacityServer()..followUpFails = true;
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.approve({'user-1': 40, 'user-2': 60}), isFalse);
      final state = harness.container.read(provider).requireValue;
      expect(state.overview.upcoming!.allocations.first.percent, 40);
      expect(state.savedPart, contains(CapacityStrings.approvalSaved));
      expect(state.error, isNotNull);
      server.followUpFails = false;
      expect(await controller.reload(), isTrue);
      expect(
        harness.adapter.requests
            .where((request) => request.method == 'POST')
            .length,
        1,
      );
    },
  );
  test(
    'backend admin rejection reloads current authorization and does not fake approval',
    () async {
      final server = CapacityServer()..approvalError = 'ADMIN_REQUIRED';
      final harness = await capacityHarness(server.respond);
      server.role = 'member';
      expect(
        await harness.container.read(provider.notifier).approve({
          'user-1': 40,
          'user-2': 60,
        }),
        isFalse,
      );
      final state = harness.container.read(provider).requireValue;
      expect(state.role, MemberRole.member);
      expect(state.overview.upcoming, isNull);
      expect(state.error, isNotNull);
    },
  );
  test(
    'history appends opaque cursor pages; failure preserves confirmed prior page',
    () async {
      final server = CapacityServer()
        ..records = [distributionJson(id: 'two'), distributionJson(id: 'one')];
      final harness = await capacityHarness(server.respond);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.loadHistory(), isTrue);
      expect(harness.container.read(provider).requireValue.nextCursor, '1');
      server.historyFails = true;
      expect(await controller.loadHistory(), isFalse);
      expect(
        harness.container.read(provider).requireValue.history.single.id,
        'two',
      );
      server.historyFails = false;
      expect(await controller.loadHistory(), isTrue);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .history
            .map((value) => value.id),
        ['two', 'one'],
      );
      expect(harness.container.read(provider).requireValue.nextCursor, isNull);
    },
  );
  for (final action in ['proposal', 'approval']) {
    for (final identity in ['household', 'account', 'epoch']) {
      test('late $action cannot change state after $identity change', () async {
        final pending = Completer<ResponseBody>();
        final server = CapacityServer();
        final harness = await capacityHarness((request) async {
          if (request.method != 'GET') return pending.future;
          return server.respond(request);
        });
        final controller = harness.container.read(provider.notifier);
        final mutation = action == 'proposal'
            ? controller.saveProposal(0)
            : controller.approve({'user-1': 40, 'user-2': 60});
        await Future<void>.delayed(Duration.zero);
        final session = harness.container.read(
          sessionControllerProvider.notifier,
        );
        final user = harness.container.read(sessionControllerProvider).user!;
        if (identity == 'epoch') {
          await harness.signIn();
        } else {
          session.confirmUser(
            identity == 'account'
                ? user.copyWith(id: 'other-account')
                : user.copyWith(activeHouseholdId: 'household-2'),
          );
        }
        await Future<void>.delayed(Duration.zero);
        pending.complete(
          action == 'approval'
              ? jsonResponse(distributionJson(own: 40), 201)
              : jsonResponse({
                  'user_id': 'user-1',
                  'name': 'Marta',
                  'nickname': null,
                  'avatar': 'indigo',
                  'role': 'admin',
                  'is_me': true,
                  'proposed_capacity_percent': 0,
                  'approved_capacity_percent': null,
                  'availability': {
                    'slots': <Object?>[],
                    'exceptions': <Object?>[],
                  },
                  'restrictions': <Object?>[],
                  'preferences': {'preferred_activity_keys': <String>[]},
                }),
        );
        expect(await mutation, isFalse);
        if (identity != 'household') {
          await harness.container.read(provider.future);
          expect(
            harness.container.read(provider).requireValue.savedPart,
            isEmpty,
          );
          expect(
            harness.container.read(provider).requireValue.overview.upcoming,
            isNull,
          );
        }
      });
    }
  }
}
