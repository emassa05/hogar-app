import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/session/session_user.dart';
import '../domain/auth_entities.dart';

part 'auth_flow_state.freezed.dart';

@Freezed(toStringOverride: false)
class AuthFlowState with _$AuthFlowState {
  const factory AuthFlowState({
    @Default(VerificationPurpose.registration) VerificationPurpose purpose,
    PhoneVerification? verification,
    VerificationProof? proof,
    @Default('') String password,
    @Default('') String name,
    AvatarChoice? avatar,
    @Default(false) bool busy,
    @Default(false) bool accountCreated,
    @Default(0) int errorPulse,
    DateTime? blockedUntil,
    AppException? error,
  }) = _AuthFlowState;
}
