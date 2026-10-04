part of 'template_selection_state.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$TemplateSelectionState {
  List<TemplateSummary> get templates => throw _privateConstructorUsedError;
  Map<String, TemplateDetail> get details => throw _privateConstructorUsedError;
  Set<String> get selected => throw _privateConstructorUsedError;
  bool get busy => throw _privateConstructorUsedError;
  TemplateApplication? get application => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;
  DateTime? get blockedUntil => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateSelectionStateCopyWith<TemplateSelectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateSelectionStateCopyWith<$Res> {
  factory $TemplateSelectionStateCopyWith(
    TemplateSelectionState value,
    $Res Function(TemplateSelectionState) then,
  ) = _$TemplateSelectionStateCopyWithImpl<$Res, TemplateSelectionState>;
  @useResult
  $Res call({
    List<TemplateSummary> templates,
    Map<String, TemplateDetail> details,
    Set<String> selected,
    bool busy,
    TemplateApplication? application,
    AppException? error,
    DateTime? blockedUntil,
  });

  $TemplateApplicationCopyWith<$Res>? get application;
}

class _$TemplateSelectionStateCopyWithImpl<
  $Res,
  $Val extends TemplateSelectionState
>
    implements $TemplateSelectionStateCopyWith<$Res> {
  _$TemplateSelectionStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templates = null,
    Object? details = null,
    Object? selected = null,
    Object? busy = null,
    Object? application = freezed,
    Object? error = freezed,
    Object? blockedUntil = freezed,
  }) {
    return _then(
      _value.copyWith(
            templates: null == templates
                ? _value.templates
                : templates as List<TemplateSummary>,
            details: null == details
                ? _value.details
                : details as Map<String, TemplateDetail>,
            selected: null == selected
                ? _value.selected
                : selected as Set<String>,
            busy: null == busy ? _value.busy : busy as bool,
            application: freezed == application
                ? _value.application
                : application as TemplateApplication?,
            error: freezed == error ? _value.error : error as AppException?,
            blockedUntil: freezed == blockedUntil
                ? _value.blockedUntil
                : blockedUntil as DateTime?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $TemplateApplicationCopyWith<$Res>? get application {
    if (_value.application == null) {
      return null;
    }

    return $TemplateApplicationCopyWith<$Res>(_value.application!, (value) {
      return _then(_value.copyWith(application: value) as $Val);
    });
  }
}

abstract class _$$TemplateSelectionStateImplCopyWith<$Res>
    implements $TemplateSelectionStateCopyWith<$Res> {
  factory _$$TemplateSelectionStateImplCopyWith(
    _$TemplateSelectionStateImpl value,
    $Res Function(_$TemplateSelectionStateImpl) then,
  ) = __$$TemplateSelectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TemplateSummary> templates,
    Map<String, TemplateDetail> details,
    Set<String> selected,
    bool busy,
    TemplateApplication? application,
    AppException? error,
    DateTime? blockedUntil,
  });

  @override
  $TemplateApplicationCopyWith<$Res>? get application;
}

class __$$TemplateSelectionStateImplCopyWithImpl<$Res>
    extends
        _$TemplateSelectionStateCopyWithImpl<$Res, _$TemplateSelectionStateImpl>
    implements _$$TemplateSelectionStateImplCopyWith<$Res> {
  __$$TemplateSelectionStateImplCopyWithImpl(
    _$TemplateSelectionStateImpl _value,
    $Res Function(_$TemplateSelectionStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templates = null,
    Object? details = null,
    Object? selected = null,
    Object? busy = null,
    Object? application = freezed,
    Object? error = freezed,
    Object? blockedUntil = freezed,
  }) {
    return _then(
      _$TemplateSelectionStateImpl(
        templates: null == templates
            ? _value._templates
            : templates as List<TemplateSummary>,
        details: null == details
            ? _value._details
            : details as Map<String, TemplateDetail>,
        selected: null == selected ? _value._selected : selected as Set<String>,
        busy: null == busy ? _value.busy : busy as bool,
        application: freezed == application
            ? _value.application
            : application as TemplateApplication?,
        error: freezed == error ? _value.error : error as AppException?,
        blockedUntil: freezed == blockedUntil
            ? _value.blockedUntil
            : blockedUntil as DateTime?,
      ),
    );
  }
}

class _$TemplateSelectionStateImpl extends _TemplateSelectionState {
  const _$TemplateSelectionStateImpl({
    required final List<TemplateSummary> templates,
    required final Map<String, TemplateDetail> details,
    final Set<String> selected = const <String>{},
    this.busy = false,
    this.application,
    this.error,
    this.blockedUntil,
  }) : _templates = templates,
       _details = details,
       _selected = selected,
       super._();

  final List<TemplateSummary> _templates;
  @override
  List<TemplateSummary> get templates {
    if (_templates is EqualUnmodifiableListView) return _templates;
    return EqualUnmodifiableListView(_templates);
  }

  final Map<String, TemplateDetail> _details;
  @override
  Map<String, TemplateDetail> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    return EqualUnmodifiableMapView(_details);
  }

  final Set<String> _selected;
  @override
  @JsonKey()
  Set<String> get selected {
    if (_selected is EqualUnmodifiableSetView) return _selected;
    return EqualUnmodifiableSetView(_selected);
  }

  @override
  @JsonKey()
  final bool busy;
  @override
  final TemplateApplication? application;
  @override
  final AppException? error;
  @override
  final DateTime? blockedUntil;

  @override
  String toString() {
    return 'TemplateSelectionState(templates: $templates, details: $details, selected: $selected, busy: $busy, application: $application, error: $error, blockedUntil: $blockedUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateSelectionStateImpl &&
            const DeepCollectionEquality().equals(
              other._templates,
              _templates,
            ) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            const DeepCollectionEquality().equals(other._selected, _selected) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.application, application) ||
                other.application == application) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.blockedUntil, blockedUntil) ||
                other.blockedUntil == blockedUntil));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_templates),
    const DeepCollectionEquality().hash(_details),
    const DeepCollectionEquality().hash(_selected),
    busy,
    application,
    error,
    blockedUntil,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateSelectionStateImplCopyWith<_$TemplateSelectionStateImpl>
  get copyWith =>
      __$$TemplateSelectionStateImplCopyWithImpl<_$TemplateSelectionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TemplateSelectionState extends TemplateSelectionState {
  const factory _TemplateSelectionState({
    required final List<TemplateSummary> templates,
    required final Map<String, TemplateDetail> details,
    final Set<String> selected,
    final bool busy,
    final TemplateApplication? application,
    final AppException? error,
    final DateTime? blockedUntil,
  }) = _$TemplateSelectionStateImpl;
  const _TemplateSelectionState._() : super._();

  @override
  List<TemplateSummary> get templates;
  @override
  Map<String, TemplateDetail> get details;
  @override
  Set<String> get selected;
  @override
  bool get busy;
  @override
  TemplateApplication? get application;
  @override
  AppException? get error;
  @override
  DateTime? get blockedUntil;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateSelectionStateImplCopyWith<_$TemplateSelectionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
