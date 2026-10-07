import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/session/session_user.dart';

part 'capacity_entities.freezed.dart';

enum CapacityStatus { configured, notConfigured }

@freezed
class CapacityMember with _$CapacityMember {
  const factory CapacityMember({
    required String userId,
    required String displayName,
    required AvatarChoice? avatar,
    required bool isActive,
  }) = _CapacityMember;
}

@freezed
class CapacityAllocation with _$CapacityAllocation {
  const factory CapacityAllocation({
    required CapacityMember member,
    required int percent,
  }) = _CapacityAllocation;
}

@freezed
class CapacityDistribution with _$CapacityDistribution {
  const factory CapacityDistribution({
    required String id,
    required String effectiveFrom,
    required CapacityMember approvedBy,
    required DateTime approvedAt,
    required List<CapacityAllocation> allocations,
  }) = _CapacityDistribution;
}

@freezed
class CapacityProposal with _$CapacityProposal {
  const factory CapacityProposal({
    required CapacityMember member,
    required int? proposedCapacityPercent,
  }) = _CapacityProposal;
}

@freezed
class CapacityOverview with _$CapacityOverview {
  const factory CapacityOverview({
    required CapacityStatus status,
    required CapacityDistribution? current,
    required CapacityDistribution? upcoming,
    required List<CapacityProposal> proposals,
  }) = _CapacityOverview;
}

@freezed
class CapacityHistory with _$CapacityHistory {
  const factory CapacityHistory({
    required List<CapacityDistribution> items,
    required String? nextCursor,
  }) = _CapacityHistory;
}
