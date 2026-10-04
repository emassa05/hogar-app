import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/template_entities.dart';
import '../domain/template_repository.dart';
import 'template_remote_data_source.dart';
part 'template_repository_impl.g.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  const TemplateRepositoryImpl(this.remote);
  final TemplateRemoteDataSource remote;
  @override
  Future<Result<List<TemplateSummary>>> list() => capture(
    () async => (await remote.list())
        .map((value) => value.toDomain())
        .toList(growable: false),
  );
  @override
  Future<Result<TemplateDetail>> detail(String key) =>
      capture(() async => (await remote.detail(key)).toDomain());
  @override
  Future<Result<TemplateApplication>> application(String id) =>
      capture(() async => (await remote.application(id)).toDomain());
  @override
  Future<Result<TemplateApplication>> apply(
    String id,
    List<String> keys,
    String actionKey,
  ) =>
      capture(() async => (await remote.apply(id, keys, actionKey)).toDomain());
}

@Riverpod(keepAlive: true)
TemplateRepository templateRepository(Ref ref) => TemplateRepositoryImpl(
  TemplateRemoteDataSource(ref.watch(dioClientProvider)),
);
