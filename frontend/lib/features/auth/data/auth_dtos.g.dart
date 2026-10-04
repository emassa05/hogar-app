
part of 'auth_dtos.dart';


_$PhoneVerificationDtoImpl _$$PhoneVerificationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PhoneVerificationDtoImpl(
  verificationId: json['verification_id'] as String,
  phone: json['phone'] as String,
  purpose: json['purpose'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  resendAvailableAt: DateTime.parse(json['resend_available_at'] as String),
);

Map<String, dynamic> _$$PhoneVerificationDtoImplToJson(
  _$PhoneVerificationDtoImpl instance,
) => <String, dynamic>{
  'verification_id': instance.verificationId,
  'phone': instance.phone,
  'purpose': instance.purpose,
  'expires_at': instance.expiresAt.toIso8601String(),
  'resend_available_at': instance.resendAvailableAt.toIso8601String(),
};

_$VerificationTokenDtoImpl _$$VerificationTokenDtoImplFromJson(
  Map<String, dynamic> json,
) => _$VerificationTokenDtoImpl(
  verificationToken: json['verification_token'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$$VerificationTokenDtoImplToJson(
  _$VerificationTokenDtoImpl instance,
) => <String, dynamic>{
  'verification_token': instance.verificationToken,
  'expires_at': instance.expiresAt.toIso8601String(),
};

_$AuthSessionDtoImpl _$$AuthSessionDtoImplFromJson(Map<String, dynamic> json) =>
    _$AuthSessionDtoImpl(
      user: SessionUser.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthSessionDtoImplToJson(
  _$AuthSessionDtoImpl instance,
) => <String, dynamic>{
  'user': instance.user.toJson(),
  'tokens': instance.tokens.toJson(),
};
