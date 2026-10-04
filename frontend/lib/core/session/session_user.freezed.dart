part of 'session_user.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SessionUser _$SessionUserFromJson(Map<String, dynamic> json) {
  return _SessionUser.fromJson(json);
}

mixin _$SessionUser {
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  String? get activeHouseholdId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionUserCopyWith<SessionUser> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $SessionUserCopyWith<$Res> {
  factory $SessionUserCopyWith(
    SessionUser value,
    $Res Function(SessionUser) then,
  ) = _$SessionUserCopyWithImpl<$Res, SessionUser>;
  @useResult
  $Res call({
    String id,
    String phone,
    String name,
    AvatarChoice? avatar,
    String? activeHouseholdId,
    DateTime createdAt,
  });
}

class _$SessionUserCopyWithImpl<$Res, $Val extends SessionUser>
    implements $SessionUserCopyWith<$Res> {
  _$SessionUserCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? activeHouseholdId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            phone: null == phone ? _value.phone : phone as String,
            name: null == name ? _value.name : name as String,
            avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
            activeHouseholdId: freezed == activeHouseholdId
                ? _value.activeHouseholdId
                : activeHouseholdId as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$SessionUserImplCopyWith<$Res>
    implements $SessionUserCopyWith<$Res> {
  factory _$$SessionUserImplCopyWith(
    _$SessionUserImpl value,
    $Res Function(_$SessionUserImpl) then,
  ) = __$$SessionUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String phone,
    String name,
    AvatarChoice? avatar,
    String? activeHouseholdId,
    DateTime createdAt,
  });
}

class __$$SessionUserImplCopyWithImpl<$Res>
    extends _$SessionUserCopyWithImpl<$Res, _$SessionUserImpl>
    implements _$$SessionUserImplCopyWith<$Res> {
  __$$SessionUserImplCopyWithImpl(
    _$SessionUserImpl _value,
    $Res Function(_$SessionUserImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? avatar = freezed,
    Object? activeHouseholdId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$SessionUserImpl(
        id: null == id ? _value.id : id as String,
        phone: null == phone ? _value.phone : phone as String,
        name: null == name ? _value.name : name as String,
        avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
        activeHouseholdId: freezed == activeHouseholdId
            ? _value.activeHouseholdId
            : activeHouseholdId as String?,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SessionUserImpl implements _SessionUser {
  const _$SessionUserImpl({
    required this.id,
    required this.phone,
    required this.name,
    this.avatar,
    this.activeHouseholdId,
    required this.createdAt,
  });

  factory _$SessionUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionUserImplFromJson(json);

  @override
  final String id;
  @override
  final String phone;
  @override
  final String name;
  @override
  final AvatarChoice? avatar;
  @override
  final String? activeHouseholdId;
  @override
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.activeHouseholdId, activeHouseholdId) ||
                other.activeHouseholdId == activeHouseholdId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    phone,
    name,
    avatar,
    activeHouseholdId,
    createdAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionUserImplCopyWith<_$SessionUserImpl> get copyWith =>
      __$$SessionUserImplCopyWithImpl<_$SessionUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionUserImplToJson(this);
  }
}

abstract class _SessionUser implements SessionUser {
  const factory _SessionUser({
    required final String id,
    required final String phone,
    required final String name,
    final AvatarChoice? avatar,
    final String? activeHouseholdId,
    required final DateTime createdAt,
  }) = _$SessionUserImpl;

  factory _SessionUser.fromJson(Map<String, dynamic> json) =
      _$SessionUserImpl.fromJson;

  @override
  String get id;
  @override
  String get phone;
  @override
  String get name;
  @override
  AvatarChoice? get avatar;
  @override
  String? get activeHouseholdId;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionUserImplCopyWith<_$SessionUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
