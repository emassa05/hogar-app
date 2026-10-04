import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/result/result_value.dart';
import 'package:hogar_app/features/catalog/data/catalog_remote_data_source.dart';
import 'package:hogar_app/features/catalog/data/catalog_repository_impl.dart';
import 'package:hogar_app/features/catalog/domain/catalog_entities.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';

void main() {
  test(
    'catalog maps backend keys and categories without inventing activities',
    () async {
      final dio = Dio()
        ..httpClientAdapter = FakeHttpAdapter(
          (request) async => jsonResponse(
            request.path.endsWith('task-categories')
                ? categoriesJson()
                : activitiesJson(),
          ),
        );
      addTearDown(dio.close);
      final repository = CatalogRepositoryImpl(CatalogRemoteDataSource(dio));
      expect((await repository.categories()).valueOrThrow.first.name, 'Ropa');
      expect(
        (await repository.activities()).valueOrThrow.first.categoryKey,
        'laundry',
      );
    },
  );
  test('catalog network failure returns a typed result', () async {
    final dio = Dio()
      ..httpClientAdapter = FakeHttpAdapter(
        (request) async => throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      );
    addTearDown(dio.close);
    final result = await CatalogRepositoryImpl(
      CatalogRemoteDataSource(dio),
    ).activities();
    expect((result as Failure<List<Activity>>).error, isA<NetworkException>());
  });
}
