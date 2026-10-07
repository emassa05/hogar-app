part of 'capacity_state.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$CapacityState {
  CapacityOverview get overview => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  String get savedPart => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;
  DateTime? get blockedUntil => throw _privateConstructorUsedError;
  List<CapacityDistribution> get history => throw _privateConstructorUsedError;
  bool get historyLoaded => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapacityStateCopyWith<CapacityState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $CapacityStateCopyWith<$Res> {
  factory $CapacityStateCopyWith(
    CapacityState value,
    $Res Function(CapacityState) then,
  ) = _$CapacityStateCopyWithImpl<$Res, CapacityState>;
  @useResult
  $Res call({
    CapacityOverview overview,
    MemberRole role,
    bool busy,
    String savedPart,
    AppException? error,
    DateTime? blockedUntil,
    List<CapacityDistribution> history,
    bool historyLoaded,
    String? nextCursor,
  });

  $CapacityOverviewCopyWith<$Res> get overview;
}

class _$CapacityStateCopyWithImpl<$Res, $Val extends CapacityState>
    implements $CapacityStateCopyWith<$Res> {
  _$CapacityStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overview = null,
    Object? role = null,
    Object? busy = null,
    Object? savedPart = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? history = null,
    Object? historyLoaded = null,
    Object? nextCursor = freezed,
  }) {
    return _then(
      _value.copyWith(
            overview: null == overview
                ? _value.overview
                : overview as CapacityOverview,
            role: null == role ? _value.role : role as MemberRole,
            busy: null == busy ? _value.busy : busy as bool,
            savedPart: null == savedPart
                ? _value.savedPart
                : savedPart as String,
            error: freezed == error ? _value.error : error as AppException?,
            blockedUntil: freezed == blockedUntil
                ? _value.blockedUntil
                : blockedUntil as DateTime?,
            history: null == history
                ? _value.history
                : history as List<CapacityDistribution>,
            historyLoaded: null == historyLoaded
                ? _value.historyLoaded
                : historyLoaded as bool,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor as String?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $CapacityOverviewCopyWith<$Res> get overview {
    return $CapacityOverviewCopyWith<$Res>(_value.overview, (value) {
      return _then(_value.copyWith(overview: value) as $Val);
    });
  }
}

abstract class _$$CapacityStateImplCopyWith<$Res>
    implements $CapacityStateCopyWith<$Res> {
  factory _$$CapacityStateImplCopyWith(
    _$CapacityStateImpl value,
    $Res Function(_$CapacityStateImpl) then,
  ) = __$$CapacityStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CapacityOverview overview,
    MemberRole role,
    bool busy,
    String savedPart,
    AppException? error,
    DateTime? blockedUntil,
    List<CapacityDistribution> history,
    bool historyLoaded,
    String? nextCursor,
  });

  @override
  $CapacityOverviewCopyWith<$Res> get overview;
}

class __$$CapacityStateImplCopyWithImpl<$Res>
    extends _$CapacityStateCopyWithImpl<$Res, _$CapacityStateImpl>
    implements _$$CapacityStateImplCopyWith<$Res> {
  __$$CapacityStateImplCopyWithImpl(
    _$CapacityStateImpl _value,
    $Res Function(_$CapacityStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overview = null,
    Object? role = null,
    Object? busy = null,
    Object? savedPart = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? history = null,
    Object? historyLoaded = null,
    Object? nextCursor = freezed,
  }) {
    return _then(
      _$CapacityStateImpl(
        overview: null == overview
            ? _value.overview
            : overview as CapacityOverview,
        role: null == role ? _value.role : role as MemberRole,
        busy: null == busy ? _value.busy : busy as bool,
        savedPart: null == savedPart ? _value.savedPart : savedPart as String,
        error: freezed == error ? _value.error : error as AppException?,
        blockedUntil: freezed == blockedUntil
            ? _value.blockedUntil
            : blockedUntil as DateTime?,
        history: null == history
            ? _value._history
            : history as List<CapacityDistribution>,
        historyLoaded: null == historyLoaded
            ? _value.historyLoaded
            : historyLoaded as bool,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor as String?,
      ),
    );
  }
}

class _$CapacityStateImpl implements _CapacityState {
  const _$CapacityStateImpl({
    required this.overview,
    required this.role,
    this.busy = false,
    this.savedPart = '',
    this.error,
    this.blockedUntil,
    final List<CapacityDistribution> history = const [],
    this.historyLoaded = false,
    this.nextCursor,
  }) : _history = history;

  @override
  final CapacityOverview overview;
  @override
  final MemberRole role;
  @override
  @JsonKey()
  final bool busy;
  @override
  @JsonKey()
  final String savedPart;
  @override
  final AppException? error;
  @override
  final DateTime? blockedUntil;
  final List<CapacityDistribution> _history;
  @override
  @JsonKey()
  List<CapacityDistribution> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    return EqualUnmodifiableListView(_history);
  }

  @override
  @JsonKey()
  final bool historyLoaded;
  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'CapacityState(overview: $overview, role: $role, busy: $busy, savedPart: $savedPart, error: $error, blockedUntil: $blockedUntil, history: $history, historyLoaded: $historyLoaded, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapacityStateImpl &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.savedPart, savedPart) ||
                other.savedPart == savedPart) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.blockedUntil, blockedUntil) ||
                other.blockedUntil == blockedUntil) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.historyLoaded, historyLoaded) ||
                other.historyLoaded == historyLoaded) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    overview,
    role,
    busy,
    savedPart,
    error,
    blockedUntil,
    const DeepCollectionEquality().hash(_history),
    historyLoaded,
    nextCursor,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapacityStateImplCopyWith<_$CapacityStateImpl> get copyWith =>
      __$$CapacityStateImplCopyWithImpl<_$CapacityStateImpl>(this, _$identity);
}

abstract class _CapacityState implements CapacityState {
  const factory _CapacityState({
    required final CapacityOverview overview,
    required final MemberRole role,
    final bool busy,
    final String savedPart,
    final AppException? error,
    final DateTime? blockedUntil,
    final List<CapacityDistribution> history,
    final bool historyLoaded,
    final String? nextCursor,
  }) = _$CapacityStateImpl;

  @override
  CapacityOverview get overview;
  @override
  MemberRole get role;
  @override
  bool get busy;
  @override
  String get savedPart;
  @override
  AppException? get error;
  @override
  DateTime? get blockedUntil;
  @override
  List<CapacityDistribution> get history;
  @override
  bool get historyLoaded;
  @override
  String? get nextCursor;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapacityStateImplCopyWith<_$CapacityStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
