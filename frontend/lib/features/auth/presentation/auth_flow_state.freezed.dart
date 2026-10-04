part of 'auth_flow_state.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$AuthFlowState {
  VerificationPurpose get purpose => throw _privateConstructorUsedError;
  PhoneVerification? get verification => throw _privateConstructorUsedError;
  VerificationProof? get proof => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  bool get accountCreated => throw _privateConstructorUsedError;
  int get errorPulse => throw _privateConstructorUsedError;
  DateTime? get blockedUntil => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthFlowStateCopyWith<AuthFlowState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AuthFlowStateCopyWith<$Res> {
  factory $AuthFlowStateCopyWith(
    AuthFlowState value,
    $Res Function(AuthFlowState) then,
  ) = _$AuthFlowStateCopyWithImpl<$Res, AuthFlowState>;
  @useResult
  $Res call({
    VerificationPurpose purpose,
    PhoneVerification? verification,
    VerificationProof? proof,
    String password,
    String name,
    AvatarChoice? avatar,
    bool busy,
    bool accountCreated,
    int errorPulse,
    DateTime? blockedUntil,
    AppException? error,
  });
}

class _$AuthFlowStateCopyWithImpl<$Res, $Val extends AuthFlowState>
    implements $AuthFlowStateCopyWith<$Res> {
  _$AuthFlowStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purpose = null,
    Object? verification = freezed,
    Object? proof = freezed,
    Object? password = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? busy = null,
    Object? accountCreated = null,
    Object? errorPulse = null,
    Object? blockedUntil = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            purpose: null == purpose
                ? _value.purpose
                : purpose as VerificationPurpose,
            verification: freezed == verification
                ? _value.verification
                : verification as PhoneVerification?,
            proof: freezed == proof
                ? _value.proof
                : proof as VerificationProof?,
            password: null == password ? _value.password : password as String,
            name: null == name ? _value.name : name as String,
            avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
            busy: null == busy ? _value.busy : busy as bool,
            accountCreated: null == accountCreated
                ? _value.accountCreated
                : accountCreated as bool,
            errorPulse: null == errorPulse
                ? _value.errorPulse
                : errorPulse as int,
            blockedUntil: freezed == blockedUntil
                ? _value.blockedUntil
                : blockedUntil as DateTime?,
            error: freezed == error ? _value.error : error as AppException?,
          )
          as $Val,
    );
  }
}

abstract class _$$AuthFlowStateImplCopyWith<$Res>
    implements $AuthFlowStateCopyWith<$Res> {
  factory _$$AuthFlowStateImplCopyWith(
    _$AuthFlowStateImpl value,
    $Res Function(_$AuthFlowStateImpl) then,
  ) = __$$AuthFlowStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VerificationPurpose purpose,
    PhoneVerification? verification,
    VerificationProof? proof,
    String password,
    String name,
    AvatarChoice? avatar,
    bool busy,
    bool accountCreated,
    int errorPulse,
    DateTime? blockedUntil,
    AppException? error,
  });
}

class __$$AuthFlowStateImplCopyWithImpl<$Res>
    extends _$AuthFlowStateCopyWithImpl<$Res, _$AuthFlowStateImpl>
    implements _$$AuthFlowStateImplCopyWith<$Res> {
  __$$AuthFlowStateImplCopyWithImpl(
    _$AuthFlowStateImpl _value,
    $Res Function(_$AuthFlowStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purpose = null,
    Object? verification = freezed,
    Object? proof = freezed,
    Object? password = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? busy = null,
    Object? accountCreated = null,
    Object? errorPulse = null,
    Object? blockedUntil = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AuthFlowStateImpl(
        purpose: null == purpose
            ? _value.purpose
            : purpose as VerificationPurpose,
        verification: freezed == verification
            ? _value.verification
            : verification as PhoneVerification?,
        proof: freezed == proof ? _value.proof : proof as VerificationProof?,
        password: null == password ? _value.password : password as String,
        name: null == name ? _value.name : name as String,
        avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
        busy: null == busy ? _value.busy : busy as bool,
        accountCreated: null == accountCreated
            ? _value.accountCreated
            : accountCreated as bool,
        errorPulse: null == errorPulse ? _value.errorPulse : errorPulse as int,
        blockedUntil: freezed == blockedUntil
            ? _value.blockedUntil
            : blockedUntil as DateTime?,
        error: freezed == error ? _value.error : error as AppException?,
      ),
    );
  }
}

class _$AuthFlowStateImpl implements _AuthFlowState {
  const _$AuthFlowStateImpl({
    this.purpose = VerificationPurpose.registration,
    this.verification,
    this.proof,
    this.password = '',
    this.name = '',
    this.avatar,
    this.busy = false,
    this.accountCreated = false,
    this.errorPulse = 0,
    this.blockedUntil,
    this.error,
  });

  @override
  @JsonKey()
  final VerificationPurpose purpose;
  @override
  final PhoneVerification? verification;
  @override
  final VerificationProof? proof;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String name;
  @override
  final AvatarChoice? avatar;
  @override
  @JsonKey()
  final bool busy;
  @override
  @JsonKey()
  final bool accountCreated;
  @override
  @JsonKey()
  final int errorPulse;
  @override
  final DateTime? blockedUntil;
  @override
  final AppException? error;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthFlowStateImpl &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.verification, verification) ||
                other.verification == verification) &&
            (identical(other.proof, proof) || other.proof == proof) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.accountCreated, accountCreated) ||
                other.accountCreated == accountCreated) &&
            (identical(other.errorPulse, errorPulse) ||
                other.errorPulse == errorPulse) &&
            (identical(other.blockedUntil, blockedUntil) ||
                other.blockedUntil == blockedUntil) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    purpose,
    verification,
    proof,
    password,
    name,
    avatar,
    busy,
    accountCreated,
    errorPulse,
    blockedUntil,
    error,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthFlowStateImplCopyWith<_$AuthFlowStateImpl> get copyWith =>
      __$$AuthFlowStateImplCopyWithImpl<_$AuthFlowStateImpl>(this, _$identity);
}

abstract class _AuthFlowState implements AuthFlowState {
  const factory _AuthFlowState({
    final VerificationPurpose purpose,
    final PhoneVerification? verification,
    final VerificationProof? proof,
    final String password,
    final String name,
    final AvatarChoice? avatar,
    final bool busy,
    final bool accountCreated,
    final int errorPulse,
    final DateTime? blockedUntil,
    final AppException? error,
  }) = _$AuthFlowStateImpl;

  @override
  VerificationPurpose get purpose;
  @override
  PhoneVerification? get verification;
  @override
  VerificationProof? get proof;
  @override
  String get password;
  @override
  String get name;
  @override
  AvatarChoice? get avatar;
  @override
  bool get busy;
  @override
  bool get accountCreated;
  @override
  int get errorPulse;
  @override
  DateTime? get blockedUntil;
  @override
  AppException? get error;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthFlowStateImplCopyWith<_$AuthFlowStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
