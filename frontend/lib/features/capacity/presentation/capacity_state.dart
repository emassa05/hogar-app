import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../households/domain/household_entities.dart';
import '../domain/capacity_entities.dart';

part 'capacity_state.freezed.dart';

@freezed
class CapacityState with _$CapacityState {
  const factory CapacityState({
    required CapacityOverview overview,
    required MemberRole role,
    @Default(false) bool busy,
    @Default('') String savedPart,
    AppException? error,
    DateTime? blockedUntil,
    @Default([]) List<CapacityDistribution> history,
    @Default(false) bool historyLoaded,
    String? nextCursor,
  }) = _CapacityState;
}
