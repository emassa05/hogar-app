part of 'profile_dtos.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemberProfileDto _$MemberProfileDtoFromJson(Map<String, dynamic> json) {
  return _MemberProfileDto.fromJson(json);
}

mixin _$MemberProfileDto {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;
  int? get proposedCapacityPercent => throw _privateConstructorUsedError;
  int? get approvedCapacityPercent => throw _privateConstructorUsedError;
  AvailabilityDto get availability => throw _privateConstructorUsedError;
  List<RestrictionDto> get restrictions => throw _privateConstructorUsedError;
  PreferencesDto get preferences => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberProfileDtoCopyWith<MemberProfileDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $MemberProfileDtoCopyWith<$Res> {
  factory $MemberProfileDtoCopyWith(
    MemberProfileDto value,
    $Res Function(MemberProfileDto) then,
  ) = _$MemberProfileDtoCopyWithImpl<$Res, MemberProfileDto>;
  @useResult
  $Res call({
    String userId,
    String name,
    String? nickname,
    AvatarChoice? avatar,
    MemberRole role,
    bool isMe,
    int? proposedCapacityPercent,
    int? approvedCapacityPercent,
    AvailabilityDto availability,
    List<RestrictionDto> restrictions,
    PreferencesDto preferences,
  });

  $AvailabilityDtoCopyWith<$Res> get availability;
  $PreferencesDtoCopyWith<$Res> get preferences;
}

class _$MemberProfileDtoCopyWithImpl<$Res, $Val extends MemberProfileDto>
    implements $MemberProfileDtoCopyWith<$Res> {
  _$MemberProfileDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? nickname = freezed,
    Object? avatar = freezed,
    Object? role = null,
    Object? isMe = null,
    Object? proposedCapacityPercent = freezed,
    Object? approvedCapacityPercent = freezed,
    Object? availability = null,
    Object? restrictions = null,
    Object? preferences = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId ? _value.userId : userId as String,
            name: null == name ? _value.name : name as String,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname as String?,
            avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
            role: null == role ? _value.role : role as MemberRole,
            isMe: null == isMe ? _value.isMe : isMe as bool,
            proposedCapacityPercent: freezed == proposedCapacityPercent
                ? _value.proposedCapacityPercent
                : proposedCapacityPercent as int?,
            approvedCapacityPercent: freezed == approvedCapacityPercent
                ? _value.approvedCapacityPercent
                : approvedCapacityPercent as int?,
            availability: null == availability
                ? _value.availability
                : availability as AvailabilityDto,
            restrictions: null == restrictions
                ? _value.restrictions
                : restrictions as List<RestrictionDto>,
            preferences: null == preferences
                ? _value.preferences
                : preferences as PreferencesDto,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $AvailabilityDtoCopyWith<$Res> get availability {
    return $AvailabilityDtoCopyWith<$Res>(_value.availability, (value) {
      return _then(_value.copyWith(availability: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesDtoCopyWith<$Res> get preferences {
    return $PreferencesDtoCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

abstract class _$$MemberProfileDtoImplCopyWith<$Res>
    implements $MemberProfileDtoCopyWith<$Res> {
  factory _$$MemberProfileDtoImplCopyWith(
    _$MemberProfileDtoImpl value,
    $Res Function(_$MemberProfileDtoImpl) then,
  ) = __$$MemberProfileDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String name,
    String? nickname,
    AvatarChoice? avatar,
    MemberRole role,
    bool isMe,
    int? proposedCapacityPercent,
    int? approvedCapacityPercent,
    AvailabilityDto availability,
    List<RestrictionDto> restrictions,
    PreferencesDto preferences,
  });

  @override
  $AvailabilityDtoCopyWith<$Res> get availability;
  @override
  $PreferencesDtoCopyWith<$Res> get preferences;
}

class __$$MemberProfileDtoImplCopyWithImpl<$Res>
    extends _$MemberProfileDtoCopyWithImpl<$Res, _$MemberProfileDtoImpl>
    implements _$$MemberProfileDtoImplCopyWith<$Res> {
  __$$MemberProfileDtoImplCopyWithImpl(
    _$MemberProfileDtoImpl _value,
    $Res Function(_$MemberProfileDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? nickname = freezed,
    Object? avatar = freezed,
    Object? role = null,
    Object? isMe = null,
    Object? proposedCapacityPercent = freezed,
    Object? approvedCapacityPercent = freezed,
    Object? availability = null,
    Object? restrictions = null,
    Object? preferences = null,
  }) {
    return _then(
      _$MemberProfileDtoImpl(
        userId: null == userId ? _value.userId : userId as String,
        name: null == name ? _value.name : name as String,
        nickname: freezed == nickname ? _value.nickname : nickname as String?,
        avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
        role: null == role ? _value.role : role as MemberRole,
        isMe: null == isMe ? _value.isMe : isMe as bool,
        proposedCapacityPercent: freezed == proposedCapacityPercent
            ? _value.proposedCapacityPercent
            : proposedCapacityPercent as int?,
        approvedCapacityPercent: freezed == approvedCapacityPercent
            ? _value.approvedCapacityPercent
            : approvedCapacityPercent as int?,
        availability: null == availability
            ? _value.availability
            : availability as AvailabilityDto,
        restrictions: null == restrictions
            ? _value._restrictions
            : restrictions as List<RestrictionDto>,
        preferences: null == preferences
            ? _value.preferences
            : preferences as PreferencesDto,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$MemberProfileDtoImpl extends _MemberProfileDto {
  const _$MemberProfileDtoImpl({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.role,
    required this.isMe,
    required this.proposedCapacityPercent,
    required this.approvedCapacityPercent,
    required this.availability,
    required final List<RestrictionDto> restrictions,
    required this.preferences,
  }) : _restrictions = restrictions,
       super._();

  factory _$MemberProfileDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberProfileDtoImplFromJson(json);

  @override
  final String userId;
  @override
  final String name;
  @override
  final String? nickname;
  @override
  final AvatarChoice? avatar;
  @override
  final MemberRole role;
  @override
  final bool isMe;
  @override
  final int? proposedCapacityPercent;
  @override
  final int? approvedCapacityPercent;
  @override
  final AvailabilityDto availability;
  final List<RestrictionDto> _restrictions;
  @override
  List<RestrictionDto> get restrictions {
    if (_restrictions is EqualUnmodifiableListView) return _restrictions;
    return EqualUnmodifiableListView(_restrictions);
  }

  @override
  final PreferencesDto preferences;

  @override
  String toString() {
    return 'MemberProfileDto(userId: $userId, name: $name, nickname: $nickname, avatar: $avatar, role: $role, isMe: $isMe, proposedCapacityPercent: $proposedCapacityPercent, approvedCapacityPercent: $approvedCapacityPercent, availability: $availability, restrictions: $restrictions, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberProfileDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isMe, isMe) || other.isMe == isMe) &&
            (identical(
                  other.proposedCapacityPercent,
                  proposedCapacityPercent,
                ) ||
                other.proposedCapacityPercent == proposedCapacityPercent) &&
            (identical(
                  other.approvedCapacityPercent,
                  approvedCapacityPercent,
                ) ||
                other.approvedCapacityPercent == approvedCapacityPercent) &&
            (identical(other.availability, availability) ||
                other.availability == availability) &&
            const DeepCollectionEquality().equals(
              other._restrictions,
              _restrictions,
            ) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    name,
    nickname,
    avatar,
    role,
    isMe,
    proposedCapacityPercent,
    approvedCapacityPercent,
    availability,
    const DeepCollectionEquality().hash(_restrictions),
    preferences,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberProfileDtoImplCopyWith<_$MemberProfileDtoImpl> get copyWith =>
      __$$MemberProfileDtoImplCopyWithImpl<_$MemberProfileDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberProfileDtoImplToJson(this);
  }
}

abstract class _MemberProfileDto extends MemberProfileDto {
  const factory _MemberProfileDto({
    required final String userId,
    required final String name,
    required final String? nickname,
    required final AvatarChoice? avatar,
    required final MemberRole role,
    required final bool isMe,
    required final int? proposedCapacityPercent,
    required final int? approvedCapacityPercent,
    required final AvailabilityDto availability,
    required final List<RestrictionDto> restrictions,
    required final PreferencesDto preferences,
  }) = _$MemberProfileDtoImpl;
  const _MemberProfileDto._() : super._();

  factory _MemberProfileDto.fromJson(Map<String, dynamic> json) =
      _$MemberProfileDtoImpl.fromJson;

  @override
  String get userId;
  @override
  String get name;
  @override
  String? get nickname;
  @override
  AvatarChoice? get avatar;
  @override
  MemberRole get role;
  @override
  bool get isMe;
  @override
  int? get proposedCapacityPercent;
  @override
  int? get approvedCapacityPercent;
  @override
  AvailabilityDto get availability;
  @override
  List<RestrictionDto> get restrictions;
  @override
  PreferencesDto get preferences;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberProfileDtoImplCopyWith<_$MemberProfileDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailabilityDto _$AvailabilityDtoFromJson(Map<String, dynamic> json) {
  return _AvailabilityDto.fromJson(json);
}

mixin _$AvailabilityDto {
  List<AvailabilitySlotDto> get slots => throw _privateConstructorUsedError;
  List<AvailabilityExceptionDto> get exceptions =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilityDtoCopyWith<AvailabilityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilityDtoCopyWith<$Res> {
  factory $AvailabilityDtoCopyWith(
    AvailabilityDto value,
    $Res Function(AvailabilityDto) then,
  ) = _$AvailabilityDtoCopyWithImpl<$Res, AvailabilityDto>;
  @useResult
  $Res call({
    List<AvailabilitySlotDto> slots,
    List<AvailabilityExceptionDto> exceptions,
  });
}

class _$AvailabilityDtoCopyWithImpl<$Res, $Val extends AvailabilityDto>
    implements $AvailabilityDtoCopyWith<$Res> {
  _$AvailabilityDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null, Object? exceptions = null}) {
    return _then(
      _value.copyWith(
            slots: null == slots
                ? _value.slots
                : slots as List<AvailabilitySlotDto>,
            exceptions: null == exceptions
                ? _value.exceptions
                : exceptions as List<AvailabilityExceptionDto>,
          )
          as $Val,
    );
  }
}

abstract class _$$AvailabilityDtoImplCopyWith<$Res>
    implements $AvailabilityDtoCopyWith<$Res> {
  factory _$$AvailabilityDtoImplCopyWith(
    _$AvailabilityDtoImpl value,
    $Res Function(_$AvailabilityDtoImpl) then,
  ) = __$$AvailabilityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AvailabilitySlotDto> slots,
    List<AvailabilityExceptionDto> exceptions,
  });
}

class __$$AvailabilityDtoImplCopyWithImpl<$Res>
    extends _$AvailabilityDtoCopyWithImpl<$Res, _$AvailabilityDtoImpl>
    implements _$$AvailabilityDtoImplCopyWith<$Res> {
  __$$AvailabilityDtoImplCopyWithImpl(
    _$AvailabilityDtoImpl _value,
    $Res Function(_$AvailabilityDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null, Object? exceptions = null}) {
    return _then(
      _$AvailabilityDtoImpl(
        slots: null == slots
            ? _value._slots
            : slots as List<AvailabilitySlotDto>,
        exceptions: null == exceptions
            ? _value._exceptions
            : exceptions as List<AvailabilityExceptionDto>,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$AvailabilityDtoImpl extends _AvailabilityDto {
  const _$AvailabilityDtoImpl({
    required final List<AvailabilitySlotDto> slots,
    required final List<AvailabilityExceptionDto> exceptions,
  }) : _slots = slots,
       _exceptions = exceptions,
       super._();

  factory _$AvailabilityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilityDtoImplFromJson(json);

  final List<AvailabilitySlotDto> _slots;
  @override
  List<AvailabilitySlotDto> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    return EqualUnmodifiableListView(_slots);
  }

  final List<AvailabilityExceptionDto> _exceptions;
  @override
  List<AvailabilityExceptionDto> get exceptions {
    if (_exceptions is EqualUnmodifiableListView) return _exceptions;
    return EqualUnmodifiableListView(_exceptions);
  }

  @override
  String toString() {
    return 'AvailabilityDto(slots: $slots, exceptions: $exceptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilityDtoImpl &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            const DeepCollectionEquality().equals(
              other._exceptions,
              _exceptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_slots),
    const DeepCollectionEquality().hash(_exceptions),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilityDtoImplCopyWith<_$AvailabilityDtoImpl> get copyWith =>
      __$$AvailabilityDtoImplCopyWithImpl<_$AvailabilityDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilityDtoImplToJson(this);
  }
}

abstract class _AvailabilityDto extends AvailabilityDto {
  const factory _AvailabilityDto({
    required final List<AvailabilitySlotDto> slots,
    required final List<AvailabilityExceptionDto> exceptions,
  }) = _$AvailabilityDtoImpl;
  const _AvailabilityDto._() : super._();

  factory _AvailabilityDto.fromJson(Map<String, dynamic> json) =
      _$AvailabilityDtoImpl.fromJson;

  @override
  List<AvailabilitySlotDto> get slots;
  @override
  List<AvailabilityExceptionDto> get exceptions;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilityDtoImplCopyWith<_$AvailabilityDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailabilitySlotDto _$AvailabilitySlotDtoFromJson(Map<String, dynamic> json) {
  return _AvailabilitySlotDto.fromJson(json);
}

mixin _$AvailabilitySlotDto {
  int get weekday => throw _privateConstructorUsedError;
  DayPeriod get period => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilitySlotDtoCopyWith<AvailabilitySlotDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilitySlotDtoCopyWith<$Res> {
  factory $AvailabilitySlotDtoCopyWith(
    AvailabilitySlotDto value,
    $Res Function(AvailabilitySlotDto) then,
  ) = _$AvailabilitySlotDtoCopyWithImpl<$Res, AvailabilitySlotDto>;
  @useResult
  $Res call({int weekday, DayPeriod period});
}

class _$AvailabilitySlotDtoCopyWithImpl<$Res, $Val extends AvailabilitySlotDto>
    implements $AvailabilitySlotDtoCopyWith<$Res> {
  _$AvailabilitySlotDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? weekday = null, Object? period = null}) {
    return _then(
      _value.copyWith(
            weekday: null == weekday ? _value.weekday : weekday as int,
            period: null == period ? _value.period : period as DayPeriod,
          )
          as $Val,
    );
  }
}

abstract class _$$AvailabilitySlotDtoImplCopyWith<$Res>
    implements $AvailabilitySlotDtoCopyWith<$Res> {
  factory _$$AvailabilitySlotDtoImplCopyWith(
    _$AvailabilitySlotDtoImpl value,
    $Res Function(_$AvailabilitySlotDtoImpl) then,
  ) = __$$AvailabilitySlotDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int weekday, DayPeriod period});
}

class __$$AvailabilitySlotDtoImplCopyWithImpl<$Res>
    extends _$AvailabilitySlotDtoCopyWithImpl<$Res, _$AvailabilitySlotDtoImpl>
    implements _$$AvailabilitySlotDtoImplCopyWith<$Res> {
  __$$AvailabilitySlotDtoImplCopyWithImpl(
    _$AvailabilitySlotDtoImpl _value,
    $Res Function(_$AvailabilitySlotDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? weekday = null, Object? period = null}) {
    return _then(
      _$AvailabilitySlotDtoImpl(
        weekday: null == weekday ? _value.weekday : weekday as int,
        period: null == period ? _value.period : period as DayPeriod,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$AvailabilitySlotDtoImpl extends _AvailabilitySlotDto {
  const _$AvailabilitySlotDtoImpl({required this.weekday, required this.period})
    : super._();

  factory _$AvailabilitySlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilitySlotDtoImplFromJson(json);

  @override
  final int weekday;
  @override
  final DayPeriod period;

  @override
  String toString() {
    return 'AvailabilitySlotDto(weekday: $weekday, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilitySlotDtoImpl &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weekday, period);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilitySlotDtoImplCopyWith<_$AvailabilitySlotDtoImpl> get copyWith =>
      __$$AvailabilitySlotDtoImplCopyWithImpl<_$AvailabilitySlotDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilitySlotDtoImplToJson(this);
  }
}

abstract class _AvailabilitySlotDto extends AvailabilitySlotDto {
  const factory _AvailabilitySlotDto({
    required final int weekday,
    required final DayPeriod period,
  }) = _$AvailabilitySlotDtoImpl;
  const _AvailabilitySlotDto._() : super._();

  factory _AvailabilitySlotDto.fromJson(Map<String, dynamic> json) =
      _$AvailabilitySlotDtoImpl.fromJson;

  @override
  int get weekday;
  @override
  DayPeriod get period;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilitySlotDtoImplCopyWith<_$AvailabilitySlotDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailabilityExceptionDto _$AvailabilityExceptionDtoFromJson(
  Map<String, dynamic> json,
) {
  return _AvailabilityExceptionDto.fromJson(json);
}

mixin _$AvailabilityExceptionDto {
  String get date => throw _privateConstructorUsedError;
  DayPeriod? get period => throw _privateConstructorUsedError;
  bool get available => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilityExceptionDtoCopyWith<AvailabilityExceptionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilityExceptionDtoCopyWith<$Res> {
  factory $AvailabilityExceptionDtoCopyWith(
    AvailabilityExceptionDto value,
    $Res Function(AvailabilityExceptionDto) then,
  ) = _$AvailabilityExceptionDtoCopyWithImpl<$Res, AvailabilityExceptionDto>;
  @useResult
  $Res call({String date, DayPeriod? period, bool available});
}

class _$AvailabilityExceptionDtoCopyWithImpl<
  $Res,
  $Val extends AvailabilityExceptionDto
>
    implements $AvailabilityExceptionDtoCopyWith<$Res> {
  _$AvailabilityExceptionDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? period = freezed,
    Object? available = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date ? _value.date : date as String,
            period: freezed == period ? _value.period : period as DayPeriod?,
            available: null == available ? _value.available : available as bool,
          )
          as $Val,
    );
  }
}

abstract class _$$AvailabilityExceptionDtoImplCopyWith<$Res>
    implements $AvailabilityExceptionDtoCopyWith<$Res> {
  factory _$$AvailabilityExceptionDtoImplCopyWith(
    _$AvailabilityExceptionDtoImpl value,
    $Res Function(_$AvailabilityExceptionDtoImpl) then,
  ) = __$$AvailabilityExceptionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, DayPeriod? period, bool available});
}

class __$$AvailabilityExceptionDtoImplCopyWithImpl<$Res>
    extends
        _$AvailabilityExceptionDtoCopyWithImpl<
          $Res,
          _$AvailabilityExceptionDtoImpl
        >
    implements _$$AvailabilityExceptionDtoImplCopyWith<$Res> {
  __$$AvailabilityExceptionDtoImplCopyWithImpl(
    _$AvailabilityExceptionDtoImpl _value,
    $Res Function(_$AvailabilityExceptionDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? period = freezed,
    Object? available = null,
  }) {
    return _then(
      _$AvailabilityExceptionDtoImpl(
        date: null == date ? _value.date : date as String,
        period: freezed == period ? _value.period : period as DayPeriod?,
        available: null == available ? _value.available : available as bool,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$AvailabilityExceptionDtoImpl extends _AvailabilityExceptionDto {
  const _$AvailabilityExceptionDtoImpl({
    required this.date,
    required this.period,
    required this.available,
  }) : super._();

  factory _$AvailabilityExceptionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilityExceptionDtoImplFromJson(json);

  @override
  final String date;
  @override
  final DayPeriod? period;
  @override
  final bool available;

  @override
  String toString() {
    return 'AvailabilityExceptionDto(date: $date, period: $period, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilityExceptionDtoImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, period, available);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilityExceptionDtoImplCopyWith<_$AvailabilityExceptionDtoImpl>
  get copyWith =>
      __$$AvailabilityExceptionDtoImplCopyWithImpl<
        _$AvailabilityExceptionDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilityExceptionDtoImplToJson(this);
  }
}

abstract class _AvailabilityExceptionDto extends AvailabilityExceptionDto {
  const factory _AvailabilityExceptionDto({
    required final String date,
    required final DayPeriod? period,
    required final bool available,
  }) = _$AvailabilityExceptionDtoImpl;
  const _AvailabilityExceptionDto._() : super._();

  factory _AvailabilityExceptionDto.fromJson(Map<String, dynamic> json) =
      _$AvailabilityExceptionDtoImpl.fromJson;

  @override
  String get date;
  @override
  DayPeriod? get period;
  @override
  bool get available;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilityExceptionDtoImplCopyWith<_$AvailabilityExceptionDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RestrictionDto _$RestrictionDtoFromJson(Map<String, dynamic> json) {
  return _RestrictionDto.fromJson(json);
}

mixin _$RestrictionDto {
  String get id => throw _privateConstructorUsedError;
  RestrictionTargetDto get target => throw _privateConstructorUsedError;
  String get targetName => throw _privateConstructorUsedError;
  RestrictionKind get kind => throw _privateConstructorUsedError;
  String get startsOn => throw _privateConstructorUsedError;
  String? get endsOn => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestrictionDtoCopyWith<RestrictionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $RestrictionDtoCopyWith<$Res> {
  factory $RestrictionDtoCopyWith(
    RestrictionDto value,
    $Res Function(RestrictionDto) then,
  ) = _$RestrictionDtoCopyWithImpl<$Res, RestrictionDto>;
  @useResult
  $Res call({
    String id,
    RestrictionTargetDto target,
    String targetName,
    RestrictionKind kind,
    String startsOn,
    String? endsOn,
    bool isActive,
    DateTime createdAt,
  });

  $RestrictionTargetDtoCopyWith<$Res> get target;
}

class _$RestrictionDtoCopyWithImpl<$Res, $Val extends RestrictionDto>
    implements $RestrictionDtoCopyWith<$Res> {
  _$RestrictionDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? target = null,
    Object? targetName = null,
    Object? kind = null,
    Object? startsOn = null,
    Object? endsOn = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            target: null == target
                ? _value.target
                : target as RestrictionTargetDto,
            targetName: null == targetName
                ? _value.targetName
                : targetName as String,
            kind: null == kind ? _value.kind : kind as RestrictionKind,
            startsOn: null == startsOn ? _value.startsOn : startsOn as String,
            endsOn: freezed == endsOn ? _value.endsOn : endsOn as String?,
            isActive: null == isActive ? _value.isActive : isActive as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $RestrictionTargetDtoCopyWith<$Res> get target {
    return $RestrictionTargetDtoCopyWith<$Res>(_value.target, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }
}

abstract class _$$RestrictionDtoImplCopyWith<$Res>
    implements $RestrictionDtoCopyWith<$Res> {
  factory _$$RestrictionDtoImplCopyWith(
    _$RestrictionDtoImpl value,
    $Res Function(_$RestrictionDtoImpl) then,
  ) = __$$RestrictionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    RestrictionTargetDto target,
    String targetName,
    RestrictionKind kind,
    String startsOn,
    String? endsOn,
    bool isActive,
    DateTime createdAt,
  });

  @override
  $RestrictionTargetDtoCopyWith<$Res> get target;
}

class __$$RestrictionDtoImplCopyWithImpl<$Res>
    extends _$RestrictionDtoCopyWithImpl<$Res, _$RestrictionDtoImpl>
    implements _$$RestrictionDtoImplCopyWith<$Res> {
  __$$RestrictionDtoImplCopyWithImpl(
    _$RestrictionDtoImpl _value,
    $Res Function(_$RestrictionDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? target = null,
    Object? targetName = null,
    Object? kind = null,
    Object? startsOn = null,
    Object? endsOn = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RestrictionDtoImpl(
        id: null == id ? _value.id : id as String,
        target: null == target ? _value.target : target as RestrictionTargetDto,
        targetName: null == targetName
            ? _value.targetName
            : targetName as String,
        kind: null == kind ? _value.kind : kind as RestrictionKind,
        startsOn: null == startsOn ? _value.startsOn : startsOn as String,
        endsOn: freezed == endsOn ? _value.endsOn : endsOn as String?,
        isActive: null == isActive ? _value.isActive : isActive as bool,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RestrictionDtoImpl extends _RestrictionDto {
  const _$RestrictionDtoImpl({
    required this.id,
    required this.target,
    required this.targetName,
    required this.kind,
    required this.startsOn,
    required this.endsOn,
    required this.isActive,
    required this.createdAt,
  }) : super._();

  factory _$RestrictionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestrictionDtoImplFromJson(json);

  @override
  final String id;
  @override
  final RestrictionTargetDto target;
  @override
  final String targetName;
  @override
  final RestrictionKind kind;
  @override
  final String startsOn;
  @override
  final String? endsOn;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RestrictionDto(id: $id, target: $target, targetName: $targetName, kind: $kind, startsOn: $startsOn, endsOn: $endsOn, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestrictionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.targetName, targetName) ||
                other.targetName == targetName) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.startsOn, startsOn) ||
                other.startsOn == startsOn) &&
            (identical(other.endsOn, endsOn) || other.endsOn == endsOn) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    target,
    targetName,
    kind,
    startsOn,
    endsOn,
    isActive,
    createdAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestrictionDtoImplCopyWith<_$RestrictionDtoImpl> get copyWith =>
      __$$RestrictionDtoImplCopyWithImpl<_$RestrictionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RestrictionDtoImplToJson(this);
  }
}

abstract class _RestrictionDto extends RestrictionDto {
  const factory _RestrictionDto({
    required final String id,
    required final RestrictionTargetDto target,
    required final String targetName,
    required final RestrictionKind kind,
    required final String startsOn,
    required final String? endsOn,
    required final bool isActive,
    required final DateTime createdAt,
  }) = _$RestrictionDtoImpl;
  const _RestrictionDto._() : super._();

  factory _RestrictionDto.fromJson(Map<String, dynamic> json) =
      _$RestrictionDtoImpl.fromJson;

  @override
  String get id;
  @override
  RestrictionTargetDto get target;
  @override
  String get targetName;
  @override
  RestrictionKind get kind;
  @override
  String get startsOn;
  @override
  String? get endsOn;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestrictionDtoImplCopyWith<_$RestrictionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestrictionTargetDto _$RestrictionTargetDtoFromJson(Map<String, dynamic> json) {
  return _RestrictionTargetDto.fromJson(json);
}

mixin _$RestrictionTargetDto {
  RestrictionTargetType get type => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestrictionTargetDtoCopyWith<RestrictionTargetDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $RestrictionTargetDtoCopyWith<$Res> {
  factory $RestrictionTargetDtoCopyWith(
    RestrictionTargetDto value,
    $Res Function(RestrictionTargetDto) then,
  ) = _$RestrictionTargetDtoCopyWithImpl<$Res, RestrictionTargetDto>;
  @useResult
  $Res call({RestrictionTargetType type, String key});
}

class _$RestrictionTargetDtoCopyWithImpl<
  $Res,
  $Val extends RestrictionTargetDto
>
    implements $RestrictionTargetDtoCopyWith<$Res> {
  _$RestrictionTargetDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? key = null}) {
    return _then(
      _value.copyWith(
            type: null == type ? _value.type : type as RestrictionTargetType,
            key: null == key ? _value.key : key as String,
          )
          as $Val,
    );
  }
}

abstract class _$$RestrictionTargetDtoImplCopyWith<$Res>
    implements $RestrictionTargetDtoCopyWith<$Res> {
  factory _$$RestrictionTargetDtoImplCopyWith(
    _$RestrictionTargetDtoImpl value,
    $Res Function(_$RestrictionTargetDtoImpl) then,
  ) = __$$RestrictionTargetDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RestrictionTargetType type, String key});
}

class __$$RestrictionTargetDtoImplCopyWithImpl<$Res>
    extends _$RestrictionTargetDtoCopyWithImpl<$Res, _$RestrictionTargetDtoImpl>
    implements _$$RestrictionTargetDtoImplCopyWith<$Res> {
  __$$RestrictionTargetDtoImplCopyWithImpl(
    _$RestrictionTargetDtoImpl _value,
    $Res Function(_$RestrictionTargetDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? key = null}) {
    return _then(
      _$RestrictionTargetDtoImpl(
        type: null == type ? _value.type : type as RestrictionTargetType,
        key: null == key ? _value.key : key as String,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RestrictionTargetDtoImpl extends _RestrictionTargetDto {
  const _$RestrictionTargetDtoImpl({required this.type, required this.key})
    : super._();

  factory _$RestrictionTargetDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestrictionTargetDtoImplFromJson(json);

  @override
  final RestrictionTargetType type;
  @override
  final String key;

  @override
  String toString() {
    return 'RestrictionTargetDto(type: $type, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestrictionTargetDtoImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, key);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestrictionTargetDtoImplCopyWith<_$RestrictionTargetDtoImpl>
  get copyWith =>
      __$$RestrictionTargetDtoImplCopyWithImpl<_$RestrictionTargetDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RestrictionTargetDtoImplToJson(this);
  }
}

abstract class _RestrictionTargetDto extends RestrictionTargetDto {
  const factory _RestrictionTargetDto({
    required final RestrictionTargetType type,
    required final String key,
  }) = _$RestrictionTargetDtoImpl;
  const _RestrictionTargetDto._() : super._();

  factory _RestrictionTargetDto.fromJson(Map<String, dynamic> json) =
      _$RestrictionTargetDtoImpl.fromJson;

  @override
  RestrictionTargetType get type;
  @override
  String get key;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestrictionTargetDtoImplCopyWith<_$RestrictionTargetDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PreferencesDto _$PreferencesDtoFromJson(Map<String, dynamic> json) {
  return _PreferencesDto.fromJson(json);
}

mixin _$PreferencesDto {
  List<String> get preferredActivityKeys => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreferencesDtoCopyWith<PreferencesDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $PreferencesDtoCopyWith<$Res> {
  factory $PreferencesDtoCopyWith(
    PreferencesDto value,
    $Res Function(PreferencesDto) then,
  ) = _$PreferencesDtoCopyWithImpl<$Res, PreferencesDto>;
  @useResult
  $Res call({List<String> preferredActivityKeys});
}

class _$PreferencesDtoCopyWithImpl<$Res, $Val extends PreferencesDto>
    implements $PreferencesDtoCopyWith<$Res> {
  _$PreferencesDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? preferredActivityKeys = null}) {
    return _then(
      _value.copyWith(
            preferredActivityKeys: null == preferredActivityKeys
                ? _value.preferredActivityKeys
                : preferredActivityKeys as List<String>,
          )
          as $Val,
    );
  }
}

abstract class _$$PreferencesDtoImplCopyWith<$Res>
    implements $PreferencesDtoCopyWith<$Res> {
  factory _$$PreferencesDtoImplCopyWith(
    _$PreferencesDtoImpl value,
    $Res Function(_$PreferencesDtoImpl) then,
  ) = __$$PreferencesDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> preferredActivityKeys});
}

class __$$PreferencesDtoImplCopyWithImpl<$Res>
    extends _$PreferencesDtoCopyWithImpl<$Res, _$PreferencesDtoImpl>
    implements _$$PreferencesDtoImplCopyWith<$Res> {
  __$$PreferencesDtoImplCopyWithImpl(
    _$PreferencesDtoImpl _value,
    $Res Function(_$PreferencesDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? preferredActivityKeys = null}) {
    return _then(
      _$PreferencesDtoImpl(
        preferredActivityKeys: null == preferredActivityKeys
            ? _value._preferredActivityKeys
            : preferredActivityKeys as List<String>,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PreferencesDtoImpl extends _PreferencesDto {
  const _$PreferencesDtoImpl({
    required final List<String> preferredActivityKeys,
  }) : _preferredActivityKeys = preferredActivityKeys,
       super._();

  factory _$PreferencesDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesDtoImplFromJson(json);

  final List<String> _preferredActivityKeys;
  @override
  List<String> get preferredActivityKeys {
    if (_preferredActivityKeys is EqualUnmodifiableListView)
      return _preferredActivityKeys;
    return EqualUnmodifiableListView(_preferredActivityKeys);
  }

  @override
  String toString() {
    return 'PreferencesDto(preferredActivityKeys: $preferredActivityKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesDtoImpl &&
            const DeepCollectionEquality().equals(
              other._preferredActivityKeys,
              _preferredActivityKeys,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_preferredActivityKeys),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesDtoImplCopyWith<_$PreferencesDtoImpl> get copyWith =>
      __$$PreferencesDtoImplCopyWithImpl<_$PreferencesDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferencesDtoImplToJson(this);
  }
}

abstract class _PreferencesDto extends PreferencesDto {
  const factory _PreferencesDto({
    required final List<String> preferredActivityKeys,
  }) = _$PreferencesDtoImpl;
  const _PreferencesDto._() : super._();

  factory _PreferencesDto.fromJson(Map<String, dynamic> json) =
      _$PreferencesDtoImpl.fromJson;

  @override
  List<String> get preferredActivityKeys;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferencesDtoImplCopyWith<_$PreferencesDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
