
part of 'auth_dtos.dart';


T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PhoneVerificationDto _$PhoneVerificationDtoFromJson(Map<String, dynamic> json) {
  return _PhoneVerificationDto.fromJson(json);
}

mixin _$PhoneVerificationDto {
  String get verificationId => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  DateTime get resendAvailableAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhoneVerificationDtoCopyWith<PhoneVerificationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $PhoneVerificationDtoCopyWith<$Res> {
  factory $PhoneVerificationDtoCopyWith(
    PhoneVerificationDto value,
    $Res Function(PhoneVerificationDto) then,
  ) = _$PhoneVerificationDtoCopyWithImpl<$Res, PhoneVerificationDto>;
  @useResult
  $Res call({
    String verificationId,
    String phone,
    String purpose,
    DateTime expiresAt,
    DateTime resendAvailableAt,
  });
}

class _$PhoneVerificationDtoCopyWithImpl<
  $Res,
  $Val extends PhoneVerificationDto
>
    implements $PhoneVerificationDtoCopyWith<$Res> {
  _$PhoneVerificationDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verificationId = null,
    Object? phone = null,
    Object? purpose = null,
    Object? expiresAt = null,
    Object? resendAvailableAt = null,
  }) {
    return _then(
      _value.copyWith(
            verificationId: null == verificationId
                ? _value.verificationId
                : verificationId
                      as String,
            phone: null == phone
                ? _value.phone
                : phone
                      as String,
            purpose: null == purpose
                ? _value.purpose
                : purpose
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt
                      as DateTime,
            resendAvailableAt: null == resendAvailableAt
                ? _value.resendAvailableAt
                : resendAvailableAt
                      as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$PhoneVerificationDtoImplCopyWith<$Res>
    implements $PhoneVerificationDtoCopyWith<$Res> {
  factory _$$PhoneVerificationDtoImplCopyWith(
    _$PhoneVerificationDtoImpl value,
    $Res Function(_$PhoneVerificationDtoImpl) then,
  ) = __$$PhoneVerificationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String verificationId,
    String phone,
    String purpose,
    DateTime expiresAt,
    DateTime resendAvailableAt,
  });
}

class __$$PhoneVerificationDtoImplCopyWithImpl<$Res>
    extends _$PhoneVerificationDtoCopyWithImpl<$Res, _$PhoneVerificationDtoImpl>
    implements _$$PhoneVerificationDtoImplCopyWith<$Res> {
  __$$PhoneVerificationDtoImplCopyWithImpl(
    _$PhoneVerificationDtoImpl _value,
    $Res Function(_$PhoneVerificationDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verificationId = null,
    Object? phone = null,
    Object? purpose = null,
    Object? expiresAt = null,
    Object? resendAvailableAt = null,
  }) {
    return _then(
      _$PhoneVerificationDtoImpl(
        verificationId: null == verificationId
            ? _value.verificationId
            : verificationId
                  as String,
        phone: null == phone
            ? _value.phone
            : phone
                  as String,
        purpose: null == purpose
            ? _value.purpose
            : purpose
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt
                  as DateTime,
        resendAvailableAt: null == resendAvailableAt
            ? _value.resendAvailableAt
            : resendAvailableAt
                  as DateTime,
      ),
    );
  }
}


@JsonSerializable(fieldRename: FieldRename.snake)
class _$PhoneVerificationDtoImpl extends _PhoneVerificationDto {
  const _$PhoneVerificationDtoImpl({
    required this.verificationId,
    required this.phone,
    required this.purpose,
    required this.expiresAt,
    required this.resendAvailableAt,
  }) : super._();

  factory _$PhoneVerificationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhoneVerificationDtoImplFromJson(json);

  @override
  final String verificationId;
  @override
  final String phone;
  @override
  final String purpose;
  @override
  final DateTime expiresAt;
  @override
  final DateTime resendAvailableAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhoneVerificationDtoImpl &&
            (identical(other.verificationId, verificationId) ||
                other.verificationId == verificationId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.resendAvailableAt, resendAvailableAt) ||
                other.resendAvailableAt == resendAvailableAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    verificationId,
    phone,
    purpose,
    expiresAt,
    resendAvailableAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhoneVerificationDtoImplCopyWith<_$PhoneVerificationDtoImpl>
  get copyWith =>
      __$$PhoneVerificationDtoImplCopyWithImpl<_$PhoneVerificationDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PhoneVerificationDtoImplToJson(this);
  }
}

abstract class _PhoneVerificationDto extends PhoneVerificationDto {
  const factory _PhoneVerificationDto({
    required final String verificationId,
    required final String phone,
    required final String purpose,
    required final DateTime expiresAt,
    required final DateTime resendAvailableAt,
  }) = _$PhoneVerificationDtoImpl;
  const _PhoneVerificationDto._() : super._();

  factory _PhoneVerificationDto.fromJson(Map<String, dynamic> json) =
      _$PhoneVerificationDtoImpl.fromJson;

  @override
  String get verificationId;
  @override
  String get phone;
  @override
  String get purpose;
  @override
  DateTime get expiresAt;
  @override
  DateTime get resendAvailableAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhoneVerificationDtoImplCopyWith<_$PhoneVerificationDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

VerificationTokenDto _$VerificationTokenDtoFromJson(Map<String, dynamic> json) {
  return _VerificationTokenDto.fromJson(json);
}

mixin _$VerificationTokenDto {
  String get verificationToken => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationTokenDtoCopyWith<VerificationTokenDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $VerificationTokenDtoCopyWith<$Res> {
  factory $VerificationTokenDtoCopyWith(
    VerificationTokenDto value,
    $Res Function(VerificationTokenDto) then,
  ) = _$VerificationTokenDtoCopyWithImpl<$Res, VerificationTokenDto>;
  @useResult
  $Res call({String verificationToken, DateTime expiresAt});
}

class _$VerificationTokenDtoCopyWithImpl<
  $Res,
  $Val extends VerificationTokenDto
>
    implements $VerificationTokenDtoCopyWith<$Res> {
  _$VerificationTokenDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? verificationToken = null, Object? expiresAt = null}) {
    return _then(
      _value.copyWith(
            verificationToken: null == verificationToken
                ? _value.verificationToken
                : verificationToken
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt
                      as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$VerificationTokenDtoImplCopyWith<$Res>
    implements $VerificationTokenDtoCopyWith<$Res> {
  factory _$$VerificationTokenDtoImplCopyWith(
    _$VerificationTokenDtoImpl value,
    $Res Function(_$VerificationTokenDtoImpl) then,
  ) = __$$VerificationTokenDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String verificationToken, DateTime expiresAt});
}

class __$$VerificationTokenDtoImplCopyWithImpl<$Res>
    extends _$VerificationTokenDtoCopyWithImpl<$Res, _$VerificationTokenDtoImpl>
    implements _$$VerificationTokenDtoImplCopyWith<$Res> {
  __$$VerificationTokenDtoImplCopyWithImpl(
    _$VerificationTokenDtoImpl _value,
    $Res Function(_$VerificationTokenDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? verificationToken = null, Object? expiresAt = null}) {
    return _then(
      _$VerificationTokenDtoImpl(
        verificationToken: null == verificationToken
            ? _value.verificationToken
            : verificationToken
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt
                  as DateTime,
      ),
    );
  }
}


@JsonSerializable(fieldRename: FieldRename.snake)
class _$VerificationTokenDtoImpl extends _VerificationTokenDto {
  const _$VerificationTokenDtoImpl({
    required this.verificationToken,
    required this.expiresAt,
  }) : super._();

  factory _$VerificationTokenDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationTokenDtoImplFromJson(json);

  @override
  final String verificationToken;
  @override
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationTokenDtoImpl &&
            (identical(other.verificationToken, verificationToken) ||
                other.verificationToken == verificationToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, verificationToken, expiresAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationTokenDtoImplCopyWith<_$VerificationTokenDtoImpl>
  get copyWith =>
      __$$VerificationTokenDtoImplCopyWithImpl<_$VerificationTokenDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationTokenDtoImplToJson(this);
  }
}

abstract class _VerificationTokenDto extends VerificationTokenDto {
  const factory _VerificationTokenDto({
    required final String verificationToken,
    required final DateTime expiresAt,
  }) = _$VerificationTokenDtoImpl;
  const _VerificationTokenDto._() : super._();

  factory _VerificationTokenDto.fromJson(Map<String, dynamic> json) =
      _$VerificationTokenDtoImpl.fromJson;

  @override
  String get verificationToken;
  @override
  DateTime get expiresAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationTokenDtoImplCopyWith<_$VerificationTokenDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) {
  return _AuthSessionDto.fromJson(json);
}

mixin _$AuthSessionDto {
  SessionUser get user => throw _privateConstructorUsedError;
  TokenPair get tokens => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthSessionDtoCopyWith<AuthSessionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AuthSessionDtoCopyWith<$Res> {
  factory $AuthSessionDtoCopyWith(
    AuthSessionDto value,
    $Res Function(AuthSessionDto) then,
  ) = _$AuthSessionDtoCopyWithImpl<$Res, AuthSessionDto>;
  @useResult
  $Res call({SessionUser user, TokenPair tokens});

  $SessionUserCopyWith<$Res> get user;
  $TokenPairCopyWith<$Res> get tokens;
}

class _$AuthSessionDtoCopyWithImpl<$Res, $Val extends AuthSessionDto>
    implements $AuthSessionDtoCopyWith<$Res> {
  _$AuthSessionDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? tokens = null}) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user
                      as SessionUser,
            tokens: null == tokens
                ? _value.tokens
                : tokens
                      as TokenPair,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $SessionUserCopyWith<$Res> get user {
    return $SessionUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TokenPairCopyWith<$Res> get tokens {
    return $TokenPairCopyWith<$Res>(_value.tokens, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }
}

abstract class _$$AuthSessionDtoImplCopyWith<$Res>
    implements $AuthSessionDtoCopyWith<$Res> {
  factory _$$AuthSessionDtoImplCopyWith(
    _$AuthSessionDtoImpl value,
    $Res Function(_$AuthSessionDtoImpl) then,
  ) = __$$AuthSessionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SessionUser user, TokenPair tokens});

  @override
  $SessionUserCopyWith<$Res> get user;
  @override
  $TokenPairCopyWith<$Res> get tokens;
}

class __$$AuthSessionDtoImplCopyWithImpl<$Res>
    extends _$AuthSessionDtoCopyWithImpl<$Res, _$AuthSessionDtoImpl>
    implements _$$AuthSessionDtoImplCopyWith<$Res> {
  __$$AuthSessionDtoImplCopyWithImpl(
    _$AuthSessionDtoImpl _value,
    $Res Function(_$AuthSessionDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? tokens = null}) {
    return _then(
      _$AuthSessionDtoImpl(
        user: null == user
            ? _value.user
            : user
                  as SessionUser,
        tokens: null == tokens
            ? _value.tokens
            : tokens
                  as TokenPair,
      ),
    );
  }
}


@JsonSerializable(explicitToJson: true)
class _$AuthSessionDtoImpl extends _AuthSessionDto {
  const _$AuthSessionDtoImpl({required this.user, required this.tokens})
    : super._();

  factory _$AuthSessionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthSessionDtoImplFromJson(json);

  @override
  final SessionUser user;
  @override
  final TokenPair tokens;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthSessionDtoImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, tokens);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthSessionDtoImplCopyWith<_$AuthSessionDtoImpl> get copyWith =>
      __$$AuthSessionDtoImplCopyWithImpl<_$AuthSessionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthSessionDtoImplToJson(this);
  }
}

abstract class _AuthSessionDto extends AuthSessionDto {
  const factory _AuthSessionDto({
    required final SessionUser user,
    required final TokenPair tokens,
  }) = _$AuthSessionDtoImpl;
  const _AuthSessionDto._() : super._();

  factory _AuthSessionDto.fromJson(Map<String, dynamic> json) =
      _$AuthSessionDtoImpl.fromJson;

  @override
  SessionUser get user;
  @override
  TokenPair get tokens;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthSessionDtoImplCopyWith<_$AuthSessionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
