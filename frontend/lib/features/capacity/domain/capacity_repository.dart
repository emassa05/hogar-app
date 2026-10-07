import '../../../core/result/result.dart';
import 'capacity_entities.dart';

abstract interface class CapacityRepository {
  Future<Result<CapacityOverview>> overview(String householdId);
  Future<Result<CapacityDistribution>> approve(
    String householdId,
    Map<String, int> allocations,
    String key,
  );
  Future<Result<CapacityHistory>> history(String householdId, {String? cursor});
}
