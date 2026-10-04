import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/profile_entities.dart';
part 'profile_view_state.freezed.dart';

@freezed
class ProfileViewState with _$ProfileViewState {
  const factory ProfileViewState({
    required MemberProfile profile,
    @Default(false) bool busy,
    AppException? error,
    DateTime? blockedUntil,
    @Default('') String savedPart,
  }) = _ProfileViewState;
}
