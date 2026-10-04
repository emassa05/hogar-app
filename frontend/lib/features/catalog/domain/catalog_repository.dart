import '../../../core/result/result.dart';
import 'catalog_entities.dart';

abstract interface class CatalogRepository {
  Future<Result<List<TaskCategory>>> categories();
  Future<Result<List<Activity>>> activities();
}
