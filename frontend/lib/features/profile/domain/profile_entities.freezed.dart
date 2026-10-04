part of 'profile_entities.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$MemberProfile {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;
  int? get proposedCapacityPercent => throw _privateConstructorUsedError;
  int? get approvedCapacityPercent => throw _privateConstructorUsedError;
  Availability get availability => throw _privateConstructorUsedError;
  List<Restriction> get restrictions => throw _privateConstructorUsedError;
  Preferences get preferences => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberProfileCopyWith<MemberProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $MemberProfileCopyWith<$Res> {
  factory $MemberProfileCopyWith(
    MemberProfile value,
    $Res Function(MemberProfile) then,
  ) = _$MemberProfileCopyWithImpl<$Res, MemberProfile>;
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
    Availability availability,
    List<Restriction> restrictions,
    Preferences preferences,
  });

  $AvailabilityCopyWith<$Res> get availability;
  $PreferencesCopyWith<$Res> get preferences;
}

class _$MemberProfileCopyWithImpl<$Res, $Val extends MemberProfile>
    implements $MemberProfileCopyWith<$Res> {
  _$MemberProfileCopyWithImpl(this._value, this._then);

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
                : availability as Availability,
            restrictions: null == restrictions
                ? _value.restrictions
                : restrictions as List<Restriction>,
            preferences: null == preferences
                ? _value.preferences
                : preferences as Preferences,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $AvailabilityCopyWith<$Res> get availability {
    return $AvailabilityCopyWith<$Res>(_value.availability, (value) {
      return _then(_value.copyWith(availability: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesCopyWith<$Res> get preferences {
    return $PreferencesCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

abstract class _$$MemberProfileImplCopyWith<$Res>
    implements $MemberProfileCopyWith<$Res> {
  factory _$$MemberProfileImplCopyWith(
    _$MemberProfileImpl value,
    $Res Function(_$MemberProfileImpl) then,
  ) = __$$MemberProfileImplCopyWithImpl<$Res>;
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
    Availability availability,
    List<Restriction> restrictions,
    Preferences preferences,
  });

  @override
  $AvailabilityCopyWith<$Res> get availability;
  @override
  $PreferencesCopyWith<$Res> get preferences;
}

class __$$MemberProfileImplCopyWithImpl<$Res>
    extends _$MemberProfileCopyWithImpl<$Res, _$MemberProfileImpl>
    implements _$$MemberProfileImplCopyWith<$Res> {
  __$$MemberProfileImplCopyWithImpl(
    _$MemberProfileImpl _value,
    $Res Function(_$MemberProfileImpl) _then,
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
      _$MemberProfileImpl(
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
            : availability as Availability,
        restrictions: null == restrictions
            ? _value._restrictions
            : restrictions as List<Restriction>,
        preferences: null == preferences
            ? _value.preferences
            : preferences as Preferences,
      ),
    );
  }
}

class _$MemberProfileImpl extends _MemberProfile {
  const _$MemberProfileImpl({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.role,
    required this.isMe,
    required this.proposedCapacityPercent,
    required this.approvedCapacityPercent,
    required this.availability,
    required final List<Restriction> restrictions,
    required this.preferences,
  }) : _restrictions = restrictions,
       super._();

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
  final Availability availability;
  final List<Restriction> _restrictions;
  @override
  List<Restriction> get restrictions {
    if (_restrictions is EqualUnmodifiableListView) return _restrictions;
    return EqualUnmodifiableListView(_restrictions);
  }

  @override
  final Preferences preferences;

  @override
  String toString() {
    return 'MemberProfile(userId: $userId, name: $name, nickname: $nickname, avatar: $avatar, role: $role, isMe: $isMe, proposedCapacityPercent: $proposedCapacityPercent, approvedCapacityPercent: $approvedCapacityPercent, availability: $availability, restrictions: $restrictions, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberProfileImpl &&
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
  _$$MemberProfileImplCopyWith<_$MemberProfileImpl> get copyWith =>
      __$$MemberProfileImplCopyWithImpl<_$MemberProfileImpl>(this, _$identity);
}

abstract class _MemberProfile extends MemberProfile {
  const factory _MemberProfile({
    required final String userId,
    required final String name,
    required final String? nickname,
    required final AvatarChoice? avatar,
    required final MemberRole role,
    required final bool isMe,
    required final int? proposedCapacityPercent,
    required final int? approvedCapacityPercent,
    required final Availability availability,
    required final List<Restriction> restrictions,
    required final Preferences preferences,
  }) = _$MemberProfileImpl;
  const _MemberProfile._() : super._();

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
  Availability get availability;
  @override
  List<Restriction> get restrictions;
  @override
  Preferences get preferences;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberProfileImplCopyWith<_$MemberProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$Availability {
  List<AvailabilitySlot> get slots => throw _privateConstructorUsedError;
  List<AvailabilityException> get exceptions =>
      throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilityCopyWith<Availability> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilityCopyWith<$Res> {
  factory $AvailabilityCopyWith(
    Availability value,
    $Res Function(Availability) then,
  ) = _$AvailabilityCopyWithImpl<$Res, Availability>;
  @useResult
  $Res call({
    List<AvailabilitySlot> slots,
    List<AvailabilityException> exceptions,
  });
}

class _$AvailabilityCopyWithImpl<$Res, $Val extends Availability>
    implements $AvailabilityCopyWith<$Res> {
  _$AvailabilityCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null, Object? exceptions = null}) {
    return _then(
      _value.copyWith(
            slots: null == slots
                ? _value.slots
                : slots as List<AvailabilitySlot>,
            exceptions: null == exceptions
                ? _value.exceptions
                : exceptions as List<AvailabilityException>,
          )
          as $Val,
    );
  }
}

abstract class _$$AvailabilityImplCopyWith<$Res>
    implements $AvailabilityCopyWith<$Res> {
  factory _$$AvailabilityImplCopyWith(
    _$AvailabilityImpl value,
    $Res Function(_$AvailabilityImpl) then,
  ) = __$$AvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AvailabilitySlot> slots,
    List<AvailabilityException> exceptions,
  });
}

class __$$AvailabilityImplCopyWithImpl<$Res>
    extends _$AvailabilityCopyWithImpl<$Res, _$AvailabilityImpl>
    implements _$$AvailabilityImplCopyWith<$Res> {
  __$$AvailabilityImplCopyWithImpl(
    _$AvailabilityImpl _value,
    $Res Function(_$AvailabilityImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null, Object? exceptions = null}) {
    return _then(
      _$AvailabilityImpl(
        slots: null == slots ? _value._slots : slots as List<AvailabilitySlot>,
        exceptions: null == exceptions
            ? _value._exceptions
            : exceptions as List<AvailabilityException>,
      ),
    );
  }
}

class _$AvailabilityImpl implements _Availability {
  const _$AvailabilityImpl({
    required final List<AvailabilitySlot> slots,
    required final List<AvailabilityException> exceptions,
  }) : _slots = slots,
       _exceptions = exceptions;

  final List<AvailabilitySlot> _slots;
  @override
  List<AvailabilitySlot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    return EqualUnmodifiableListView(_slots);
  }

  final List<AvailabilityException> _exceptions;
  @override
  List<AvailabilityException> get exceptions {
    if (_exceptions is EqualUnmodifiableListView) return _exceptions;
    return EqualUnmodifiableListView(_exceptions);
  }

  @override
  String toString() {
    return 'Availability(slots: $slots, exceptions: $exceptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilityImpl &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            const DeepCollectionEquality().equals(
              other._exceptions,
              _exceptions,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_slots),
    const DeepCollectionEquality().hash(_exceptions),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilityImplCopyWith<_$AvailabilityImpl> get copyWith =>
      __$$AvailabilityImplCopyWithImpl<_$AvailabilityImpl>(this, _$identity);
}

abstract class _Availability implements Availability {
  const factory _Availability({
    required final List<AvailabilitySlot> slots,
    required final List<AvailabilityException> exceptions,
  }) = _$AvailabilityImpl;

  @override
  List<AvailabilitySlot> get slots;
  @override
  List<AvailabilityException> get exceptions;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilityImplCopyWith<_$AvailabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$AvailabilitySlot {
  int get weekday => throw _privateConstructorUsedError;
  DayPeriod get period => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilitySlotCopyWith<AvailabilitySlot> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilitySlotCopyWith<$Res> {
  factory $AvailabilitySlotCopyWith(
    AvailabilitySlot value,
    $Res Function(AvailabilitySlot) then,
  ) = _$AvailabilitySlotCopyWithImpl<$Res, AvailabilitySlot>;
  @useResult
  $Res call({int weekday, DayPeriod period});
}

class _$AvailabilitySlotCopyWithImpl<$Res, $Val extends AvailabilitySlot>
    implements $AvailabilitySlotCopyWith<$Res> {
  _$AvailabilitySlotCopyWithImpl(this._value, this._then);

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

abstract class _$$AvailabilitySlotImplCopyWith<$Res>
    implements $AvailabilitySlotCopyWith<$Res> {
  factory _$$AvailabilitySlotImplCopyWith(
    _$AvailabilitySlotImpl value,
    $Res Function(_$AvailabilitySlotImpl) then,
  ) = __$$AvailabilitySlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int weekday, DayPeriod period});
}

class __$$AvailabilitySlotImplCopyWithImpl<$Res>
    extends _$AvailabilitySlotCopyWithImpl<$Res, _$AvailabilitySlotImpl>
    implements _$$AvailabilitySlotImplCopyWith<$Res> {
  __$$AvailabilitySlotImplCopyWithImpl(
    _$AvailabilitySlotImpl _value,
    $Res Function(_$AvailabilitySlotImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? weekday = null, Object? period = null}) {
    return _then(
      _$AvailabilitySlotImpl(
        weekday: null == weekday ? _value.weekday : weekday as int,
        period: null == period ? _value.period : period as DayPeriod,
      ),
    );
  }
}

class _$AvailabilitySlotImpl extends _AvailabilitySlot {
  const _$AvailabilitySlotImpl({required this.weekday, required this.period})
    : super._();

  @override
  final int weekday;
  @override
  final DayPeriod period;

  @override
  String toString() {
    return 'AvailabilitySlot(weekday: $weekday, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilitySlotImpl &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.period, period) || other.period == period));
  }

  @override
  int get hashCode => Object.hash(runtimeType, weekday, period);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilitySlotImplCopyWith<_$AvailabilitySlotImpl> get copyWith =>
      __$$AvailabilitySlotImplCopyWithImpl<_$AvailabilitySlotImpl>(
        this,
        _$identity,
      );
}

abstract class _AvailabilitySlot extends AvailabilitySlot {
  const factory _AvailabilitySlot({
    required final int weekday,
    required final DayPeriod period,
  }) = _$AvailabilitySlotImpl;
  const _AvailabilitySlot._() : super._();

  @override
  int get weekday;
  @override
  DayPeriod get period;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilitySlotImplCopyWith<_$AvailabilitySlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$AvailabilityException {
  String get date => throw _privateConstructorUsedError;
  DayPeriod? get period => throw _privateConstructorUsedError;
  bool get available => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilityExceptionCopyWith<AvailabilityException> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $AvailabilityExceptionCopyWith<$Res> {
  factory $AvailabilityExceptionCopyWith(
    AvailabilityException value,
    $Res Function(AvailabilityException) then,
  ) = _$AvailabilityExceptionCopyWithImpl<$Res, AvailabilityException>;
  @useResult
  $Res call({String date, DayPeriod? period, bool available});
}

class _$AvailabilityExceptionCopyWithImpl<
  $Res,
  $Val extends AvailabilityException
>
    implements $AvailabilityExceptionCopyWith<$Res> {
  _$AvailabilityExceptionCopyWithImpl(this._value, this._then);

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

abstract class _$$AvailabilityExceptionImplCopyWith<$Res>
    implements $AvailabilityExceptionCopyWith<$Res> {
  factory _$$AvailabilityExceptionImplCopyWith(
    _$AvailabilityExceptionImpl value,
    $Res Function(_$AvailabilityExceptionImpl) then,
  ) = __$$AvailabilityExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, DayPeriod? period, bool available});
}

class __$$AvailabilityExceptionImplCopyWithImpl<$Res>
    extends
        _$AvailabilityExceptionCopyWithImpl<$Res, _$AvailabilityExceptionImpl>
    implements _$$AvailabilityExceptionImplCopyWith<$Res> {
  __$$AvailabilityExceptionImplCopyWithImpl(
    _$AvailabilityExceptionImpl _value,
    $Res Function(_$AvailabilityExceptionImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? period = freezed,
    Object? available = null,
  }) {
    return _then(
      _$AvailabilityExceptionImpl(
        date: null == date ? _value.date : date as String,
        period: freezed == period ? _value.period : period as DayPeriod?,
        available: null == available ? _value.available : available as bool,
      ),
    );
  }
}

class _$AvailabilityExceptionImpl implements _AvailabilityException {
  const _$AvailabilityExceptionImpl({
    required this.date,
    required this.period,
    required this.available,
  });

  @override
  final String date;
  @override
  final DayPeriod? period;
  @override
  final bool available;

  @override
  String toString() {
    return 'AvailabilityException(date: $date, period: $period, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilityExceptionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, period, available);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilityExceptionImplCopyWith<_$AvailabilityExceptionImpl>
  get copyWith =>
      __$$AvailabilityExceptionImplCopyWithImpl<_$AvailabilityExceptionImpl>(
        this,
        _$identity,
      );
}

abstract class _AvailabilityException implements AvailabilityException {
  const factory _AvailabilityException({
    required final String date,
    required final DayPeriod? period,
    required final bool available,
  }) = _$AvailabilityExceptionImpl;

  @override
  String get date;
  @override
  DayPeriod? get period;
  @override
  bool get available;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilityExceptionImplCopyWith<_$AvailabilityExceptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

mixin _$Restriction {
  String get id => throw _privateConstructorUsedError;
  RestrictionTarget get target => throw _privateConstructorUsedError;
  String get targetName => throw _privateConstructorUsedError;
  RestrictionKind get kind => throw _privateConstructorUsedError;
  String get startsOn => throw _privateConstructorUsedError;
  String? get endsOn => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestrictionCopyWith<Restriction> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $RestrictionCopyWith<$Res> {
  factory $RestrictionCopyWith(
    Restriction value,
    $Res Function(Restriction) then,
  ) = _$RestrictionCopyWithImpl<$Res, Restriction>;
  @useResult
  $Res call({
    String id,
    RestrictionTarget target,
    String targetName,
    RestrictionKind kind,
    String startsOn,
    String? endsOn,
    bool isActive,
    DateTime createdAt,
  });

  $RestrictionTargetCopyWith<$Res> get target;
}

class _$RestrictionCopyWithImpl<$Res, $Val extends Restriction>
    implements $RestrictionCopyWith<$Res> {
  _$RestrictionCopyWithImpl(this._value, this._then);

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
                : target as RestrictionTarget,
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
  $RestrictionTargetCopyWith<$Res> get target {
    return $RestrictionTargetCopyWith<$Res>(_value.target, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }
}

abstract class _$$RestrictionImplCopyWith<$Res>
    implements $RestrictionCopyWith<$Res> {
  factory _$$RestrictionImplCopyWith(
    _$RestrictionImpl value,
    $Res Function(_$RestrictionImpl) then,
  ) = __$$RestrictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    RestrictionTarget target,
    String targetName,
    RestrictionKind kind,
    String startsOn,
    String? endsOn,
    bool isActive,
    DateTime createdAt,
  });

  @override
  $RestrictionTargetCopyWith<$Res> get target;
}

class __$$RestrictionImplCopyWithImpl<$Res>
    extends _$RestrictionCopyWithImpl<$Res, _$RestrictionImpl>
    implements _$$RestrictionImplCopyWith<$Res> {
  __$$RestrictionImplCopyWithImpl(
    _$RestrictionImpl _value,
    $Res Function(_$RestrictionImpl) _then,
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
      _$RestrictionImpl(
        id: null == id ? _value.id : id as String,
        target: null == target ? _value.target : target as RestrictionTarget,
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

class _$RestrictionImpl implements _Restriction {
  const _$RestrictionImpl({
    required this.id,
    required this.target,
    required this.targetName,
    required this.kind,
    required this.startsOn,
    required this.endsOn,
    required this.isActive,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final RestrictionTarget target;
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
    return 'Restriction(id: $id, target: $target, targetName: $targetName, kind: $kind, startsOn: $startsOn, endsOn: $endsOn, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestrictionImpl &&
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
  _$$RestrictionImplCopyWith<_$RestrictionImpl> get copyWith =>
      __$$RestrictionImplCopyWithImpl<_$RestrictionImpl>(this, _$identity);
}

abstract class _Restriction implements Restriction {
  const factory _Restriction({
    required final String id,
    required final RestrictionTarget target,
    required final String targetName,
    required final RestrictionKind kind,
    required final String startsOn,
    required final String? endsOn,
    required final bool isActive,
    required final DateTime createdAt,
  }) = _$RestrictionImpl;

  @override
  String get id;
  @override
  RestrictionTarget get target;
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
  _$$RestrictionImplCopyWith<_$RestrictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$RestrictionTarget {
  RestrictionTargetType get type => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestrictionTargetCopyWith<RestrictionTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $RestrictionTargetCopyWith<$Res> {
  factory $RestrictionTargetCopyWith(
    RestrictionTarget value,
    $Res Function(RestrictionTarget) then,
  ) = _$RestrictionTargetCopyWithImpl<$Res, RestrictionTarget>;
  @useResult
  $Res call({RestrictionTargetType type, String key});
}

class _$RestrictionTargetCopyWithImpl<$Res, $Val extends RestrictionTarget>
    implements $RestrictionTargetCopyWith<$Res> {
  _$RestrictionTargetCopyWithImpl(this._value, this._then);

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

abstract class _$$RestrictionTargetImplCopyWith<$Res>
    implements $RestrictionTargetCopyWith<$Res> {
  factory _$$RestrictionTargetImplCopyWith(
    _$RestrictionTargetImpl value,
    $Res Function(_$RestrictionTargetImpl) then,
  ) = __$$RestrictionTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RestrictionTargetType type, String key});
}

class __$$RestrictionTargetImplCopyWithImpl<$Res>
    extends _$RestrictionTargetCopyWithImpl<$Res, _$RestrictionTargetImpl>
    implements _$$RestrictionTargetImplCopyWith<$Res> {
  __$$RestrictionTargetImplCopyWithImpl(
    _$RestrictionTargetImpl _value,
    $Res Function(_$RestrictionTargetImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? key = null}) {
    return _then(
      _$RestrictionTargetImpl(
        type: null == type ? _value.type : type as RestrictionTargetType,
        key: null == key ? _value.key : key as String,
      ),
    );
  }
}

class _$RestrictionTargetImpl extends _RestrictionTarget {
  const _$RestrictionTargetImpl({required this.type, required this.key})
    : super._();

  @override
  final RestrictionTargetType type;
  @override
  final String key;

  @override
  String toString() {
    return 'RestrictionTarget(type: $type, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestrictionTargetImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, key);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestrictionTargetImplCopyWith<_$RestrictionTargetImpl> get copyWith =>
      __$$RestrictionTargetImplCopyWithImpl<_$RestrictionTargetImpl>(
        this,
        _$identity,
      );
}

abstract class _RestrictionTarget extends RestrictionTarget {
  const factory _RestrictionTarget({
    required final RestrictionTargetType type,
    required final String key,
  }) = _$RestrictionTargetImpl;
  const _RestrictionTarget._() : super._();

  @override
  RestrictionTargetType get type;
  @override
  String get key;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestrictionTargetImplCopyWith<_$RestrictionTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$Preferences {
  List<String> get preferredActivityKeys => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreferencesCopyWith<Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $PreferencesCopyWith<$Res> {
  factory $PreferencesCopyWith(
    Preferences value,
    $Res Function(Preferences) then,
  ) = _$PreferencesCopyWithImpl<$Res, Preferences>;
  @useResult
  $Res call({List<String> preferredActivityKeys});
}

class _$PreferencesCopyWithImpl<$Res, $Val extends Preferences>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._value, this._then);

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

abstract class _$$PreferencesImplCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$PreferencesImplCopyWith(
    _$PreferencesImpl value,
    $Res Function(_$PreferencesImpl) then,
  ) = __$$PreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> preferredActivityKeys});
}

class __$$PreferencesImplCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$PreferencesImpl>
    implements _$$PreferencesImplCopyWith<$Res> {
  __$$PreferencesImplCopyWithImpl(
    _$PreferencesImpl _value,
    $Res Function(_$PreferencesImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? preferredActivityKeys = null}) {
    return _then(
      _$PreferencesImpl(
        preferredActivityKeys: null == preferredActivityKeys
            ? _value._preferredActivityKeys
            : preferredActivityKeys as List<String>,
      ),
    );
  }
}

class _$PreferencesImpl implements _Preferences {
  const _$PreferencesImpl({required final List<String> preferredActivityKeys})
    : _preferredActivityKeys = preferredActivityKeys;

  final List<String> _preferredActivityKeys;
  @override
  List<String> get preferredActivityKeys {
    if (_preferredActivityKeys is EqualUnmodifiableListView)
      return _preferredActivityKeys;
    return EqualUnmodifiableListView(_preferredActivityKeys);
  }

  @override
  String toString() {
    return 'Preferences(preferredActivityKeys: $preferredActivityKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesImpl &&
            const DeepCollectionEquality().equals(
              other._preferredActivityKeys,
              _preferredActivityKeys,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_preferredActivityKeys),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      __$$PreferencesImplCopyWithImpl<_$PreferencesImpl>(this, _$identity);
}

abstract class _Preferences implements Preferences {
  const factory _Preferences({
    required final List<String> preferredActivityKeys,
  }) = _$PreferencesImpl;

  @override
  List<String> get preferredActivityKeys;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
