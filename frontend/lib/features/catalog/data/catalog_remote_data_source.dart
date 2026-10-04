import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import 'catalog_dtos.dart';

class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this.dio);
  final Dio dio;
  Future<List<TaskCategoryDto>> categories() async => ApiResponse.objects(
    (await dio.get<Object?>('/catalog/task-categories')).data,
  ).map(TaskCategoryDto.fromJson).toList();
  Future<List<ActivityDto>> activities() async => ApiResponse.objects(
    (await dio.get<Object?>('/catalog/activities')).data,
  ).map(ActivityDto.fromJson).toList();
}
