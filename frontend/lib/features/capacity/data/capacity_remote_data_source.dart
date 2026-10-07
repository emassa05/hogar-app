import 'package:dio/dio.dart';

import '../domain/capacity_entities.dart';
import 'capacity_dtos.dart';

class CapacityRemoteDataSource {
  const CapacityRemoteDataSource(this.dio);
  final Dio dio;

  String _path(String id) => '/households/$id/capacity';
  Future<CapacityOverview> overview(String id) async =>
      CapacityDtos.overview((await dio.get<Object?>(_path(id))).data);
  Future<CapacityDistribution> approve(
    String id,
    Map<String, int> allocations,
    String key,
  ) async => CapacityDtos.distribution(
    (await dio.post<Object?>(
      '${_path(id)}/distributions',
      options: Options(headers: {'Idempotency-Key': key}),
      data: {
        'allocations': [
          for (final entry in allocations.entries)
            {'user_id': entry.key, 'percent': entry.value},
        ],
      },
    )).data,
  );
  Future<CapacityHistory> history(String id, {String? cursor}) async =>
      CapacityDtos.history(
        (await dio.get<Object?>(
          '${_path(id)}/distributions',
          queryParameters: {if (cursor != null) 'cursor': cursor},
        )).data,
      );
}
