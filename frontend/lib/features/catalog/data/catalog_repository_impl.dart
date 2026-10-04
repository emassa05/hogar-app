import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/catalog_entities.dart';
import '../domain/catalog_repository.dart';
import 'catalog_remote_data_source.dart';
part 'catalog_repository_impl.g.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this.remote);
  final CatalogRemoteDataSource remote;
  @override
  Future<Result<List<TaskCategory>>> categories() => capture(
    () async => (await remote.categories())
        .map((value) => value.toDomain())
        .toList(growable: false),
  );
  @override
  Future<Result<List<Activity>>> activities() => capture(
    () async => (await remote.activities())
        .map((value) => value.toDomain())
        .toList(growable: false),
  );
}

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) => CatalogRepositoryImpl(
  CatalogRemoteDataSource(ref.watch(dioClientProvider)),
);
