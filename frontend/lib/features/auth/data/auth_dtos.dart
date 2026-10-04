import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/session/session_user.dart';
import '../../../core/session/token_pair.dart';
import '../domain/auth_entities.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

@Freezed(toStringOverride: false)
class PhoneVerificationDto with _$PhoneVerificationDto {
  const PhoneVerificationDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PhoneVerificationDto({required String verificationId, required String phone, required String purpose, required DateTime expiresAt, required DateTime resendAvailableAt}) = _PhoneVerificationDto;
  factory PhoneVerificationDto.fromJson(Map<String, dynamic> json) => _$PhoneVerificationDtoFromJson(json);
  PhoneVerification toDomain() => PhoneVerification(id: verificationId, phone: phone, purpose: purpose == 'registration' ? VerificationPurpose.registration : VerificationPurpose.passwordReset, expiresAt: expiresAt, resendAvailableAt: resendAvailableAt);
}

@Freezed(toStringOverride: false)
class VerificationTokenDto with _$VerificationTokenDto {
  const VerificationTokenDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VerificationTokenDto({required String verificationToken, required DateTime expiresAt}) = _VerificationTokenDto;
  factory VerificationTokenDto.fromJson(Map<String, dynamic> json) => _$VerificationTokenDtoFromJson(json);
  VerificationProof toDomain() => VerificationProof(token: verificationToken, expiresAt: expiresAt);
}

@Freezed(toStringOverride: false)
class AuthSessionDto with _$AuthSessionDto {
  const AuthSessionDto._();
  @JsonSerializable(explicitToJson: true)
  const factory AuthSessionDto({required SessionUser user, required TokenPair tokens}) = _AuthSessionDto;
  factory AuthSessionDto.fromJson(Map<String, dynamic> json) => _$AuthSessionDtoFromJson(json);
  AuthenticatedSession toDomain() => AuthenticatedSession(user: user, tokens: tokens);
}
