part of 'profile_view_state.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$ProfileViewState {
  MemberProfile get profile => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;
  DateTime? get blockedUntil => throw _privateConstructorUsedError;
  String get savedPart => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileViewStateCopyWith<ProfileViewState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ProfileViewStateCopyWith<$Res> {
  factory $ProfileViewStateCopyWith(
    ProfileViewState value,
    $Res Function(ProfileViewState) then,
  ) = _$ProfileViewStateCopyWithImpl<$Res, ProfileViewState>;
  @useResult
  $Res call({
    MemberProfile profile,
    bool busy,
    AppException? error,
    DateTime? blockedUntil,
    String savedPart,
  });

  $MemberProfileCopyWith<$Res> get profile;
}

class _$ProfileViewStateCopyWithImpl<$Res, $Val extends ProfileViewState>
    implements $ProfileViewStateCopyWith<$Res> {
  _$ProfileViewStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? busy = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? savedPart = null,
  }) {
    return _then(
      _value.copyWith(
            profile: null == profile
                ? _value.profile
                : profile as MemberProfile,
            busy: null == busy ? _value.busy : busy as bool,
            error: freezed == error ? _value.error : error as AppException?,
            blockedUntil: freezed == blockedUntil
                ? _value.blockedUntil
                : blockedUntil as DateTime?,
            savedPart: null == savedPart
                ? _value.savedPart
                : savedPart as String,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $MemberProfileCopyWith<$Res> get profile {
    return $MemberProfileCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

abstract class _$$ProfileViewStateImplCopyWith<$Res>
    implements $ProfileViewStateCopyWith<$Res> {
  factory _$$ProfileViewStateImplCopyWith(
    _$ProfileViewStateImpl value,
    $Res Function(_$ProfileViewStateImpl) then,
  ) = __$$ProfileViewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MemberProfile profile,
    bool busy,
    AppException? error,
    DateTime? blockedUntil,
    String savedPart,
  });

  @override
  $MemberProfileCopyWith<$Res> get profile;
}

class __$$ProfileViewStateImplCopyWithImpl<$Res>
    extends _$ProfileViewStateCopyWithImpl<$Res, _$ProfileViewStateImpl>
    implements _$$ProfileViewStateImplCopyWith<$Res> {
  __$$ProfileViewStateImplCopyWithImpl(
    _$ProfileViewStateImpl _value,
    $Res Function(_$ProfileViewStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? busy = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? savedPart = null,
  }) {
    return _then(
      _$ProfileViewStateImpl(
        profile: null == profile ? _value.profile : profile as MemberProfile,
        busy: null == busy ? _value.busy : busy as bool,
        error: freezed == error ? _value.error : error as AppException?,
        blockedUntil: freezed == blockedUntil
            ? _value.blockedUntil
            : blockedUntil as DateTime?,
        savedPart: null == savedPart ? _value.savedPart : savedPart as String,
      ),
    );
  }
}

class _$ProfileViewStateImpl implements _ProfileViewState {
  const _$ProfileViewStateImpl({
    required this.profile,
    this.busy = false,
    this.error,
    this.blockedUntil,
    this.savedPart = '',
  });

  @override
  final MemberProfile profile;
  @override
  @JsonKey()
  final bool busy;
  @override
  final AppException? error;
  @override
  final DateTime? blockedUntil;
  @override
  @JsonKey()
  final String savedPart;

  @override
  String toString() {
    return 'ProfileViewState(profile: $profile, busy: $busy, error: $error, blockedUntil: $blockedUntil, savedPart: $savedPart)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileViewStateImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.blockedUntil, blockedUntil) ||
                other.blockedUntil == blockedUntil) &&
            (identical(other.savedPart, savedPart) ||
                other.savedPart == savedPart));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, profile, busy, error, blockedUntil, savedPart);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileViewStateImplCopyWith<_$ProfileViewStateImpl> get copyWith =>
      __$$ProfileViewStateImplCopyWithImpl<_$ProfileViewStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileViewState implements ProfileViewState {
  const factory _ProfileViewState({
    required final MemberProfile profile,
    final bool busy,
    final AppException? error,
    final DateTime? blockedUntil,
    final String savedPart,
  }) = _$ProfileViewStateImpl;

  @override
  MemberProfile get profile;
  @override
  bool get busy;
  @override
  AppException? get error;
  @override
  DateTime? get blockedUntil;
  @override
  String get savedPart;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileViewStateImplCopyWith<_$ProfileViewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
