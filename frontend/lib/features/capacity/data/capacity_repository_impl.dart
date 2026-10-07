import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/capacity_entities.dart';
import '../domain/capacity_repository.dart';
import 'capacity_remote_data_source.dart';

part 'capacity_repository_impl.g.dart';

class CapacityRepositoryImpl implements CapacityRepository {
  const CapacityRepositoryImpl(this.remote);
  final CapacityRemoteDataSource remote;

  @override
  Future<Result<CapacityOverview>> overview(String householdId) =>
      capture(() => remote.overview(householdId));
  @override
  Future<Result<CapacityDistribution>> approve(
    String householdId,
    Map<String, int> allocations,
    String key,
  ) => capture(() => remote.approve(householdId, allocations, key));
  @override
  Future<Result<CapacityHistory>> history(
    String householdId, {
    String? cursor,
  }) => capture(() => remote.history(householdId, cursor: cursor));
}

@Riverpod(keepAlive: true)
CapacityRepository capacityRepository(Ref ref) => CapacityRepositoryImpl(
  CapacityRemoteDataSource(ref.watch(dioClientProvider)),
);
