part of 'capacity_entities.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$CapacityMember {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityMemberCopyWith<CapacityMember> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityMemberCopyWith<$Res> {
  factory $CapacityMemberCopyWith(
    CapacityMember value,
    $Res Function(CapacityMember) then,
  ) = _$CapacityMemberCopyWithImpl<$Res, CapacityMember>;
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class _$CapacityMemberCopyWithImpl<$Res, $Val extends CapacityMember>
    implements $CapacityMemberCopyWith<$Res> {
  _$CapacityMemberCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? avatar = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId ? _value.userId : userId as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName as String,
            avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
            isActive: null == isActive ? _value.isActive : isActive as bool,
          )
          as $Val,
    );
  }
}

abstract class _$$CapacityMemberImplCopyWith<$Res>
    implements $CapacityMemberCopyWith<$Res> {
  factory _$$CapacityMemberImplCopyWith(
    _$CapacityMemberImpl value,
    $Res Function(_$CapacityMemberImpl) then,
  ) = __$$CapacityMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class __$$CapacityMemberImplCopyWithImpl<$Res>
    extends _$CapacityMemberCopyWithImpl<$Res, _$CapacityMemberImpl>
    implements _$$CapacityMemberImplCopyWith<$Res> {
  __$$CapacityMemberImplCopyWithImpl(
    _$CapacityMemberImpl _value,
    $Res Function(_$CapacityMemberImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? avatar = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$CapacityMemberImpl(
        userId: null == userId ? _value.userId : userId as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName as String,
        avatar: freezed == avatar ? _value.avatar : avatar as AvatarChoice?,
        isActive: null == isActive ? _value.isActive : isActive as bool,
      ),
    );
  }
}

class _$CapacityMemberImpl implements _CapacityMember {
  const _$CapacityMemberImpl({
    required this.userId,
    required this.displayName,
    required this.avatar,
    required this.isActive,
  });

  @override
  final String userId;
  @override
  final String displayName;
  @override
  final AvatarChoice? avatar;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'CapacityMember(userId: $userId, displayName: $displayName, avatar: $avatar, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, displayName, avatar, isActive);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityMemberImplCopyWith<_$CapacityMemberImpl> get copyWith =>
      __$$CapacityMemberImplCopyWithImpl<_$CapacityMemberImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityMember implements CapacityMember {
  const factory _CapacityMember({
    required final String userId,
    required final String displayName,
    required final AvatarChoice? avatar,
    required final bool isActive,
  }) = _$CapacityMemberImpl;

  @override
  String get userId;
  @override
  String get displayName;
  @override
  AvatarChoice? get avatar;
  @override
  bool get isActive;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityMemberImplCopyWith<_$CapacityMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$CapacityAllocation {
  CapacityMember get member => throw _privateConstructorUsedError;
  int get percent => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityAllocationCopyWith<CapacityAllocation> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityAllocationCopyWith<$Res> {
  factory $CapacityAllocationCopyWith(
    CapacityAllocation value,
    $Res Function(CapacityAllocation) then,
  ) = _$CapacityAllocationCopyWithImpl<$Res, CapacityAllocation>;
  @useResult
  $Res call({CapacityMember member, int percent});

  $CapacityMemberCopyWith<$Res> get member;
}

class _$CapacityAllocationCopyWithImpl<$Res, $Val extends CapacityAllocation>
    implements $CapacityAllocationCopyWith<$Res> {
  _$CapacityAllocationCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? member = null, Object? percent = null}) {
    return _then(
      _value.copyWith(
            member: null == member ? _value.member : member as CapacityMember,
            percent: null == percent ? _value.percent : percent as int,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityMemberCopyWith<$Res> get member {
    return $CapacityMemberCopyWith<$Res>(_value.member, (value) {
      return _then(_value.copyWith(member: value) as $Val);
    });
  }
}

abstract class _$$CapacityAllocationImplCopyWith<$Res>
    implements $CapacityAllocationCopyWith<$Res> {
  factory _$$CapacityAllocationImplCopyWith(
    _$CapacityAllocationImpl value,
    $Res Function(_$CapacityAllocationImpl) then,
  ) = __$$CapacityAllocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CapacityMember member, int percent});

  @override
  $CapacityMemberCopyWith<$Res> get member;
}

class __$$CapacityAllocationImplCopyWithImpl<$Res>
    extends _$CapacityAllocationCopyWithImpl<$Res, _$CapacityAllocationImpl>
    implements _$$CapacityAllocationImplCopyWith<$Res> {
  __$$CapacityAllocationImplCopyWithImpl(
    _$CapacityAllocationImpl _value,
    $Res Function(_$CapacityAllocationImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? member = null, Object? percent = null}) {
    return _then(
      _$CapacityAllocationImpl(
        member: null == member ? _value.member : member as CapacityMember,
        percent: null == percent ? _value.percent : percent as int,
      ),
    );
  }
}

class _$CapacityAllocationImpl implements _CapacityAllocation {
  const _$CapacityAllocationImpl({required this.member, required this.percent});

  @override
  final CapacityMember member;
  @override
  final int percent;

  @override
  String toString() {
    return 'CapacityAllocation(member: $member, percent: $percent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityAllocationImpl &&
            (identical(other.member, member) || other.member == member) &&
            (identical(other.percent, percent) || other.percent == percent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, member, percent);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityAllocationImplCopyWith<_$CapacityAllocationImpl> get copyWith =>
      __$$CapacityAllocationImplCopyWithImpl<_$CapacityAllocationImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityAllocation implements CapacityAllocation {
  const factory _CapacityAllocation({
    required final CapacityMember member,
    required final int percent,
  }) = _$CapacityAllocationImpl;

  @override
  CapacityMember get member;
  @override
  int get percent;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityAllocationImplCopyWith<_$CapacityAllocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$CapacityDistribution {
  String get id => throw _privateConstructorUsedError;
  String get effectiveFrom => throw _privateConstructorUsedError;
  CapacityMember get approvedBy => throw _privateConstructorUsedError;
  DateTime get approvedAt => throw _privateConstructorUsedError;
  List<CapacityAllocation> get allocations =>
      throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityDistributionCopyWith<CapacityDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityDistributionCopyWith<$Res> {
  factory $CapacityDistributionCopyWith(
    CapacityDistribution value,
    $Res Function(CapacityDistribution) then,
  ) = _$CapacityDistributionCopyWithImpl<$Res, CapacityDistribution>;
  @useResult
  $Res call({
    String id,
    String effectiveFrom,
    CapacityMember approvedBy,
    DateTime approvedAt,
    List<CapacityAllocation> allocations,
  });

  $CapacityMemberCopyWith<$Res> get approvedBy;
}

class _$CapacityDistributionCopyWithImpl<
  $Res,
  $Val extends CapacityDistribution
>
    implements $CapacityDistributionCopyWith<$Res> {
  _$CapacityDistributionCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? effectiveFrom = null,
    Object? approvedBy = null,
    Object? approvedAt = null,
    Object? allocations = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            effectiveFrom: null == effectiveFrom
                ? _value.effectiveFrom
                : effectiveFrom as String,
            approvedBy: null == approvedBy
                ? _value.approvedBy
                : approvedBy as CapacityMember,
            approvedAt: null == approvedAt
                ? _value.approvedAt
                : approvedAt as DateTime,
            allocations: null == allocations
                ? _value.allocations
                : allocations as List<CapacityAllocation>,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityMemberCopyWith<$Res> get approvedBy {
    return $CapacityMemberCopyWith<$Res>(_value.approvedBy, (value) {
      return _then(_value.copyWith(approvedBy: value) as $Val);
    });
  }
}

abstract class _$$CapacityDistributionImplCopyWith<$Res>
    implements $CapacityDistributionCopyWith<$Res> {
  factory _$$CapacityDistributionImplCopyWith(
    _$CapacityDistributionImpl value,
    $Res Function(_$CapacityDistributionImpl) then,
  ) = __$$CapacityDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String effectiveFrom,
    CapacityMember approvedBy,
    DateTime approvedAt,
    List<CapacityAllocation> allocations,
  });

  @override
  $CapacityMemberCopyWith<$Res> get approvedBy;
}

class __$$CapacityDistributionImplCopyWithImpl<$Res>
    extends _$CapacityDistributionCopyWithImpl<$Res, _$CapacityDistributionImpl>
    implements _$$CapacityDistributionImplCopyWith<$Res> {
  __$$CapacityDistributionImplCopyWithImpl(
    _$CapacityDistributionImpl _value,
    $Res Function(_$CapacityDistributionImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? effectiveFrom = null,
    Object? approvedBy = null,
    Object? approvedAt = null,
    Object? allocations = null,
  }) {
    return _then(
      _$CapacityDistributionImpl(
        id: null == id ? _value.id : id as String,
        effectiveFrom: null == effectiveFrom
            ? _value.effectiveFrom
            : effectiveFrom as String,
        approvedBy: null == approvedBy
            ? _value.approvedBy
            : approvedBy as CapacityMember,
        approvedAt: null == approvedAt
            ? _value.approvedAt
            : approvedAt as DateTime,
        allocations: null == allocations
            ? _value._allocations
            : allocations as List<CapacityAllocation>,
      ),
    );
  }
}

class _$CapacityDistributionImpl implements _CapacityDistribution {
  const _$CapacityDistributionImpl({
    required this.id,
    required this.effectiveFrom,
    required this.approvedBy,
    required this.approvedAt,
    required final List<CapacityAllocation> allocations,
  }) : _allocations = allocations;

  @override
  final String id;
  @override
  final String effectiveFrom;
  @override
  final CapacityMember approvedBy;
  @override
  final DateTime approvedAt;
  final List<CapacityAllocation> _allocations;
  @override
  List<CapacityAllocation> get allocations {
    if (_allocations is EqualUnmodifiableListView) return _allocations;
    return EqualUnmodifiableListView(_allocations);
  }

  @override
  String toString() {
    return 'CapacityDistribution(id: $id, effectiveFrom: $effectiveFrom, approvedBy: $approvedBy, approvedAt: $approvedAt, allocations: $allocations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityDistributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            const DeepCollectionEquality().equals(
              other._allocations,
              _allocations,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    effectiveFrom,
    approvedBy,
    approvedAt,
    const DeepCollectionEquality().hash(_allocations),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityDistributionImplCopyWith<_$CapacityDistributionImpl>
  get copyWith =>
      __$$CapacityDistributionImplCopyWithImpl<_$CapacityDistributionImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityDistribution implements CapacityDistribution {
  const factory _CapacityDistribution({
    required final String id,
    required final String effectiveFrom,
    required final CapacityMember approvedBy,
    required final DateTime approvedAt,
    required final List<CapacityAllocation> allocations,
  }) = _$CapacityDistributionImpl;

  @override
  String get id;
  @override
  String get effectiveFrom;
  @override
  CapacityMember get approvedBy;
  @override
  DateTime get approvedAt;
  @override
  List<CapacityAllocation> get allocations;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityDistributionImplCopyWith<_$CapacityDistributionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

mixin _$CapacityProposal {
  CapacityMember get member => throw _privateConstructorUsedError;
  int? get proposedCapacityPercent => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityProposalCopyWith<CapacityProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityProposalCopyWith<$Res> {
  factory $CapacityProposalCopyWith(
    CapacityProposal value,
    $Res Function(CapacityProposal) then,
  ) = _$CapacityProposalCopyWithImpl<$Res, CapacityProposal>;
  @useResult
  $Res call({CapacityMember member, int? proposedCapacityPercent});

  $CapacityMemberCopyWith<$Res> get member;
}

class _$CapacityProposalCopyWithImpl<$Res, $Val extends CapacityProposal>
    implements $CapacityProposalCopyWith<$Res> {
  _$CapacityProposalCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? member = null,
    Object? proposedCapacityPercent = freezed,
  }) {
    return _then(
      _value.copyWith(
            member: null == member ? _value.member : member as CapacityMember,
            proposedCapacityPercent: freezed == proposedCapacityPercent
                ? _value.proposedCapacityPercent
                : proposedCapacityPercent as int?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityMemberCopyWith<$Res> get member {
    return $CapacityMemberCopyWith<$Res>(_value.member, (value) {
      return _then(_value.copyWith(member: value) as $Val);
    });
  }
}

abstract class _$$CapacityProposalImplCopyWith<$Res>
    implements $CapacityProposalCopyWith<$Res> {
  factory _$$CapacityProposalImplCopyWith(
    _$CapacityProposalImpl value,
    $Res Function(_$CapacityProposalImpl) then,
  ) = __$$CapacityProposalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CapacityMember member, int? proposedCapacityPercent});

  @override
  $CapacityMemberCopyWith<$Res> get member;
}

class __$$CapacityProposalImplCopyWithImpl<$Res>
    extends _$CapacityProposalCopyWithImpl<$Res, _$CapacityProposalImpl>
    implements _$$CapacityProposalImplCopyWith<$Res> {
  __$$CapacityProposalImplCopyWithImpl(
    _$CapacityProposalImpl _value,
    $Res Function(_$CapacityProposalImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? member = null,
    Object? proposedCapacityPercent = freezed,
  }) {
    return _then(
      _$CapacityProposalImpl(
        member: null == member ? _value.member : member as CapacityMember,
        proposedCapacityPercent: freezed == proposedCapacityPercent
            ? _value.proposedCapacityPercent
            : proposedCapacityPercent as int?,
      ),
    );
  }
}

class _$CapacityProposalImpl implements _CapacityProposal {
  const _$CapacityProposalImpl({
    required this.member,
    required this.proposedCapacityPercent,
  });

  @override
  final CapacityMember member;
  @override
  final int? proposedCapacityPercent;

  @override
  String toString() {
    return 'CapacityProposal(member: $member, proposedCapacityPercent: $proposedCapacityPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityProposalImpl &&
            (identical(other.member, member) || other.member == member) &&
            (identical(
                  other.proposedCapacityPercent,
                  proposedCapacityPercent,
                ) ||
                other.proposedCapacityPercent == proposedCapacityPercent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, member, proposedCapacityPercent);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityProposalImplCopyWith<_$CapacityProposalImpl> get copyWith =>
      __$$CapacityProposalImplCopyWithImpl<_$CapacityProposalImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityProposal implements CapacityProposal {
  const factory _CapacityProposal({
    required final CapacityMember member,
    required final int? proposedCapacityPercent,
  }) = _$CapacityProposalImpl;

  @override
  CapacityMember get member;
  @override
  int? get proposedCapacityPercent;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityProposalImplCopyWith<_$CapacityProposalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$CapacityOverview {
  CapacityStatus get status => throw _privateConstructorUsedError;
  CapacityDistribution? get current => throw _privateConstructorUsedError;
  CapacityDistribution? get upcoming => throw _privateConstructorUsedError;
  List<CapacityProposal> get proposals => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityOverviewCopyWith<CapacityOverview> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityOverviewCopyWith<$Res> {
  factory $CapacityOverviewCopyWith(
    CapacityOverview value,
    $Res Function(CapacityOverview) then,
  ) = _$CapacityOverviewCopyWithImpl<$Res, CapacityOverview>;
  @useResult
  $Res call({
    CapacityStatus status,
    CapacityDistribution? current,
    CapacityDistribution? upcoming,
    List<CapacityProposal> proposals,
  });

  $CapacityDistributionCopyWith<$Res>? get current;
  $CapacityDistributionCopyWith<$Res>? get upcoming;
}

class _$CapacityOverviewCopyWithImpl<$Res, $Val extends CapacityOverview>
    implements $CapacityOverviewCopyWith<$Res> {
  _$CapacityOverviewCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? current = freezed,
    Object? upcoming = freezed,
    Object? proposals = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status ? _value.status : status as CapacityStatus,
            current: freezed == current
                ? _value.current
                : current as CapacityDistribution?,
            upcoming: freezed == upcoming
                ? _value.upcoming
                : upcoming as CapacityDistribution?,
            proposals: null == proposals
                ? _value.proposals
                : proposals as List<CapacityProposal>,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityDistributionCopyWith<$Res>? get current {
    if (_value.current == null) {
      return null;
    }

    return $CapacityDistributionCopyWith<$Res>(_value.current!, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityDistributionCopyWith<$Res>? get upcoming {
    if (_value.upcoming == null) {
      return null;
    }

    return $CapacityDistributionCopyWith<$Res>(_value.upcoming!, (value) {
      return _then(_value.copyWith(upcoming: value) as $Val);
    });
  }
}

abstract class _$$CapacityOverviewImplCopyWith<$Res>
    implements $CapacityOverviewCopyWith<$Res> {
  factory _$$CapacityOverviewImplCopyWith(
    _$CapacityOverviewImpl value,
    $Res Function(_$CapacityOverviewImpl) then,
  ) = __$$CapacityOverviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CapacityStatus status,
    CapacityDistribution? current,
    CapacityDistribution? upcoming,
    List<CapacityProposal> proposals,
  });

  @override
  $CapacityDistributionCopyWith<$Res>? get current;
  @override
  $CapacityDistributionCopyWith<$Res>? get upcoming;
}

class __$$CapacityOverviewImplCopyWithImpl<$Res>
    extends _$CapacityOverviewCopyWithImpl<$Res, _$CapacityOverviewImpl>
    implements _$$CapacityOverviewImplCopyWith<$Res> {
  __$$CapacityOverviewImplCopyWithImpl(
    _$CapacityOverviewImpl _value,
    $Res Function(_$CapacityOverviewImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? current = freezed,
    Object? upcoming = freezed,
    Object? proposals = null,
  }) {
    return _then(
      _$CapacityOverviewImpl(
        status: null == status ? _value.status : status as CapacityStatus,
        current: freezed == current
            ? _value.current
            : current as CapacityDistribution?,
        upcoming: freezed == upcoming
            ? _value.upcoming
            : upcoming as CapacityDistribution?,
        proposals: null == proposals
            ? _value._proposals
            : proposals as List<CapacityProposal>,
      ),
    );
  }
}

class _$CapacityOverviewImpl implements _CapacityOverview {
  const _$CapacityOverviewImpl({
    required this.status,
    required this.current,
    required this.upcoming,
    required final List<CapacityProposal> proposals,
  }) : _proposals = proposals;

  @override
  final CapacityStatus status;
  @override
  final CapacityDistribution? current;
  @override
  final CapacityDistribution? upcoming;
  final List<CapacityProposal> _proposals;
  @override
  List<CapacityProposal> get proposals {
    if (_proposals is EqualUnmodifiableListView) return _proposals;
    return EqualUnmodifiableListView(_proposals);
  }

  @override
  String toString() {
    return 'CapacityOverview(status: $status, current: $current, upcoming: $upcoming, proposals: $proposals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityOverviewImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.upcoming, upcoming) ||
                other.upcoming == upcoming) &&
            const DeepCollectionEquality().equals(
              other._proposals,
              _proposals,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    current,
    upcoming,
    const DeepCollectionEquality().hash(_proposals),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityOverviewImplCopyWith<_$CapacityOverviewImpl> get copyWith =>
      __$$CapacityOverviewImplCopyWithImpl<_$CapacityOverviewImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityOverview implements CapacityOverview {
  const factory _CapacityOverview({
    required final CapacityStatus status,
    required final CapacityDistribution? current,
    required final CapacityDistribution? upcoming,
    required final List<CapacityProposal> proposals,
  }) = _$CapacityOverviewImpl;

  @override
  CapacityStatus get status;
  @override
  CapacityDistribution? get current;
  @override
  CapacityDistribution? get upcoming;
  @override
  List<CapacityProposal> get proposals;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityOverviewImplCopyWith<_$CapacityOverviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$CapacityHistory {
  List<CapacityDistribution> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityHistoryCopyWith<CapacityHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityHistoryCopyWith<$Res> {
  factory $CapacityHistoryCopyWith(
    CapacityHistory value,
    $Res Function(CapacityHistory) then,
  ) = _$CapacityHistoryCopyWithImpl<$Res, CapacityHistory>;
  @useResult
  $Res call({List<CapacityDistribution> items, String? nextCursor});
}

class _$CapacityHistoryCopyWithImpl<$Res, $Val extends CapacityHistory>
    implements $CapacityHistoryCopyWith<$Res> {
  _$CapacityHistoryCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? nextCursor = freezed}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items as List<CapacityDistribution>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor as String?,
          )
          as $Val,
    );
  }
}

abstract class _$$CapacityHistoryImplCopyWith<$Res>
    implements $CapacityHistoryCopyWith<$Res> {
  factory _$$CapacityHistoryImplCopyWith(
    _$CapacityHistoryImpl value,
    $Res Function(_$CapacityHistoryImpl) then,
  ) = __$$CapacityHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CapacityDistribution> items, String? nextCursor});
}

class __$$CapacityHistoryImplCopyWithImpl<$Res>
    extends _$CapacityHistoryCopyWithImpl<$Res, _$CapacityHistoryImpl>
    implements _$$CapacityHistoryImplCopyWith<$Res> {
  __$$CapacityHistoryImplCopyWithImpl(
    _$CapacityHistoryImpl _value,
    $Res Function(_$CapacityHistoryImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? nextCursor = freezed}) {
    return _then(
      _$CapacityHistoryImpl(
        items: null == items
            ? _value._items
            : items as List<CapacityDistribution>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor as String?,
      ),
    );
  }
}

class _$CapacityHistoryImpl implements _CapacityHistory {
  const _$CapacityHistoryImpl({
    required final List<CapacityDistribution> items,
    required this.nextCursor,
  }) : _items = items;

  final List<CapacityDistribution> _items;
  @override
  List<CapacityDistribution> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'CapacityHistory(items: $items, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityHistoryImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityHistoryImplCopyWith<_$CapacityHistoryImpl> get copyWith =>
      __$$CapacityHistoryImplCopyWithImpl<_$CapacityHistoryImpl>(
        this,
        _$identity,
      );
}

abstract class _CapacityHistory implements CapacityHistory {
  const factory _CapacityHistory({
    required final List<CapacityDistribution> items,
    required final String? nextCursor,
  }) = _$CapacityHistoryImpl;

  @override
  List<CapacityDistribution> get items;
  @override
  String? get nextCursor;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityHistoryImplCopyWith<_$CapacityHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
