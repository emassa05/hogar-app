import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/network/request_options.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';
import 'package:hogar_app/features/notifications/domain/notification_settings.dart';
import 'package:hogar_app/features/profile/domain/profile_entities.dart';
import 'package:hogar_app/features/profile/domain/profile_repository.dart';
import 'package:hogar_app/features/profile/presentation/profile_controller.dart';

import 'support/e2e_client.dart';

Future<HouseholdDetail> createN6Household(E2eClient client) async {
  final action = IdempotentAction();
  final household = await requireSuccess(
    client.households.create('N6 ${action.key.substring(0, 8)}', action.key),
  );
  client.probe.expectLast('POST', '/households', 201, authenticated: true);
  return household;
}

Future<void> joinN6Household(
  E2eClient admin,
  E2eClient member,
  String householdId,
) async {
  final invitation = await requireSuccess(
    admin.households.invitation(householdId),
  );
  final household = await requireSuccess(
    member.households.accept(invitation.code),
  );
  expect(household.id, householdId);
  expect(household.myRole, MemberRole.member);
}

Future<void> exerciseN6Permissions(E2eClient admin, E2eClient member) async {
  final owner = await admin.register(name: 'N6 Owner');
  final guest = await member.register(name: 'N6 Guest');
  final household = await createN6Household(admin);
  await joinN6Household(admin, member, household.id);
  final id = household.id;
  final initial = await requireSuccess(member.households.detail(id));
  member.probe.expectLast('GET', '/households/$id', 200, authenticated: true);
  expect(initial.myRole, MemberRole.member);
  expect(
    initial.members.map((value) => value.userId),
    unorderedEquals([owner.user.id, guest.user.id]),
  );
  requireFailure(
    await member.households.update(id, initial.version, 'Unauthorized name'),
    ApiErrorCode.adminRequired,
    403,
  );
  member.probe.expectLast('PATCH', '/households/$id', 403, authenticated: true);
  requireFailure(
    await member.households.changeRole(id, guest.user.id, MemberRole.admin),
    ApiErrorCode.adminRequired,
    403,
  );
  member.probe.expectLast(
    'PATCH',
    '/households/$id/members/${guest.user.id}',
    403,
  );
  requireFailure(
    await member.households.removeMember(id, owner.user.id),
    ApiErrorCode.adminRequired,
    403,
  );
  member.probe.expectLast(
    'DELETE',
    '/households/$id/members/${owner.user.id}',
    403,
  );
  expect(
    await requireSuccess(admin.households.detail(id)),
    initial.copyWith(
      myRole: MemberRole.admin,
      members: [
        for (final value in initial.members)
          value.copyWith(isMe: value.userId == owner.user.id),
      ],
    ),
  );
  final renamed = await requireSuccess(
    admin.households.update(id, initial.version, 'Authorized N6 name'),
  );
  expect(renamed.name, 'Authorized N6 name');
  expect(renamed.version, initial.version + 1);
  final conflict = requireFailure(
    await admin.households.update(id, initial.version, 'Stale N6 name'),
    ApiErrorCode.versionConflict,
    412,
  );
  expect(conflict.details['current_version'], renamed.version);
  final persistedHousehold = await requireSuccess(member.households.detail(id));
  expect(persistedHousehold.name, renamed.name);
  expect(persistedHousehold.version, renamed.version);

  final controller = member.container.read(
    householdControllerProvider.notifier,
  );
  expect(await controller.openExisting(id), isTrue);
  final provider = profileControllerProvider(id);
  final subscription = member.container.listen(provider, (_, _) {});
  try {
    await member.container.read(provider.future);
    expect(
      await member.container
          .read(provider.notifier)
          .saveIdentity('Updated N6 Guest', 'Local nickname', AvatarChoice.sky),
      isTrue,
    );
    final persisted = await requireSuccess(member.auth.currentUser());
    expect(persisted.id, guest.user.id);
    expect(persisted.name, 'Updated N6 Guest');
    expect(persisted.avatar, AvatarChoice.sky);
    expect(member.user, persisted);
    final own = await requireSuccess(member.profiles.profile(id));
    expect(own.userId, guest.user.id);
    expect(own.isMe, isTrue);
    expect(own.nickname, 'Local nickname');
    final foreign = await requireSuccess(
      admin.profiles.profile(id, userId: guest.user.id),
    );
    admin.probe.expectLast(
      'GET',
      '/households/$id/members/${guest.user.id}/profile',
      200,
    );
    expect(foreign, own.copyWith(isMe: false));
    final category = (await requireSuccess(member.catalog.categories())).first;
    final input = RestrictionInput(
      target: RestrictionTarget(
        type: RestrictionTargetType.category,
        key: category.key,
      ),
      kind: RestrictionKind.permanent,
    );
    final restriction = await requireSuccess(
      member.profiles.addRestriction(id, input),
    );
    requireFailure(
      await admin.profiles.editRestriction(id, restriction.id, input),
      ApiErrorCode.notFound,
      404,
    );
    admin.probe.expectLast(
      'PUT',
      '/households/$id/members/me/restrictions/${restriction.id}',
      404,
    );
    requireFailure(
      await admin.profiles.removeRestriction(id, restriction.id),
      ApiErrorCode.notFound,
      404,
    );
    admin.probe.expectLast(
      'DELETE',
      '/households/$id/members/me/restrictions/${restriction.id}',
      404,
    );
    expect(
      (await requireSuccess(member.profiles.profile(id))).restrictions.single,
      restriction,
    );
    expect(
      (await requireSuccess(admin.profiles.profile(id))).restrictions,
      isEmpty,
    );
  } finally {
    subscription.close();
  }
  final second = await createN6Household(member);
  final independent = await requireSuccess(member.profiles.profile(second.id));
  expect(independent.nickname, isNull);
  expect(independent.name, 'Updated N6 Guest');
  expect(independent.avatar, AvatarChoice.sky);
  expect(independent.restrictions, isEmpty);
  expect(independent.proposedCapacityPercent, isNull);
  requireFailure(
    await admin.households.detail(second.id),
    ApiErrorCode.householdNotFound,
    404,
  );
  requireFailure(
    await admin.profiles.profile(second.id),
    ApiErrorCode.householdNotFound,
    404,
  );
  await requireSuccess(
    admin.households.changeRole(id, guest.user.id, MemberRole.admin),
  );
  expect(
    (await requireSuccess(member.households.detail(id))).myRole,
    MemberRole.admin,
  );
  await requireSuccess(
    admin.households.changeRole(id, guest.user.id, MemberRole.member),
  );
  await requireSuccess(admin.households.removeMember(id, guest.user.id));
  admin.probe.expectLast(
    'DELETE',
    '/households/$id/members/${guest.user.id}',
    204,
  );
  requireFailure(
    await member.households.detail(id),
    ApiErrorCode.householdNotFound,
    404,
  );
  requireFailure(
    await admin.profiles.profile(id, userId: guest.user.id),
    ApiErrorCode.memberNotFound,
    404,
  );
}

Future<void> exerciseN6SwitchAndLeave(E2eClient admin, E2eClient member) async {
  final owner = await admin.register(name: 'N6 Leaving Admin');
  await member.register(name: 'N6 Remaining Admin');
  final first = await createN6Household(admin);
  final second = await createN6Household(admin);
  await joinN6Household(admin, member, first.id);
  await joinN6Household(admin, member, second.id);
  await requireSuccess(admin.profiles.updateNickname(first.id, 'First home'));
  await requireSuccess(admin.profiles.updateNickname(second.id, 'Second home'));
  final controller = admin.container.read(householdControllerProvider.notifier);
  for (final household in [first, second, first]) {
    expect(await controller.openExisting(household.id), isTrue);
    admin.probe.expectLast('PATCH', '/users/me', 200, authenticated: true);
    expect(admin.user?.activeHouseholdId, household.id);
    expect(
      (await requireSuccess(admin.auth.currentUser())).activeHouseholdId,
      household.id,
    );
    final profile = await requireSuccess(admin.profiles.profile(household.id));
    expect(
      profile.nickname,
      household.id == first.id ? 'First home' : 'Second home',
    );
  }
  expect(
    (await requireSuccess(admin.households.list())).map((value) => value.id),
    unorderedEquals([first.id, second.id]),
  );
  expect(await controller.leave(first.id), isFalse);
  admin.probe.expectLast('POST', '/households/${first.id}/leave', 409);
  final error = admin.container.read(householdControllerProvider).error;
  expect(
    error,
    isA<ApiException>()
        .having(
          (value) => value.code,
          'code',
          ApiErrorCode.lastAdminMustTransfer,
        )
        .having((value) => value.statusCode, 'status', 409),
  );
  expect(admin.probe.records.last.error?['code'], 'LAST_ADMIN_MUST_TRANSFER');
  expect(admin.user?.activeHouseholdId, first.id);
  for (final household in [first, second]) {
    final remainingId = member.user!.id;
    await requireSuccess(
      admin.households.changeRole(household.id, remainingId, MemberRole.admin),
    );
    expect(
      (await requireSuccess(member.households.detail(household.id))).myRole,
      MemberRole.admin,
    );
  }
  expect(await controller.leave(first.id), isTrue);
  admin.probe.expectLast('POST', '/households/${first.id}/leave', 204);
  expect(admin.user?.activeHouseholdId, isNull);
  expect(
    (await requireSuccess(admin.auth.currentUser())).activeHouseholdId,
    isNull,
  );
  expect(
    (await admin.container.read(householdListProvider.future)).single.id,
    second.id,
  );
  expect(await admin.container.read(activeHouseholdProvider.future), isNull);
  requireFailure(
    await admin.households.detail(first.id),
    ApiErrorCode.householdNotFound,
    404,
  );
  expect(await controller.openExisting(second.id), isTrue);
  expect(admin.user?.activeHouseholdId, second.id);
  expect(await controller.leave(second.id), isTrue);
  expect(await admin.container.read(householdListProvider.future), isEmpty);
  final identity = await requireSuccess(admin.auth.currentUser());
  expect(identity.id, owner.user.id);
  expect(identity.name, owner.user.name);
  expect(identity.activeHouseholdId, isNull);
  expect(admin.user?.activeHouseholdId, isNull);
  expect(await admin.container.read(activeHouseholdProvider.future), isNull);
}

Future<void> exerciseMissingNotificationDependency(E2eClient client) async {
  await client.register(name: 'N6 Notification Dependency');
  const path = '/users/me/notification-settings';
  requireFailure(
    await client.notificationSettings.load(),
    ApiErrorCode.notFound,
    404,
  );
  client.probe.expectLast('GET', path, 404, authenticated: true);
  final input = NotificationSettings(
    muted: false,
    mutedTypes: ['swap_resolved'],
    quietHours: const QuietHours('22:00', '07:00'),
    reminderLeadMinutes: 60,
  );
  requireFailure(
    await client.notificationSettings.save(input),
    ApiErrorCode.notFound,
    404,
  );
  client.probe.expectLast('PUT', path, 404, authenticated: true);
  expect((await requireSuccess(client.auth.currentUser())).id, client.user?.id);
}
