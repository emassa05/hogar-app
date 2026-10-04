import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/l10n/error_messages.dart';
import 'package:hogar_app/features/profile/domain/profile_entities.dart';
import 'package:hogar_app/features/profile/domain/profile_repository.dart';
import 'package:intl/intl.dart';

import 'support/e2e_client.dart';

Future<void> exerciseProfile(
  E2eClient client,
  String householdId,
  String userId,
) async {
  final categories = await requireSuccess(client.catalog.categories());
  final activities = await requireSuccess(client.catalog.activities());
  expect(categories, isNotEmpty);
  expect(activities, isNotEmpty);
  expect(
    categories.every(
      (category) => category.key.isNotEmpty && category.name.isNotEmpty,
    ),
    isTrue,
  );
  expect(
    activities.every(
      (activity) =>
          categories.any((category) => category.key == activity.categoryKey),
    ),
    isTrue,
  );
  final activity = activities.firstWhere((activity) => activity.key == 'cook');
  final category = categories.firstWhere(
    (category) => category.key == 'cleaning',
  );
  final categoryActivity = activities.firstWhere(
    (activity) => activity.categoryKey == category.key,
  );
  final preferredActivity = activities.firstWhere(
    (candidate) =>
        candidate.key != activity.key && candidate.categoryKey != category.key,
  );

  final initial = await requireSuccess(client.profiles.profile(householdId));
  expect(initial.userId, userId);
  expect(initial.isMe, isTrue);
  expect(initial.nickname, isNull);
  expect(initial.restrictions, isEmpty);
  expect(initial.preferences.preferredActivityKeys, isEmpty);
  expect(initial.approvedCapacityPercent, isNull);
  final updated = await requireSuccess(
    client.profiles.update(householdId, 'API Nickname', 35),
  );
  expect(updated.nickname, 'API Nickname');
  expect(updated.displayName, 'API Nickname');
  expect(updated.proposedCapacityPercent, 35);
  expect(updated.approvedCapacityPercent, isNull);

  final date = DateFormat('yyyy-MM-dd');
  final now = DateTime.now().toUtc();
  final day = date.format(now.add(const Duration(days: 2)));
  final availability = Availability(
    slots: const [
      AvailabilitySlot(weekday: 0, period: DayPeriod.morning),
      AvailabilitySlot(weekday: 5, period: DayPeriod.evening),
    ],
    exceptions: [
      AvailabilityException(date: day, period: null, available: false),
    ],
  );
  expect(
    await requireSuccess(
      client.profiles.availability(householdId, availability),
    ),
    availability,
  );
  expect(
    (await requireSuccess(client.profiles.profile(householdId))).availability,
    availability,
  );
  const replacement = Availability(
    slots: [AvailabilitySlot(weekday: 2, period: DayPeriod.afternoon)],
    exceptions: [],
  );
  expect(
    await requireSuccess(
      client.profiles.availability(householdId, replacement),
    ),
    replacement,
  );
  expect(
    (await requireSuccess(client.profiles.profile(householdId))).availability,
    replacement,
  );

  final permanentInput = RestrictionInput(
    target: RestrictionTarget(
      type: RestrictionTargetType.activity,
      key: activity.key,
    ),
    kind: RestrictionKind.permanent,
  );
  final permanent = await requireSuccess(
    client.profiles.addRestriction(householdId, permanentInput),
  );
  expect(permanent.target, permanentInput.target);
  expect(permanent.targetName, activity.name);
  expect(permanent.kind, RestrictionKind.permanent);
  expect(permanent.endsOn, isNull);
  expect(permanent.isActive, isTrue);
  requireFailure(
    await client.profiles.addRestriction(householdId, permanentInput),
    ApiErrorCode.conflict,
    409,
  );
  final temporaryInput = RestrictionInput(
    target: RestrictionTarget(
      type: RestrictionTargetType.category,
      key: category.key,
    ),
    kind: RestrictionKind.temporary,
    startsOn: date.format(now.subtract(const Duration(days: 1))),
    endsOn: date.format(now.add(const Duration(days: 7))),
  );
  final temporary = await requireSuccess(
    client.profiles.addRestriction(householdId, temporaryInput),
  );
  expect(temporary.targetName, category.name);
  expect(temporary.startsOn, temporaryInput.startsOn);
  expect(temporary.endsOn, temporaryInput.endsOn);
  expect(temporary.isActive, isTrue);

  for (final key in [activity.key, categoryActivity.key]) {
    final conflict = requireFailure(
      await client.profiles.preferences(householdId, [key]),
      ApiErrorCode.validationError,
      422,
    );
    expect(conflict.fields, isNotEmpty);
    expect(conflict.fields.first.code, 'conflicting_values');
    expect(
      conflict.fields.first.fieldName,
      startsWith('preferred_activity_keys'),
    );
    expect(ErrorMessages.field(conflict, 'preferred_activity_keys'), isNotNull);
    expect(ErrorMessages.forField(conflict.fields.first), isNotEmpty);
  }
  final preferred = await requireSuccess(
    client.profiles.preferences(householdId, [preferredActivity.key]),
  );
  expect(preferred.preferredActivityKeys, [preferredActivity.key]);
  expect(
    (await requireSuccess(client.profiles.profile(householdId))).preferences,
    preferred,
  );

  final editedInput = RestrictionInput(
    target: permanent.target,
    kind: RestrictionKind.temporary,
    startsOn: temporaryInput.startsOn,
    endsOn: temporaryInput.endsOn,
  );
  final edited = await requireSuccess(
    client.profiles.editRestriction(householdId, permanent.id, editedInput),
  );
  expect(edited.id, permanent.id);
  expect(edited.kind, RestrictionKind.temporary);
  expect(edited.endsOn, editedInput.endsOn);
  final saved = await requireSuccess(client.profiles.profile(householdId));
  expect(
    saved.restrictions.map((restriction) => restriction.id),
    containsAll([permanent.id, temporary.id]),
  );
  await requireSuccess(
    client.profiles.removeRestriction(householdId, permanent.id),
  );
  await requireSuccess(
    client.profiles.removeRestriction(householdId, temporary.id),
  );
  expect(
    (await requireSuccess(client.profiles.profile(householdId))).restrictions,
    isEmpty,
  );
  requireFailure(
    await client.profiles.removeRestriction(householdId, permanent.id),
    ApiErrorCode.notFound,
    404,
  );
  final cleared = await requireSuccess(
    client.profiles.update(householdId, null, null),
  );
  expect(cleared.nickname, isNull);
  expect(cleared.proposedCapacityPercent, isNull);
  expect(
    (await requireSuccess(
      client.profiles.preferences(householdId, const []),
    )).preferredActivityKeys,
    isEmpty,
  );
}
