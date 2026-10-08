import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/network/request_options.dart';
import 'package:hogar_app/features/capacity/domain/capacity_entities.dart';
import 'package:hogar_app/features/capacity/presentation/capacity_controller.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';

import 'n6_scenarios.dart';
import 'support/e2e_client.dart';

Future<void> exerciseCapacity(
  E2eClient admin,
  E2eClient member,
  E2eClient newcomer,
) async {
  final owner = await admin.register(name: 'N6 Capacity Admin');
  final guest = await member.register(name: 'N6 Capacity Member');
  final added = await newcomer.register(name: 'N6 Capacity Newcomer');
  final household = await createN6Household(admin);
  final id = household.id;
  await joinN6Household(admin, member, id);
  await admin.dio.patch<Object?>(
    '/households/$id',
    data: {'version': household.version, 'timezone': 'UTC'},
  );
  admin.probe.expectLast('PATCH', '/households/$id', 200, authenticated: true);
  final utcHousehold = await requireSuccess(admin.households.detail(id));
  expect(utcHousehold.timezone, 'UTC');
  expect(utcHousehold.version, household.version + 1);
  await requireSuccess(admin.profiles.updateNickname(id, 'Capacity owner'));
  await requireSuccess(member.profiles.updateNickname(id, 'Capacity guest'));
  expect(
    await admin.container
        .read(householdControllerProvider.notifier)
        .openExisting(id),
    isTrue,
  );
  final provider = capacityControllerProvider(id);
  final subscription = admin.container.listen(provider, (_, _) {});
  try {
    final initial = await admin.container.read(provider.future);
    expect(initial.overview.status, CapacityStatus.notConfigured);
    expect(initial.overview.current, isNull);
    expect(initial.overview.upcoming, isNull);
    expect(
      await admin.container.read(provider.notifier).saveProposal(35),
      isTrue,
    );
    final other = await requireSuccess(member.profiles.updateCapacity(id, 65));
    expect(other.userId, guest.user.id);
    expect(other.isMe, isTrue);
    final ownProfile = await requireSuccess(admin.profiles.profile(id));
    expect(ownProfile.proposedCapacityPercent, 35);
    expect(ownProfile.nickname, 'Capacity owner');
    expect(other.nickname, 'Capacity guest');
    final allocations = {owner.user.id: 40, guest.user.id: 60};
    requireFailure(
      await member.capacity.approve(id, allocations, IdempotentAction().key),
      ApiErrorCode.adminRequired,
      403,
    );
    member.probe.expectLast(
      'POST',
      '/households/$id/capacity/distributions',
      403,
    );
    for (final invalid in [
      {owner.user.id: 100},
      {owner.user.id: 40, guest.user.id: 50},
      {owner.user.id: 0, guest.user.id: 0},
    ]) {
      final error = requireFailure(
        await admin.capacity.approve(id, invalid, IdempotentAction().key),
        ApiErrorCode.capacitySumInvalid,
        422,
      );
      admin.probe.expectLast(
        'POST',
        '/households/$id/capacity/distributions',
        422,
      );
      expect(
        error.details['sum'],
        invalid.values.fold(0, (sum, value) => sum + value),
      );
    }
    expect((await requireSuccess(admin.capacity.history(id))).items, isEmpty);
    final before = DateTime.now().toUtc();
    expect(
      await admin.container.read(provider.notifier).approve(allocations),
      isTrue,
    );
    final approved = admin.container
        .read(provider)
        .requireValue
        .overview
        .upcoming!;
    expect(approved.approvedBy.userId, owner.user.id);
    expect(approved.approvedBy.isActive, isTrue);
    expect(approved.approvedAt.isUtc, isTrue);
    expect(
      approved.approvedAt.isBefore(before.subtract(const Duration(seconds: 5))),
      isFalse,
    );
    expect(
      approved.approvedAt.isAfter(
        DateTime.now().toUtc().add(const Duration(seconds: 5)),
      ),
      isFalse,
    );
    expect(approved.effectiveFrom, nextMonday(approved.approvedAt));
    expect({
      for (final value in approved.allocations)
        value.member.userId: value.percent,
    }, allocations);
    final overview = await requireSuccess(member.capacity.overview(id));
    member.probe.expectLast(
      'GET',
      '/households/$id/capacity',
      200,
      authenticated: true,
    );
    expect(overview.current, isNull);
    expect(overview.status, CapacityStatus.notConfigured);
    expect(overview.upcoming, approved);
    expect(
      {
        for (final value in overview.proposals)
          value.member.userId: value.proposedCapacityPercent,
      },
      {owner.user.id: 35, guest.user.id: 65},
    );
    expect(await requireSuccess(member.profiles.profile(id)), other);
    expect(await requireSuccess(admin.profiles.profile(id)), ownProfile);
    final changedProposal = await requireSuccess(
      admin.profiles.updateCapacity(id, 0),
    );
    expect(changedProposal.nickname, ownProfile.nickname);
    expect(changedProposal.proposedCapacityPercent, 0);
    expect(changedProposal.approvedCapacityPercent, isNull);
    expect(await requireSuccess(member.profiles.profile(id)), other);
    expect(
      (await requireSuccess(admin.capacity.overview(id))).upcoming,
      approved,
    );
    final action = IdempotentAction();
    final replacementValues = {owner.user.id: 25, guest.user.id: 75};
    final replacement = await requireSuccess(
      admin.capacity.approve(id, replacementValues, action.key),
    );
    admin.probe.expectLast(
      'POST',
      '/households/$id/capacity/distributions',
      201,
      authenticated: true,
    );
    expect(admin.probe.records.last.idempotencyKey, action.key);
    expect(replacement.id, isNot(approved.id));
    expect(replacement.effectiveFrom, approved.effectiveFrom);
    expect(
      await requireSuccess(
        admin.capacity.approve(id, replacementValues, action.key),
      ),
      replacement,
    );
    requireFailure(
      await admin.capacity.approve(id, allocations, action.key),
      ApiErrorCode.idempotencyKeyReused,
      409,
    );
    final history = await requireSuccess(member.capacity.history(id));
    member.probe.expectLast(
      'GET',
      '/households/$id/capacity/distributions',
      200,
    );
    expect(history.items, [replacement, approved]);
    expect(history.nextCursor, isNull);
    expect(
      (await requireSuccess(admin.capacity.overview(id))).upcoming,
      replacement,
    );
    expect(await admin.container.read(provider.notifier).loadHistory(), isTrue);
    expect(admin.container.read(provider).requireValue.history, history.items);

    await joinN6Household(admin, newcomer, id);
    final joined = await requireSuccess(admin.capacity.overview(id));
    expect(joined.status, CapacityStatus.notConfigured);
    expect(joined.current, isNull);
    expect(joined.upcoming, isNull);
    expect(
      joined.proposals.map((value) => value.member.userId),
      unorderedEquals([owner.user.id, guest.user.id, added.user.id]),
    );
    expect(
      (await requireSuccess(admin.capacity.history(id))).items,
      history.items,
    );
    final expanded = await requireSuccess(
      admin.capacity.approve(id, {
        owner.user.id: 25,
        guest.user.id: 50,
        added.user.id: 25,
      }, IdempotentAction().key),
    );
    expect(
      (await requireSuccess(admin.capacity.overview(id))).upcoming,
      expanded,
    );
    await requireSuccess(admin.households.removeMember(id, added.user.id));
    admin.probe.expectLast(
      'DELETE',
      '/households/$id/members/${added.user.id}',
      204,
    );
    final removed = await requireSuccess(admin.capacity.overview(id));
    expect(removed.status, CapacityStatus.notConfigured);
    expect(removed.current, isNull);
    expect(removed.upcoming, isNull);
    expect(
      removed.proposals.map((value) => value.member.userId),
      unorderedEquals([owner.user.id, guest.user.id]),
    );
    final preserved = await requireSuccess(admin.capacity.history(id));
    expect(preserved.items.map((value) => value.id), [
      expanded.id,
      replacement.id,
      approved.id,
    ]);
    final former = preserved.items.first.allocations.singleWhere(
      (value) => value.member.userId == added.user.id,
    );
    expect(former.percent, 25);
    expect(former.member.isActive, isFalse);
    expect(preserved.items.skip(1), history.items);
    expect(
      (await requireSuccess(
        member.profiles.profile(id),
      )).approvedCapacityPercent,
      isNull,
    );
    expect(
      (await requireSuccess(admin.households.detail(id))).version,
      utcHousehold.version,
    );
    requireFailure(
      await newcomer.capacity.overview(id),
      ApiErrorCode.householdNotFound,
      404,
    );
  } finally {
    subscription.close();
  }
}

String nextMonday(DateTime approvedAt) {
  final monday = DateTime.utc(
    approvedAt.year,
    approvedAt.month,
    approvedAt.day,
  ).add(Duration(days: 8 - approvedAt.weekday));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
}
