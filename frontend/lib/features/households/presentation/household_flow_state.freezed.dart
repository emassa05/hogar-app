part of 'household_flow_state.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$HouseholdFlowState {
  HouseholdDetail? get household => throw _privateConstructorUsedError;
  Invitation? get invitation => throw _privateConstructorUsedError;
  InvitationPreview? get preview => throw _privateConstructorUsedError;
  String get previewCode => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;
  DateTime? get blockedUntil => throw _privateConstructorUsedError;
  String get savedPart => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdFlowStateCopyWith<HouseholdFlowState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $HouseholdFlowStateCopyWith<$Res> {
  factory $HouseholdFlowStateCopyWith(
    HouseholdFlowState value,
    $Res Function(HouseholdFlowState) then,
  ) = _$HouseholdFlowStateCopyWithImpl<$Res, HouseholdFlowState>;
  @useResult
  $Res call({
    HouseholdDetail? household,
    Invitation? invitation,
    InvitationPreview? preview,
    String previewCode,
    bool busy,
    AppException? error,
    DateTime? blockedUntil,
    String savedPart,
  });

  $HouseholdDetailCopyWith<$Res>? get household;
  $InvitationCopyWith<$Res>? get invitation;
  $InvitationPreviewCopyWith<$Res>? get preview;
}

class _$HouseholdFlowStateCopyWithImpl<$Res, $Val extends HouseholdFlowState>
    implements $HouseholdFlowStateCopyWith<$Res> {
  _$HouseholdFlowStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? household = freezed,
    Object? invitation = freezed,
    Object? preview = freezed,
    Object? previewCode = null,
    Object? busy = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? savedPart = null,
  }) {
    return _then(
      _value.copyWith(
            household: freezed == household
                ? _value.household
                : household as HouseholdDetail?,
            invitation: freezed == invitation
                ? _value.invitation
                : invitation as Invitation?,
            preview: freezed == preview
                ? _value.preview
                : preview as InvitationPreview?,
            previewCode: null == previewCode
                ? _value.previewCode
                : previewCode as String,
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
  $HouseholdDetailCopyWith<$Res>? get household {
    if (_value.household == null) {
      return null;
    }

    return $HouseholdDetailCopyWith<$Res>(_value.household!, (value) {
      return _then(_value.copyWith(household: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $InvitationCopyWith<$Res>? get invitation {
    if (_value.invitation == null) {
      return null;
    }

    return $InvitationCopyWith<$Res>(_value.invitation!, (value) {
      return _then(_value.copyWith(invitation: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $InvitationPreviewCopyWith<$Res>? get preview {
    if (_value.preview == null) {
      return null;
    }

    return $InvitationPreviewCopyWith<$Res>(_value.preview!, (value) {
      return _then(_value.copyWith(preview: value) as $Val);
    });
  }
}

abstract class _$$HouseholdFlowStateImplCopyWith<$Res>
    implements $HouseholdFlowStateCopyWith<$Res> {
  factory _$$HouseholdFlowStateImplCopyWith(
    _$HouseholdFlowStateImpl value,
    $Res Function(_$HouseholdFlowStateImpl) then,
  ) = __$$HouseholdFlowStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    HouseholdDetail? household,
    Invitation? invitation,
    InvitationPreview? preview,
    String previewCode,
    bool busy,
    AppException? error,
    DateTime? blockedUntil,
    String savedPart,
  });

  @override
  $HouseholdDetailCopyWith<$Res>? get household;
  @override
  $InvitationCopyWith<$Res>? get invitation;
  @override
  $InvitationPreviewCopyWith<$Res>? get preview;
}

class __$$HouseholdFlowStateImplCopyWithImpl<$Res>
    extends _$HouseholdFlowStateCopyWithImpl<$Res, _$HouseholdFlowStateImpl>
    implements _$$HouseholdFlowStateImplCopyWith<$Res> {
  __$$HouseholdFlowStateImplCopyWithImpl(
    _$HouseholdFlowStateImpl _value,
    $Res Function(_$HouseholdFlowStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? household = freezed,
    Object? invitation = freezed,
    Object? preview = freezed,
    Object? previewCode = null,
    Object? busy = null,
    Object? error = freezed,
    Object? blockedUntil = freezed,
    Object? savedPart = null,
  }) {
    return _then(
      _$HouseholdFlowStateImpl(
        household: freezed == household
            ? _value.household
            : household as HouseholdDetail?,
        invitation: freezed == invitation
            ? _value.invitation
            : invitation as Invitation?,
        preview: freezed == preview
            ? _value.preview
            : preview as InvitationPreview?,
        previewCode: null == previewCode
            ? _value.previewCode
            : previewCode as String,
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

class _$HouseholdFlowStateImpl implements _HouseholdFlowState {
  const _$HouseholdFlowStateImpl({
    this.household,
    this.invitation,
    this.preview,
    this.previewCode = '',
    this.busy = false,
    this.error,
    this.blockedUntil,
    this.savedPart = '',
  });

  @override
  final HouseholdDetail? household;
  @override
  final Invitation? invitation;
  @override
  final InvitationPreview? preview;
  @override
  @JsonKey()
  final String previewCode;
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
    return 'HouseholdFlowState(household: $household, invitation: $invitation, preview: $preview, previewCode: $previewCode, busy: $busy, error: $error, blockedUntil: $blockedUntil, savedPart: $savedPart)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdFlowStateImpl &&
            (identical(other.household, household) ||
                other.household == household) &&
            (identical(other.invitation, invitation) ||
                other.invitation == invitation) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            (identical(other.previewCode, previewCode) ||
                other.previewCode == previewCode) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.blockedUntil, blockedUntil) ||
                other.blockedUntil == blockedUntil) &&
            (identical(other.savedPart, savedPart) ||
                other.savedPart == savedPart));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    household,
    invitation,
    preview,
    previewCode,
    busy,
    error,
    blockedUntil,
    savedPart,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdFlowStateImplCopyWith<_$HouseholdFlowStateImpl> get copyWith =>
      __$$HouseholdFlowStateImplCopyWithImpl<_$HouseholdFlowStateImpl>(
        this,
        _$identity,
      );
}

abstract class _HouseholdFlowState implements HouseholdFlowState {
  const factory _HouseholdFlowState({
    final HouseholdDetail? household,
    final Invitation? invitation,
    final InvitationPreview? preview,
    final String previewCode,
    final bool busy,
    final AppException? error,
    final DateTime? blockedUntil,
    final String savedPart,
  }) = _$HouseholdFlowStateImpl;

  @override
  HouseholdDetail? get household;
  @override
  Invitation? get invitation;
  @override
  InvitationPreview? get preview;
  @override
  String get previewCode;
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
  _$$HouseholdFlowStateImplCopyWith<_$HouseholdFlowStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
