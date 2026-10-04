import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/features/templates/presentation/template_controller.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';

ResponseBody templateReads(
  RequestOptions request, {
  bool applied = false,
  String role = 'admin',
}) {
  if (request.path == '/households/household-1') {
    return jsonResponse(householdJson(templatesApplied: applied, role: role));
  }
  if (request.path.endsWith('/template-application')) {
    return jsonResponse(applicationJson(keys: [], count: 0));
  }
  if (request.path == '/household-templates') {
    return jsonResponse([templateJson(), templateJson(key: 'pets', count: 6)]);
  }
  final key = request.path.split('/').last;
  return jsonResponse(
    templateJson(key: key, count: key == 'pets' ? 6 : 19, detail: true),
  );
}

void main() {
  test(
    'multiple template selections expose live totals and preview tasks with no writes',
    () async {
      final harness = N2Harness((request) async => templateReads(request));
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      controller.toggle('family');
      controller.toggle('pets');
      controller.toggle('unknown');
      final state = harness.container.read(provider).requireValue;
      expect(state.taskTotal, 25);
      expect(state.previewTasks.map((task) => task.activityKey), [
        'laundry_load',
        'dog_walk',
      ]);
      expect(
        harness.adapter.requests.where((request) => request.method != 'GET'),
        isEmpty,
      );
      controller.toggle('family');
      expect(harness.container.read(provider).requireValue.taskTotal, 6);
      expect(() => state.selected.clear(), throwsUnsupportedError);
    },
  );
  test(
    'template retry reuses key but a changed selection starts a new intention',
    () async {
      var attempts = 0;
      final keys = <String>[];
      final bodies = <List<String>>[];
      final harness = N2Harness((request) async {
        if (request.method == 'POST') {
          attempts++;
          keys.add(request.headers['Idempotency-Key'] as String);
          bodies.add(
            (requestBody(request)['template_keys'] as List<dynamic>)
                .cast<String>(),
          );
          if (attempts < 3) {
            throw DioException(
              requestOptions: request,
              type: DioExceptionType.receiveTimeout,
            );
          }
          return jsonResponse(
            applicationJson(keys: ['family', 'pets'], count: 25),
            201,
          );
        }
        return templateReads(request);
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      controller.toggle('family');
      expect(await controller.apply(), isFalse);
      expect(harness.container.read(provider).requireValue.application, isNull);
      expect(await controller.apply(), isFalse);
      expect(keys[1], keys[0]);
      controller.toggle('pets');
      expect(await controller.apply(), isTrue);
      expect(keys[2], isNot(keys[0]));
      expect(bodies.last, ['family', 'pets']);
      expect(
        harness.container.read(provider).requireValue.application!.taskCount,
        25,
      );
      expect(await controller.apply(), isFalse);
      expect(attempts, 3);
    },
  );
  test(
    'empty household choice posts an empty array and closes the template decision',
    () async {
      final harness = N2Harness((request) async {
        if (request.method == 'POST') {
          expect(requestBody(request), {'template_keys': <String>[]});
          return jsonResponse(applicationJson(keys: [], count: 0), 201);
        }
        return templateReads(request);
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      expect(await controller.apply(), isFalse);
      expect(await controller.apply(empty: true), isTrue);
      expect(
        harness.container.read(provider).requireValue.application!.templateKeys,
        isEmpty,
      );
      controller.toggle('family');
      expect(harness.container.read(provider).requireValue.selected, isEmpty);
    },
  );
  test(
    'server already applied conflict resolves to the existing confirmed decision',
    () async {
      final harness = N2Harness(
        (request) async => request.method == 'POST'
            ? apiError('TEMPLATES_ALREADY_APPLIED', 409)
            : templateReads(request),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      controller.toggle('family');
      expect(await controller.apply(), isTrue);
      final application = harness.container
          .read(provider)
          .requireValue
          .application!;
      expect(application.templateKeys, isEmpty);
      expect(application.taskCount, 0);
      expect(
        harness.adapter.requests.last.path,
        '/households/household-1/template-application',
      );
      expect(harness.adapter.requests.last.method, 'GET');
    },
  );
  test(
    'already decided households load the applied decision without template catalog requests',
    () async {
      final harness = N2Harness(
        (request) async => templateReads(request, applied: true),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final state = await harness.container.read(provider.future);
      expect(state.application, isNotNull);
      expect(harness.adapter.requests.length, 2);
    },
  );
  test(
    'non administrators cannot select or apply household templates',
    () async {
      final harness = N2Harness(
        (request) async => templateReads(request, role: 'member'),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await expectLater(
        harness.container.read(provider.future),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.adminRequired,
          ),
        ),
      );
      expect(
        await harness.container.read(provider.notifier).apply(empty: true),
        isFalse,
      );
      expect(harness.adapter.requests.length, 1);
    },
  );
  test(
    'single flight submit preserves selection and logout discards late application',
    () async {
      final gate = Completer<ResponseBody>();
      final harness = N2Harness(
        (request) async =>
            request.method == 'POST' ? gate.future : templateReads(request),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      controller.toggle('family');
      final pending = controller.apply();
      controller.toggle('pets');
      expect(harness.container.read(provider).requireValue.selected, {
        'family',
      });
      expect(await controller.apply(), isFalse);
      await harness.container.read(sessionControllerProvider.notifier).expire();
      gate.complete(jsonResponse(applicationJson(), 201));
      expect(await pending, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(harness.container.read(provider).hasError, isTrue);
    },
  );
  test(
    'rate limited application preserves selection and blocks early retries',
    () async {
      final harness = N2Harness(
        (request) async => request.method == 'POST'
            ? apiError('RATE_LIMITED', 429, {'retry_after_seconds': 60})
            : templateReads(request),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = templateControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      controller.toggle('family');
      expect(await controller.apply(), isFalse);
      expect(await controller.apply(), isFalse);
      expect(
        harness.adapter.requests
            .where((request) => request.method == 'POST')
            .length,
        1,
      );
      expect(harness.container.read(provider).requireValue.selected, {
        'family',
      });
      expect(
        harness.container.read(provider).requireValue.blockedUntil,
        isNotNull,
      );
    },
  );
}
