import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/household_entities.dart';
part 'household_flow_state.freezed.dart';

@freezed
class HouseholdFlowState with _$HouseholdFlowState {
  const factory HouseholdFlowState({
    HouseholdDetail? household,
    Invitation? invitation,
    InvitationPreview? preview,
    @Default('') String previewCode,
    @Default(false) bool busy,
    AppException? error,
    DateTime? blockedUntil,
    @Default('') String savedPart,
  }) = _HouseholdFlowState;
}
