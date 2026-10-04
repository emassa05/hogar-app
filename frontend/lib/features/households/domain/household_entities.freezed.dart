part of 'household_entities.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$HouseholdSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MemberRole get myRole => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdSummaryCopyWith<HouseholdSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $HouseholdSummaryCopyWith<$Res> {
  factory $HouseholdSummaryCopyWith(
    HouseholdSummary value,
    $Res Function(HouseholdSummary) then,
  ) = _$HouseholdSummaryCopyWithImpl<$Res, HouseholdSummary>;
  @useResult
  $Res call({
    String id,
    String name,
    MemberRole myRole,
    int memberCount,
    DateTime createdAt,
  });
}

class _$HouseholdSummaryCopyWithImpl<$Res, $Val extends HouseholdSummary>
    implements $HouseholdSummaryCopyWith<$Res> {
  _$HouseholdSummaryCopyWithImpl(this._value, this._then);

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

abstract class _$$HouseholdSummaryImplCopyWith<$Res>
    implements $HouseholdSummaryCopyWith<$Res> {
  factory _$$HouseholdSummaryImplCopyWith(
    _$HouseholdSummaryImpl value,
    $Res Function(_$HouseholdSummaryImpl) then,
  ) = __$$HouseholdSummaryImplCopyWithImpl<$Res>;
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

class __$$HouseholdSummaryImplCopyWithImpl<$Res>
    extends _$HouseholdSummaryCopyWithImpl<$Res, _$HouseholdSummaryImpl>
    implements _$$HouseholdSummaryImplCopyWith<$Res> {
  __$$HouseholdSummaryImplCopyWithImpl(
    _$HouseholdSummaryImpl _value,
    $Res Function(_$HouseholdSummaryImpl) _then,
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
      _$HouseholdSummaryImpl(
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

class _$HouseholdSummaryImpl implements _HouseholdSummary {
  const _$HouseholdSummaryImpl({
    required this.id,
    required this.name,
    required this.myRole,
    required this.memberCount,
    required this.createdAt,
  });

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
    return 'HouseholdSummary(id: $id, name: $name, myRole: $myRole, memberCount: $memberCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.myRole, myRole) || other.myRole == myRole) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, myRole, memberCount, createdAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdSummaryImplCopyWith<_$HouseholdSummaryImpl> get copyWith =>
      __$$HouseholdSummaryImplCopyWithImpl<_$HouseholdSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _HouseholdSummary implements HouseholdSummary {
  const factory _HouseholdSummary({
    required final String id,
    required final String name,
    required final MemberRole myRole,
    required final int memberCount,
    required final DateTime createdAt,
  }) = _$HouseholdSummaryImpl;

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
  _$$HouseholdSummaryImplCopyWith<_$HouseholdSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$HouseholdDetail {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  int? get imbalanceThresholdPercent => throw _privateConstructorUsedError;
  MemberRole get myRole => throw _privateConstructorUsedError;
  List<Member> get members => throw _privateConstructorUsedError;
  bool get templatesApplied => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdDetailCopyWith<HouseholdDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $HouseholdDetailCopyWith<$Res> {
  factory $HouseholdDetailCopyWith(
    HouseholdDetail value,
    $Res Function(HouseholdDetail) then,
  ) = _$HouseholdDetailCopyWithImpl<$Res, HouseholdDetail>;
  @useResult
  $Res call({
    String id,
    String name,
    String timezone,
    int? imbalanceThresholdPercent,
    MemberRole myRole,
    List<Member> members,
    bool templatesApplied,
    int version,
    DateTime createdAt,
  });
}

class _$HouseholdDetailCopyWithImpl<$Res, $Val extends HouseholdDetail>
    implements $HouseholdDetailCopyWith<$Res> {
  _$HouseholdDetailCopyWithImpl(this._value, this._then);

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
            members: null == members ? _value.members : members as List<Member>,
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

abstract class _$$HouseholdDetailImplCopyWith<$Res>
    implements $HouseholdDetailCopyWith<$Res> {
  factory _$$HouseholdDetailImplCopyWith(
    _$HouseholdDetailImpl value,
    $Res Function(_$HouseholdDetailImpl) then,
  ) = __$$HouseholdDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String timezone,
    int? imbalanceThresholdPercent,
    MemberRole myRole,
    List<Member> members,
    bool templatesApplied,
    int version,
    DateTime createdAt,
  });
}

class __$$HouseholdDetailImplCopyWithImpl<$Res>
    extends _$HouseholdDetailCopyWithImpl<$Res, _$HouseholdDetailImpl>
    implements _$$HouseholdDetailImplCopyWith<$Res> {
  __$$HouseholdDetailImplCopyWithImpl(
    _$HouseholdDetailImpl _value,
    $Res Function(_$HouseholdDetailImpl) _then,
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
      _$HouseholdDetailImpl(
        id: null == id ? _value.id : id as String,
        name: null == name ? _value.name : name as String,
        timezone: null == timezone ? _value.timezone : timezone as String,
        imbalanceThresholdPercent: freezed == imbalanceThresholdPercent
            ? _value.imbalanceThresholdPercent
            : imbalanceThresholdPercent as int?,
        myRole: null == myRole ? _value.myRole : myRole as MemberRole,
        members: null == members ? _value._members : members as List<Member>,
        templatesApplied: null == templatesApplied
            ? _value.templatesApplied
            : templatesApplied as bool,
        version: null == version ? _value.version : version as int,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      ),
    );
  }
}

class _$HouseholdDetailImpl implements _HouseholdDetail {
  const _$HouseholdDetailImpl({
    required this.id,
    required this.name,
    required this.timezone,
    required this.imbalanceThresholdPercent,
    required this.myRole,
    required final List<Member> members,
    required this.templatesApplied,
    required this.version,
    required this.createdAt,
  }) : _members = members;

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
  final List<Member> _members;
  @override
  List<Member> get members {
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
    return 'HouseholdDetail(id: $id, name: $name, timezone: $timezone, imbalanceThresholdPercent: $imbalanceThresholdPercent, myRole: $myRole, members: $members, templatesApplied: $templatesApplied, version: $version, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdDetailImpl &&
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
  _$$HouseholdDetailImplCopyWith<_$HouseholdDetailImpl> get copyWith =>
      __$$HouseholdDetailImplCopyWithImpl<_$HouseholdDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _HouseholdDetail implements HouseholdDetail {
  const factory _HouseholdDetail({
    required final String id,
    required final String name,
    required final String timezone,
    required final int? imbalanceThresholdPercent,
    required final MemberRole myRole,
    required final List<Member> members,
    required final bool templatesApplied,
    required final int version,
    required final DateTime createdAt,
  }) = _$HouseholdDetailImpl;

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
  List<Member> get members;
  @override
  bool get templatesApplied;
  @override
  int get version;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdDetailImplCopyWith<_$HouseholdDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$Member {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberCopyWith<Member> get copyWith => throw _privateConstructorUsedError;
}

abstract class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) then) =
      _$MemberCopyWithImpl<$Res, Member>;
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

class _$MemberCopyWithImpl<$Res, $Val extends Member>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._value, this._then);

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

abstract class _$$MemberImplCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$$MemberImplCopyWith(
    _$MemberImpl value,
    $Res Function(_$MemberImpl) then,
  ) = __$$MemberImplCopyWithImpl<$Res>;
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

class __$$MemberImplCopyWithImpl<$Res>
    extends _$MemberCopyWithImpl<$Res, _$MemberImpl>
    implements _$$MemberImplCopyWith<$Res> {
  __$$MemberImplCopyWithImpl(
    _$MemberImpl _value,
    $Res Function(_$MemberImpl) _then,
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
      _$MemberImpl(
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

class _$MemberImpl extends _Member {
  const _$MemberImpl({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.role,
    required this.joinedAt,
    required this.isMe,
  }) : super._();

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
    return 'Member(userId: $userId, name: $name, nickname: $nickname, avatar: $avatar, role: $role, joinedAt: $joinedAt, isMe: $isMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberImpl &&
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
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      __$$MemberImplCopyWithImpl<_$MemberImpl>(this, _$identity);
}

abstract class _Member extends Member {
  const factory _Member({
    required final String userId,
    required final String name,
    required final String? nickname,
    required final AvatarChoice? avatar,
    required final MemberRole role,
    required final DateTime joinedAt,
    required final bool isMe,
  }) = _$MemberImpl;
  const _Member._() : super._();

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
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$Invitation {
  String get code => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String get shareUrl => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationCopyWith<Invitation> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $InvitationCopyWith<$Res> {
  factory $InvitationCopyWith(
    Invitation value,
    $Res Function(Invitation) then,
  ) = _$InvitationCopyWithImpl<$Res, Invitation>;
  @useResult
  $Res call({String code, DateTime expiresAt, String shareUrl});
}

class _$InvitationCopyWithImpl<$Res, $Val extends Invitation>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._value, this._then);

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

abstract class _$$InvitationImplCopyWith<$Res>
    implements $InvitationCopyWith<$Res> {
  factory _$$InvitationImplCopyWith(
    _$InvitationImpl value,
    $Res Function(_$InvitationImpl) then,
  ) = __$$InvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, DateTime expiresAt, String shareUrl});
}

class __$$InvitationImplCopyWithImpl<$Res>
    extends _$InvitationCopyWithImpl<$Res, _$InvitationImpl>
    implements _$$InvitationImplCopyWith<$Res> {
  __$$InvitationImplCopyWithImpl(
    _$InvitationImpl _value,
    $Res Function(_$InvitationImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? expiresAt = null,
    Object? shareUrl = null,
  }) {
    return _then(
      _$InvitationImpl(
        code: null == code ? _value.code : code as String,
        expiresAt: null == expiresAt ? _value.expiresAt : expiresAt as DateTime,
        shareUrl: null == shareUrl ? _value.shareUrl : shareUrl as String,
      ),
    );
  }
}

class _$InvitationImpl implements _Invitation {
  const _$InvitationImpl({
    required this.code,
    required this.expiresAt,
    required this.shareUrl,
  });

  @override
  final String code;
  @override
  final DateTime expiresAt;
  @override
  final String shareUrl;

  @override
  String toString() {
    return 'Invitation(code: $code, expiresAt: $expiresAt, shareUrl: $shareUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, expiresAt, shareUrl);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationImplCopyWith<_$InvitationImpl> get copyWith =>
      __$$InvitationImplCopyWithImpl<_$InvitationImpl>(this, _$identity);
}

abstract class _Invitation implements Invitation {
  const factory _Invitation({
    required final String code,
    required final DateTime expiresAt,
    required final String shareUrl,
  }) = _$InvitationImpl;

  @override
  String get code;
  @override
  DateTime get expiresAt;
  @override
  String get shareUrl;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvitationImplCopyWith<_$InvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$InvitationPreview {
  String get householdId => throw _privateConstructorUsedError;
  String get householdName => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationPreviewCopyWith<InvitationPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $InvitationPreviewCopyWith<$Res> {
  factory $InvitationPreviewCopyWith(
    InvitationPreview value,
    $Res Function(InvitationPreview) then,
  ) = _$InvitationPreviewCopyWithImpl<$Res, InvitationPreview>;
  @useResult
  $Res call({
    String householdId,
    String householdName,
    int memberCount,
    DateTime expiresAt,
  });
}

class _$InvitationPreviewCopyWithImpl<$Res, $Val extends InvitationPreview>
    implements $InvitationPreviewCopyWith<$Res> {
  _$InvitationPreviewCopyWithImpl(this._value, this._then);

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

abstract class _$$InvitationPreviewImplCopyWith<$Res>
    implements $InvitationPreviewCopyWith<$Res> {
  factory _$$InvitationPreviewImplCopyWith(
    _$InvitationPreviewImpl value,
    $Res Function(_$InvitationPreviewImpl) then,
  ) = __$$InvitationPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String householdId,
    String householdName,
    int memberCount,
    DateTime expiresAt,
  });
}

class __$$InvitationPreviewImplCopyWithImpl<$Res>
    extends _$InvitationPreviewCopyWithImpl<$Res, _$InvitationPreviewImpl>
    implements _$$InvitationPreviewImplCopyWith<$Res> {
  __$$InvitationPreviewImplCopyWithImpl(
    _$InvitationPreviewImpl _value,
    $Res Function(_$InvitationPreviewImpl) _then,
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
      _$InvitationPreviewImpl(
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

class _$InvitationPreviewImpl implements _InvitationPreview {
  const _$InvitationPreviewImpl({
    required this.householdId,
    required this.householdName,
    required this.memberCount,
    required this.expiresAt,
  });

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
    return 'InvitationPreview(householdId: $householdId, householdName: $householdName, memberCount: $memberCount, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationPreviewImpl &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.householdName, householdName) ||
                other.householdName == householdName) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

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
  _$$InvitationPreviewImplCopyWith<_$InvitationPreviewImpl> get copyWith =>
      __$$InvitationPreviewImplCopyWithImpl<_$InvitationPreviewImpl>(
        this,
        _$identity,
      );
}

abstract class _InvitationPreview implements InvitationPreview {
  const factory _InvitationPreview({
    required final String householdId,
    required final String householdName,
    required final int memberCount,
    required final DateTime expiresAt,
  }) = _$InvitationPreviewImpl;

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
  _$$InvitationPreviewImplCopyWith<_$InvitationPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
