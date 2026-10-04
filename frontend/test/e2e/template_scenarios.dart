import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/network/request_options.dart';

import 'support/contract_report.dart';
import 'support/e2e_client.dart';

Future<void> exerciseTemplates(
  E2eClient client,
  String householdId,
  String userId,
  ContractReport report,
) async {
  final summaries = await requireSuccess(client.templates.list());
  expect(summaries.length, greaterThanOrEqualTo(2));
  final keys = summaries.take(2).map((summary) => summary.key).toList();
  var total = 0;
  for (final summary in summaries) {
    final detail = await requireSuccess(client.templates.detail(summary.key));
    expect(detail.key, summary.key);
    expect(detail.name, summary.name);
    expect(detail.description, summary.description);
    expect(detail.taskCount, summary.taskCount);
    expect(detail.tasks.length, summary.taskCount);
    for (final task in detail.tasks) {
      expect(task.activityKey, isNotEmpty);
      expect(task.categoryKey, isNotEmpty);
      expect(task.name, isNotEmpty);
      expect(task.recurrenceLabel, isNotEmpty);
      expect(task.estimatedDurationMinutes, greaterThan(0));
      expect(task.effort, inInclusiveRange(1, 5));
      expect(task.mentalLoad, inInclusiveRange(1, 5));
    }
    if (keys.contains(summary.key)) total += detail.taskCount;
  }
  requireFailure(
    await client.templates.application(householdId),
    ApiErrorCode.notFound,
    404,
  );
  final invalid = requireFailure(
    await client.templates.apply(householdId, [
      'missing_template',
    ], IdempotentAction().key),
    ApiErrorCode.validationError,
    422,
  );
  expect(invalid.fields.first.code, 'unknown_key');

  final action = IdempotentAction();
  final applied = await requireSuccess(
    client.templates.apply(householdId, keys, action.key),
  );
  client.probe.expectLast(
    'POST',
    '/households/$householdId/template-application',
    201,
    authenticated: true,
  );
  expect(client.probe.records.last.idempotencyKey, action.key);
  expect(applied.templateKeys, keys);
  expect(applied.taskCount, total);
  expect(applied.appliedBy.userId, userId);
  expect(applied.appliedBy.displayName, 'Household Admin');
  expect(applied.appliedBy.isActive, isTrue);
  expect(
    await requireSuccess(client.templates.apply(householdId, keys, action.key)),
    applied,
  );
  expect(
    await requireSuccess(client.templates.application(householdId)),
    applied,
  );
  expect(
    (await requireSuccess(
      client.households.detail(householdId),
    )).templatesApplied,
    isTrue,
  );
  requireFailure(
    await client.templates.apply(householdId, keys, IdempotentAction().key),
    ApiErrorCode.templatesAlreadyApplied,
    409,
  );
  requireFailure(
    await client.templates.apply(householdId, const [], action.key),
    ApiErrorCode.idempotencyKeyReused,
    409,
  );

  await report.checkTemplateResources(client, householdId, applied);

  final emptyHousehold = await requireSuccess(
    client.households.create('Empty Template Smoke', IdempotentAction().key),
  );
  final empty = await requireSuccess(
    client.templates.apply(emptyHousehold.id, const [], IdempotentAction().key),
  );
  expect(empty.templateKeys, isEmpty);
  expect(empty.taskCount, 0);
  expect(
    (await requireSuccess(
      client.households.detail(emptyHousehold.id),
    )).templatesApplied,
    isTrue,
  );
  requireFailure(
    await client.templates.apply(
      emptyHousehold.id,
      keys,
      IdempotentAction().key,
    ),
    ApiErrorCode.templatesAlreadyApplied,
    409,
  );
}
