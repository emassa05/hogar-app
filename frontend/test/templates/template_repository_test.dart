import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/result/result_value.dart';
import 'package:hogar_app/features/templates/data/template_remote_data_source.dart';
import 'package:hogar_app/features/templates/data/template_repository_impl.dart';
import 'package:hogar_app/features/templates/domain/template_entities.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';

void main() {
  test(
    'templates map summaries, details and applied empty decisions',
    () async {
      final adapter = FakeHttpAdapter((request) async {
        if (request.path == '/household-templates') {
          return jsonResponse([templateJson()]);
        }
        if (request.path.startsWith('/household-templates/')) {
          return jsonResponse(templateJson(detail: true));
        }
        return jsonResponse(
          applicationJson(keys: [], count: 0),
          request.method == 'POST' ? 201 : 200,
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(dio.close);
      final repository = TemplateRepositoryImpl(TemplateRemoteDataSource(dio));
      expect((await repository.list()).valueOrThrow.single.taskCount, 19);
      final detail = (await repository.detail('family')).valueOrThrow;
      expect(detail.tasks.single.distribution, TaskDistribution.rotating);
      expect(() => detail.tasks.clear(), throwsUnsupportedError);
      expect(
        (await repository.apply(
          'household-1',
          [],
          'action-2',
        )).valueOrThrow.taskCount,
        0,
      );
      expect(requestBody(adapter.requests.last), {'template_keys': <String>[]});
      expect(adapter.requests.last.headers['Idempotency-Key'], 'action-2');
      expect(
        (await repository.application(
          'household-1',
        )).valueOrThrow.appliedBy.displayName,
        'Marta',
      );
    },
  );
  test(
    'already applied and undecided responses preserve their different codes',
    () async {
      final dio = Dio()
        ..httpClientAdapter = FakeHttpAdapter(
          (request) async => request.method == 'POST'
              ? apiError('TEMPLATES_ALREADY_APPLIED', 409)
              : apiError('NOT_FOUND', 404),
        );
      addTearDown(dio.close);
      final repository = TemplateRepositoryImpl(TemplateRemoteDataSource(dio));
      final undecided = await repository.application('household-1');
      expect(
        ((undecided as Failure<TemplateApplication>).error as ApiException)
            .code,
        ApiErrorCode.notFound,
      );
      final applied = await repository.apply('household-1', [
        'family',
      ], 'action-1');
      expect(
        ((applied as Failure<TemplateApplication>).error as ApiException).code,
        ApiErrorCode.templatesAlreadyApplied,
      );
    },
  );
}
