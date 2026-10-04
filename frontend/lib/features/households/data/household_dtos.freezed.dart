part of 'household_dtos.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HouseholdSummaryDto _$HouseholdSummaryDtoFromJson(Map<String, dynamic> json) {
  return _HouseholdSummaryDto.fromJson(json);
}

mixin _$HouseholdSummaryDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MemberRole get myRole => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdSummaryDtoCopyWith<HouseholdSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $HouseholdSummaryDtoCopyWith<$Res> {
  factory $HouseholdSummaryDtoCopyWith(
    HouseholdSummaryDto value,
    $Res Function(HouseholdSummaryDto) then,
  ) = _$HouseholdSummaryDtoCopyWithImpl<$Res, HouseholdSummaryDto>;
  @useResult
  $Res call({
    String id,
    String name,
    MemberRole myRole,
    int memberCount,
    DateTime createdAt,
  });
}

class _$HouseholdSummaryDtoCopyWithImpl<$Res, $Val extends HouseholdSummaryDto>
    implements $HouseholdSummaryDtoCopyWith<$Res> {
  _$HouseholdSummaryDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? myRole = null,
    Object? memberCount = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            name: null == name ? _value.name : name as String,
            myRole: null == myRole ? _value.myRole : myRole as MemberRole,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$HouseholdSummaryDtoImplCopyWith<$Res>
    implements $HouseholdSummaryDtoCopyWith<$Res> {
  factory _$$HouseholdSummaryDtoImplCopyWith(
    _$HouseholdSummaryDtoImpl value,
    $Res Function(_$HouseholdSummaryDtoImpl) then,
  ) = __$$HouseholdSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    MemberRole myRole,
    int memberCount,
    DateTime createdAt,
  });
}

class __$$HouseholdSummaryDtoImplCopyWithImpl<$Res>
    extends _$HouseholdSummaryDtoCopyWithImpl<$Res, _$HouseholdSummaryDtoImpl>
    implements _$$HouseholdSummaryDtoImplCopyWith<$Res> {
  __$$HouseholdSummaryDtoImplCopyWithImpl(
    _$HouseholdSummaryDtoImpl _value,
    $Res Function(_$HouseholdSummaryDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? myRole = null,
    Object? memberCount = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$HouseholdSummaryDtoImpl(
        id: null == id ? _value.id : id as String,
        name: null == name ? _value.name : name as String,
        myRole: null == myRole ? _value.myRole : myRole as MemberRole,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount as int,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HouseholdSummaryDtoImpl extends _HouseholdSummaryDto {
  const _$HouseholdSummaryDtoImpl({
    required this.id,
    required this.name,
    required this.myRole,
    required this.memberCount,
    required this.createdAt,
  }) : super._();

  factory _$HouseholdSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseholdSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final MemberRole myRole;
  @override
  final int memberCount;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'HouseholdSummaryDto(id: $id, name: $name, myRole: $myRole, memberCount: $memberCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.myRole, myRole) || other.myRole == myRole) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, myRole, memberCount, createdAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdSummaryDtoImplCopyWith<_$HouseholdSummaryDtoImpl> get copyWith =>
      __$$HouseholdSummaryDtoImplCopyWithImpl<_$HouseholdSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseholdSummaryDtoImplToJson(this);
  }
}

abstract class _HouseholdSummaryDto extends HouseholdSummaryDto {
  const factory _HouseholdSummaryDto({
    required final String id,
    required final String name,
    required final MemberRole myRole,
    required final int memberCount,
    required final DateTime createdAt,
  }) = _$HouseholdSummaryDtoImpl;
  const _HouseholdSummaryDto._() : super._();

  factory _HouseholdSummaryDto.fromJson(Map<String, dynamic> json) =
      _$HouseholdSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  MemberRole get myRole;
  @override
  int get memberCount;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdSummaryDtoImplCopyWith<_$HouseholdSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HouseholdDetailDto _$HouseholdDetailDtoFromJson(Map<String, dynamic> json) {
  return _HouseholdDetailDto.fromJson(json);
}

mixin _$HouseholdDetailDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  int? get imbalanceThresholdPercent => throw _privateConstructorUsedError;
  MemberRole get myRole => throw _privateConstructorUsedError;
  List<MemberDto> get members => throw _privateConstructorUsedError;
  bool get templatesApplied => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdDetailDtoCopyWith<HouseholdDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $HouseholdDetailDtoCopyWith<$Res> {
  factory $HouseholdDetailDtoCopyWith(
    HouseholdDetailDto value,
    $Res Function(HouseholdDetailDto) then,
  ) = _$HouseholdDetailDtoCopyWithImpl<$Res, HouseholdDetailDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String timezone,
    int? imbalanceThresholdPercent,
    MemberRole myRole,
    List<MemberDto> members,
    bool templatesApplied,
    int version,
    DateTime createdAt,
  });
}

class _$HouseholdDetailDtoCopyWithImpl<$Res, $Val extends HouseholdDetailDto>
    implements $HouseholdDetailDtoCopyWith<$Res> {
  _$HouseholdDetailDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? timezone = null,
    Object? imbalanceThresholdPercent = freezed,
    Object? myRole = null,
    Object? members = null,
    Object? templatesApplied = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            name: null == name ? _value.name : name as String,
            timezone: null == timezone ? _value.timezone : timezone as String,
            imbalanceThresholdPercent: freezed == imbalanceThresholdPercent
                ? _value.imbalanceThresholdPercent
                : imbalanceThresholdPercent as int?,
            myRole: null == myRole ? _value.myRole : myRole as MemberRole,
            members: null == members
                ? _value.members
                : members as List<MemberDto>,
            templatesApplied: null == templatesApplied
                ? _value.templatesApplied
                : templatesApplied as bool,
            version: null == version ? _value.version : version as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$HouseholdDetailDtoImplCopyWith<$Res>
    implements $HouseholdDetailDtoCopyWith<$Res> {
  factory _$$HouseholdDetailDtoImplCopyWith(
    _$HouseholdDetailDtoImpl value,
    $Res Function(_$HouseholdDetailDtoImpl) then,
  ) = __$$HouseholdDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String timezone,
    int? imbalanceThresholdPercent,
    MemberRole myRole,
    List<MemberDto> members,
    bool templatesApplied,
    int version,
    DateTime createdAt,
  });
}

class __$$HouseholdDetailDtoImplCopyWithImpl<$Res>
    extends _$HouseholdDetailDtoCopyWithImpl<$Res, _$HouseholdDetailDtoImpl>
    implements _$$HouseholdDetailDtoImplCopyWith<$Res> {
  __$$HouseholdDetailDtoImplCopyWithImpl(
    _$HouseholdDetailDtoImpl _value,
    $Res Function(_$HouseholdDetailDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? timezone = null,
    Object? imbalanceThresholdPercent = freezed,
    Object? myRole = null,
    Object? members = null,
    Object? templatesApplied = null,
    Object? version = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$HouseholdDetailDtoImpl(
        id: null == id ? _value.id : id as String,
        name: null == name ? _value.name : name as String,
        timezone: null == timezone ? _value.timezone : timezone as String,
        imbalanceThresholdPercent: freezed == imbalanceThresholdPercent
            ? _value.imbalanceThresholdPercent
            : imbalanceThresholdPercent as int?,
        myRole: null == myRole ? _value.myRole : myRole as MemberRole,
        members: null == members ? _value._members : members as List<MemberDto>,
        templatesApplied: null == templatesApplied
            ? _value.templatesApplied
            : templatesApplied as bool,
        version: null == version ? _value.version : version as int,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HouseholdDetailDtoImpl extends _HouseholdDetailDto {
  const _$HouseholdDetailDtoImpl({
    required this.id,
    required this.name,
    required this.timezone,
    required this.imbalanceThresholdPercent,
    required this.myRole,
    required final List<MemberDto> members,
    required this.templatesApplied,
    required this.version,
    required this.createdAt,
  }) : _members = members,
       super._();

  factory _$HouseholdDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseholdDetailDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String timezone;
  @override
  final int? imbalanceThresholdPercent;
  @override
  final MemberRole myRole;
  final List<MemberDto> _members;
  @override
  List<MemberDto> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    return EqualUnmodifiableListView(_members);
  }

  @override
  final bool templatesApplied;
  @override
  final int version;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'HouseholdDetailDto(id: $id, name: $name, timezone: $timezone, imbalanceThresholdPercent: $imbalanceThresholdPercent, myRole: $myRole, members: $members, templatesApplied: $templatesApplied, version: $version, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(
                  other.imbalanceThresholdPercent,
                  imbalanceThresholdPercent,
                ) ||
                other.imbalanceThresholdPercent == imbalanceThresholdPercent) &&
            (identical(other.myRole, myRole) || other.myRole == myRole) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.templatesApplied, templatesApplied) ||
                other.templatesApplied == templatesApplied) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    timezone,
    imbalanceThresholdPercent,
    myRole,
    const DeepCollectionEquality().hash(_members),
    templatesApplied,
    version,
    createdAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdDetailDtoImplCopyWith<_$HouseholdDetailDtoImpl> get copyWith =>
      __$$HouseholdDetailDtoImplCopyWithImpl<_$HouseholdDetailDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseholdDetailDtoImplToJson(this);
  }
}

abstract class _HouseholdDetailDto extends HouseholdDetailDto {
  const factory _HouseholdDetailDto({
    required final String id,
    required final String name,
    required final String timezone,
    required final int? imbalanceThresholdPercent,
    required final MemberRole myRole,
    required final List<MemberDto> members,
    required final bool templatesApplied,
    required final int version,
    required final DateTime createdAt,
  }) = _$HouseholdDetailDtoImpl;
  const _HouseholdDetailDto._() : super._();

  factory _HouseholdDetailDto.fromJson(Map<String, dynamic> json) =
      _$HouseholdDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get timezone;
  @override
  int? get imbalanceThresholdPercent;
  @override
  MemberRole get myRole;
  @override
  List<MemberDto> get members;
  @override
  bool get templatesApplied;
  @override
  int get version;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdDetailDtoImplCopyWith<_$HouseholdDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberDto _$MemberDtoFromJson(Map<String, dynamic> json) {
  return _MemberDto.fromJson(json);
}

mixin _$MemberDto {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberDtoCopyWith<MemberDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $MemberDtoCopyWith<$Res> {
  factory $MemberDtoCopyWith(MemberDto value, $Res Function(MemberDto) then) =
      _$MemberDtoCopyWithImpl<$Res, MemberDto>;
  @useResult
  $Res call({
    String userId,
    String name,
    String? nickname,
    AvatarChoice? avatar,
    MemberRole role,
    DateTime joinedAt,
    bool isMe,
  });
}

class _$MemberDtoCopyWithImpl<$Res, $Val extends MemberDto>
    implements $MemberDtoCopyWith<$Res> {
  _$MemberDtoCopyWithImpl(this._value, this._then);

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
    Object? joinedAt = null,
    Object? isMe = null,
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
            joinedAt: null == joinedAt ? _value.joinedAt : joinedAt as DateTime,
            isMe: null == isMe ? _value.isMe : isMe as bool,
          )
          as $Val,
    );
  }
}

abstract class _$$MemberDtoImplCopyWith<$Res>
    implements $MemberDtoCopyWith<$Res> {
  factory _$$MemberDtoImplCopyWith(
    _$MemberDtoImpl value,
    $Res Function(_$MemberDtoImpl) then,
  ) = __$$MemberDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String name,
    String? nickname,
    AvatarChoice? avatar,
    MemberRole role,
    DateTime joinedAt,
    bool isMe,
  });
}

class __$$MemberDtoImplCopyWithImpl<$Res>
    extends _$MemberDtoCopyWithImpl<$Res, _$MemberDtoImpl>
    implements _$$MemberDtoImplCopyWith<$Res> {
  __$$MemberDtoImplCopyWithImpl(
    _$MemberDtoImpl _value,
    $Res Function(_$MemberDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? nickname = freezed,
    Object? avatar = freezed,
    Object? role = null,
    Object? joinedAt = null,
    Object? isMe = null,
  }) {
    return _then(
      _$MemberDtoImpl(
        userId: null == userId ? _value.userId : userId as String,
        name: null == name ? _value.name : name as String,
        nickname: freezed == nickname ? _value.nickname : nickname as String?,
        avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
        role: null == role ? _value.role : role as MemberRole,
        joinedAt: null == joinedAt ? _value.joinedAt : joinedAt as DateTime,
        isMe: null == isMe ? _value.isMe : isMe as bool,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$MemberDtoImpl extends _MemberDto {
  const _$MemberDtoImpl({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.role,
    required this.joinedAt,
    required this.isMe,
  }) : super._();

  factory _$MemberDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberDtoImplFromJson(json);

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
  final DateTime joinedAt;
  @override
  final bool isMe;

  @override
  String toString() {
    return 'MemberDto(userId: $userId, name: $name, nickname: $nickname, avatar: $avatar, role: $role, joinedAt: $joinedAt, isMe: $isMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isMe, isMe) || other.isMe == isMe));
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
    joinedAt,
    isMe,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberDtoImplCopyWith<_$MemberDtoImpl> get copyWith =>
      __$$MemberDtoImplCopyWithImpl<_$MemberDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberDtoImplToJson(this);
  }
}

abstract class _MemberDto extends MemberDto {
  const factory _MemberDto({
    required final String userId,
    required final String name,
    required final String? nickname,
    required final AvatarChoice? avatar,
    required final MemberRole role,
    required final DateTime joinedAt,
    required final bool isMe,
  }) = _$MemberDtoImpl;
  const _MemberDto._() : super._();

  factory _MemberDto.fromJson(Map<String, dynamic> json) =
      _$MemberDtoImpl.fromJson;

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
  DateTime get joinedAt;
  @override
  bool get isMe;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberDtoImplCopyWith<_$MemberDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvitationDto _$InvitationDtoFromJson(Map<String, dynamic> json) {
  return _InvitationDto.fromJson(json);
}

mixin _$InvitationDto {
  String get code => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String get shareUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationDtoCopyWith<InvitationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $InvitationDtoCopyWith<$Res> {
  factory $InvitationDtoCopyWith(
    InvitationDto value,
    $Res Function(InvitationDto) then,
  ) = _$InvitationDtoCopyWithImpl<$Res, InvitationDto>;
  @useResult
  $Res call({String code, DateTime expiresAt, String shareUrl});
}

class _$InvitationDtoCopyWithImpl<$Res, $Val extends InvitationDto>
    implements $InvitationDtoCopyWith<$Res> {
  _$InvitationDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? expiresAt = null,
    Object? shareUrl = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code ? _value.code : code as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt as DateTime,
            shareUrl: null == shareUrl ? _value.shareUrl : shareUrl as String,
          )
          as $Val,
    );
  }
}

abstract class _$$InvitationDtoImplCopyWith<$Res>
    implements $InvitationDtoCopyWith<$Res> {
  factory _$$InvitationDtoImplCopyWith(
    _$InvitationDtoImpl value,
    $Res Function(_$InvitationDtoImpl) then,
  ) = __$$InvitationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, DateTime expiresAt, String shareUrl});
}

class __$$InvitationDtoImplCopyWithImpl<$Res>
    extends _$InvitationDtoCopyWithImpl<$Res, _$InvitationDtoImpl>
    implements _$$InvitationDtoImplCopyWith<$Res> {
  __$$InvitationDtoImplCopyWithImpl(
    _$InvitationDtoImpl _value,
    $Res Function(_$InvitationDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? expiresAt = null,
    Object? shareUrl = null,
  }) {
    return _then(
      _$InvitationDtoImpl(
        code: null == code ? _value.code : code as String,
        expiresAt: null == expiresAt ? _value.expiresAt : expiresAt as DateTime,
        shareUrl: null == shareUrl ? _value.shareUrl : shareUrl as String,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$InvitationDtoImpl extends _InvitationDto {
  const _$InvitationDtoImpl({
    required this.code,
    required this.expiresAt,
    required this.shareUrl,
  }) : super._();

  factory _$InvitationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitationDtoImplFromJson(json);

  @override
  final String code;
  @override
  final DateTime expiresAt;
  @override
  final String shareUrl;

  @override
  String toString() {
    return 'InvitationDto(code: $code, expiresAt: $expiresAt, shareUrl: $shareUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, expiresAt, shareUrl);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationDtoImplCopyWith<_$InvitationDtoImpl> get copyWith =>
      __$$InvitationDtoImplCopyWithImpl<_$InvitationDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitationDtoImplToJson(this);
  }
}

abstract class _InvitationDto extends InvitationDto {
  const factory _InvitationDto({
    required final String code,
    required final DateTime expiresAt,
    required final String shareUrl,
  }) = _$InvitationDtoImpl;
  const _InvitationDto._() : super._();

  factory _InvitationDto.fromJson(Map<String, dynamic> json) =
      _$InvitationDtoImpl.fromJson;

  @override
  String get code;
  @override
  DateTime get expiresAt;
  @override
  String get shareUrl;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvitationDtoImplCopyWith<_$InvitationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvitationPreviewDto _$InvitationPreviewDtoFromJson(Map<String, dynamic> json) {
  return _InvitationPreviewDto.fromJson(json);
}

mixin _$InvitationPreviewDto {
  String get householdId => throw _privateConstructorUsedError;
  String get householdName => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationPreviewDtoCopyWith<InvitationPreviewDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $InvitationPreviewDtoCopyWith<$Res> {
  factory $InvitationPreviewDtoCopyWith(
    InvitationPreviewDto value,
    $Res Function(InvitationPreviewDto) then,
  ) = _$InvitationPreviewDtoCopyWithImpl<$Res, InvitationPreviewDto>;
  @useResult
  $Res call({
    String householdId,
    String householdName,
    int memberCount,
    DateTime expiresAt,
  });
}

class _$InvitationPreviewDtoCopyWithImpl<
  $Res,
  $Val extends InvitationPreviewDto
>
    implements $InvitationPreviewDtoCopyWith<$Res> {
  _$InvitationPreviewDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? householdId = null,
    Object? householdName = null,
    Object? memberCount = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            householdId: null == householdId
                ? _value.householdId
                : householdId as String,
            householdName: null == householdName
                ? _value.householdName
                : householdName as String,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount as int,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt as DateTime,
          )
          as $Val,
    );
  }
}

abstract class _$$InvitationPreviewDtoImplCopyWith<$Res>
    implements $InvitationPreviewDtoCopyWith<$Res> {
  factory _$$InvitationPreviewDtoImplCopyWith(
    _$InvitationPreviewDtoImpl value,
    $Res Function(_$InvitationPreviewDtoImpl) then,
  ) = __$$InvitationPreviewDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String householdId,
    String householdName,
    int memberCount,
    DateTime expiresAt,
  });
}

class __$$InvitationPreviewDtoImplCopyWithImpl<$Res>
    extends _$InvitationPreviewDtoCopyWithImpl<$Res, _$InvitationPreviewDtoImpl>
    implements _$$InvitationPreviewDtoImplCopyWith<$Res> {
  __$$InvitationPreviewDtoImplCopyWithImpl(
    _$InvitationPreviewDtoImpl _value,
    $Res Function(_$InvitationPreviewDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? householdId = null,
    Object? householdName = null,
    Object? memberCount = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$InvitationPreviewDtoImpl(
        householdId: null == householdId
            ? _value.householdId
            : householdId as String,
        householdName: null == householdName
            ? _value.householdName
            : householdName as String,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount as int,
        expiresAt: null == expiresAt ? _value.expiresAt : expiresAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$InvitationPreviewDtoImpl extends _InvitationPreviewDto {
  const _$InvitationPreviewDtoImpl({
    required this.householdId,
    required this.householdName,
    required this.memberCount,
    required this.expiresAt,
  }) : super._();

  factory _$InvitationPreviewDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitationPreviewDtoImplFromJson(json);

  @override
  final String householdId;
  @override
  final String householdName;
  @override
  final int memberCount;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'InvitationPreviewDto(householdId: $householdId, householdName: $householdName, memberCount: $memberCount, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationPreviewDtoImpl &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.householdName, householdName) ||
                other.householdName == householdName) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    householdId,
    householdName,
    memberCount,
    expiresAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationPreviewDtoImplCopyWith<_$InvitationPreviewDtoImpl>
  get copyWith =>
      __$$InvitationPreviewDtoImplCopyWithImpl<_$InvitationPreviewDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitationPreviewDtoImplToJson(this);
  }
}

abstract class _InvitationPreviewDto extends InvitationPreviewDto {
  const factory _InvitationPreviewDto({
    required final String householdId,
    required final String householdName,
    required final int memberCount,
    required final DateTime expiresAt,
  }) = _$InvitationPreviewDtoImpl;
  const _InvitationPreviewDto._() : super._();

  factory _InvitationPreviewDto.fromJson(Map<String, dynamic> json) =
      _$InvitationPreviewDtoImpl.fromJson;

  @override
  String get householdId;
  @override
  String get householdName;
  @override
  int get memberCount;
  @override
  DateTime get expiresAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvitationPreviewDtoImplCopyWith<_$InvitationPreviewDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
