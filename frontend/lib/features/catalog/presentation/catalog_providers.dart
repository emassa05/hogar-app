import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../data/catalog_repository_impl.dart';
import '../domain/catalog_entities.dart';
part 'catalog_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<TaskCategory>> taskCategories(Ref ref) async {
  final userId = ref.watch(
    sessionControllerProvider.select((value) => value.user?.id),
  );
  if (userId == null) throw const UnauthenticatedException();
  return (await ref.watch(catalogRepositoryProvider).categories()).valueOrThrow;
}

@Riverpod(keepAlive: true)
Future<List<Activity>> activities(Ref ref) async {
  final userId = ref.watch(
    sessionControllerProvider.select((value) => value.user?.id),
  );
  if (userId == null) throw const UnauthenticatedException();
  return (await ref.watch(catalogRepositoryProvider).activities()).valueOrThrow;
}
