import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/network/request_options.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';

import 'profile_scenarios.dart';
import 'support/contract_report.dart';
import 'support/e2e_client.dart';
import 'template_scenarios.dart';

Future<void> exerciseHouseholds(
  E2eClient admin,
  E2eClient guest,
  ContractReport report,
) async {
  final creator = await admin.register(name: 'Household Admin');
  final member = await guest.register(name: 'Household Member', avatar: null);
  expect(await requireSuccess(admin.households.list()), isEmpty);
  final action = IdempotentAction();
  const name = 'Household API Smoke';
  final created = await requireSuccess(
    admin.households.create(name, action.key),
  );
  admin.probe.expectLast('POST', '/households', 201, authenticated: true);
  expect(admin.probe.records.last.idempotencyKey, action.key);
  expect(created.name, name);
  expect(created.timezone, 'America/Santiago');
  expect(created.myRole, MemberRole.admin);
  expect(created.members.single.userId, creator.user.id);
  expect(created.members.single.isMe, isTrue);
  expect(created.version, 1);
  expect(created.templatesApplied, isFalse);
  expect(
    await requireSuccess(admin.households.create(name, action.key)),
    created,
  );
  requireFailure(
    await admin.households.create('Different Household', action.key),
    ApiErrorCode.idempotencyKeyReused,
    409,
  );
  final summaries = await requireSuccess(admin.households.list());
  expect(summaries.single.id, created.id);
  expect(summaries.single.myRole, MemberRole.admin);
  expect(summaries.single.memberCount, 1);
  expect(
    (await requireSuccess(admin.auth.currentUser())).activeHouseholdId,
    created.id,
  );
  expect(await requireSuccess(admin.households.detail(created.id)), created);

  final updated = await requireSuccess(
    admin.households.update(
      created.id,
      created.version,
      'Renamed API Household',
    ),
  );
  expect(updated.version, created.version + 1);
  expect(updated.name, 'Renamed API Household');
  final stale = requireFailure(
    await admin.households.update(created.id, created.version, 'Stale Update'),
    ApiErrorCode.versionConflict,
    412,
  );
  expect(stale.details['current_version'], updated.version);
  expect(
    (await requireSuccess(admin.households.detail(created.id))).name,
    updated.name,
  );

  final invitation = await requireSuccess(
    admin.households.invitation(created.id),
  );
  expect(invitation.code, matches(r'^[0-9A-Z]{4}-[0-9A-Z]{4}$'));
  expect(invitation.shareUrl, endsWith('/${invitation.code}'));
  expect(invitation.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
  final normalizedCode = invitation.code.replaceAll('-', '').toLowerCase();
  final preview = await requireSuccess(
    guest.households.preview(normalizedCode),
  );
  expect(preview.householdId, created.id);
  expect(preview.householdName, updated.name);
  expect(preview.memberCount, 1);
  expect(preview.expiresAt, invitation.expiresAt);
  final accepted = await requireSuccess(
    guest.households.accept(normalizedCode),
  );
  guest.probe.expectLast(
    'POST',
    '/invitations/$normalizedCode/accept',
    201,
    authenticated: true,
  );
  expect(accepted.myRole, MemberRole.member);
  expect(accepted.members.length, 2);
  expect(
    accepted.members.singleWhere((value) => value.isMe).userId,
    member.user.id,
  );
  expect(
    (await requireSuccess(guest.auth.currentUser())).activeHouseholdId,
    created.id,
  );
  expect((await requireSuccess(guest.households.list())).single.memberCount, 2);
  requireFailure(
    await guest.households.accept(invitation.code),
    ApiErrorCode.alreadyMember,
    409,
  );
  requireFailure(
    await guest.households.invitation(created.id),
    ApiErrorCode.adminRequired,
    403,
  );
  requireFailure(
    await admin.households.changeRole(
      created.id,
      creator.user.id,
      MemberRole.member,
    ),
    ApiErrorCode.lastAdminMustTransfer,
    409,
  );

  await exerciseProfile(guest, created.id, member.user.id);
  expect(
    (await requireSuccess(admin.profiles.profile(created.id))).nickname,
    isNull,
  );
  await exerciseTemplates(admin, created.id, creator.user.id, report);
  expect(
    (await requireSuccess(
      admin.households.selectActive(created.id),
    )).activeHouseholdId,
    created.id,
  );

  final promoted = await requireSuccess(
    admin.households.changeRole(created.id, member.user.id, MemberRole.admin),
  );
  expect(promoted.userId, member.user.id);
  expect(promoted.role, MemberRole.admin);
  expect(promoted.isMe, isFalse);
  expect(
    (await requireSuccess(guest.households.detail(created.id))).myRole,
    MemberRole.admin,
  );
  final demoted = await requireSuccess(
    admin.households.changeRole(created.id, member.user.id, MemberRole.member),
  );
  expect(demoted.role, MemberRole.member);
  final regenerated = await requireSuccess(
    admin.households.regenerateInvitation(created.id),
  );
  expect(regenerated.code != invitation.code, isTrue);
  admin.probe.expectLast(
    'POST',
    '/households/${created.id}/invitation/regenerate',
    201,
  );
  requireFailure(
    await guest.households.preview(invitation.code),
    ApiErrorCode.invitationNotFound,
    404,
  );
  await requireSuccess(
    admin.households.removeMember(created.id, member.user.id),
  );
  admin.probe.expectLast(
    'DELETE',
    '/households/${created.id}/members/${member.user.id}',
    204,
  );
  expect(
    (await requireSuccess(
      admin.households.detail(created.id),
    )).members.single.userId,
    creator.user.id,
  );
  expect(await requireSuccess(guest.households.list()), isEmpty);
  expect(
    (await requireSuccess(guest.auth.currentUser())).activeHouseholdId,
    isNull,
  );
  requireFailure(
    await admin.households.removeMember(created.id, member.user.id),
    ApiErrorCode.memberNotFound,
    404,
  );
}
