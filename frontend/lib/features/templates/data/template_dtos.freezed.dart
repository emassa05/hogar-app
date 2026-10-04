part of 'template_dtos.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TemplateSummaryDto _$TemplateSummaryDtoFromJson(Map<String, dynamic> json) {
  return _TemplateSummaryDto.fromJson(json);
}

mixin _$TemplateSummaryDto {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateSummaryDtoCopyWith<TemplateSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateSummaryDtoCopyWith<$Res> {
  factory $TemplateSummaryDtoCopyWith(
    TemplateSummaryDto value,
    $Res Function(TemplateSummaryDto) then,
  ) = _$TemplateSummaryDtoCopyWithImpl<$Res, TemplateSummaryDto>;
  @useResult
  $Res call({String key, String name, String description, int taskCount});
}

class _$TemplateSummaryDtoCopyWithImpl<$Res, $Val extends TemplateSummaryDto>
    implements $TemplateSummaryDtoCopyWith<$Res> {
  _$TemplateSummaryDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? description = null,
    Object? taskCount = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key ? _value.key : key as String,
            name: null == name ? _value.name : name as String,
            description: null == description
                ? _value.description
                : description as String,
            taskCount: null == taskCount ? _value.taskCount : taskCount as int,
          )
          as $Val,
    );
  }
}

abstract class _$$TemplateSummaryDtoImplCopyWith<$Res>
    implements $TemplateSummaryDtoCopyWith<$Res> {
  factory _$$TemplateSummaryDtoImplCopyWith(
    _$TemplateSummaryDtoImpl value,
    $Res Function(_$TemplateSummaryDtoImpl) then,
  ) = __$$TemplateSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, String description, int taskCount});
}

class __$$TemplateSummaryDtoImplCopyWithImpl<$Res>
    extends _$TemplateSummaryDtoCopyWithImpl<$Res, _$TemplateSummaryDtoImpl>
    implements _$$TemplateSummaryDtoImplCopyWith<$Res> {
  __$$TemplateSummaryDtoImplCopyWithImpl(
    _$TemplateSummaryDtoImpl _value,
    $Res Function(_$TemplateSummaryDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? description = null,
    Object? taskCount = null,
  }) {
    return _then(
      _$TemplateSummaryDtoImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
        description: null == description
            ? _value.description
            : description as String,
        taskCount: null == taskCount ? _value.taskCount : taskCount as int,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TemplateSummaryDtoImpl extends _TemplateSummaryDto {
  const _$TemplateSummaryDtoImpl({
    required this.key,
    required this.name,
    required this.description,
    required this.taskCount,
  }) : super._();

  factory _$TemplateSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateSummaryDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final String description;
  @override
  final int taskCount;

  @override
  String toString() {
    return 'TemplateSummaryDto(key: $key, name: $name, description: $description, taskCount: $taskCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateSummaryDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, name, description, taskCount);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateSummaryDtoImplCopyWith<_$TemplateSummaryDtoImpl> get copyWith =>
      __$$TemplateSummaryDtoImplCopyWithImpl<_$TemplateSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateSummaryDtoImplToJson(this);
  }
}

abstract class _TemplateSummaryDto extends TemplateSummaryDto {
  const factory _TemplateSummaryDto({
    required final String key,
    required final String name,
    required final String description,
    required final int taskCount,
  }) = _$TemplateSummaryDtoImpl;
  const _TemplateSummaryDto._() : super._();

  factory _TemplateSummaryDto.fromJson(Map<String, dynamic> json) =
      _$TemplateSummaryDtoImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  String get description;
  @override
  int get taskCount;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateSummaryDtoImplCopyWith<_$TemplateSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateDetailDto _$TemplateDetailDtoFromJson(Map<String, dynamic> json) {
  return _TemplateDetailDto.fromJson(json);
}

mixin _$TemplateDetailDto {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  List<TemplateTaskDto> get tasks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateDetailDtoCopyWith<TemplateDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateDetailDtoCopyWith<$Res> {
  factory $TemplateDetailDtoCopyWith(
    TemplateDetailDto value,
    $Res Function(TemplateDetailDto) then,
  ) = _$TemplateDetailDtoCopyWithImpl<$Res, TemplateDetailDto>;
  @useResult
  $Res call({
    String key,
    String name,
    String description,
    int taskCount,
    List<TemplateTaskDto> tasks,
  });
}

class _$TemplateDetailDtoCopyWithImpl<$Res, $Val extends TemplateDetailDto>
    implements $TemplateDetailDtoCopyWith<$Res> {
  _$TemplateDetailDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? description = null,
    Object? taskCount = null,
    Object? tasks = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key ? _value.key : key as String,
            name: null == name ? _value.name : name as String,
            description: null == description
                ? _value.description
                : description as String,
            taskCount: null == taskCount ? _value.taskCount : taskCount as int,
            tasks: null == tasks
                ? _value.tasks
                : tasks as List<TemplateTaskDto>,
          )
          as $Val,
    );
  }
}

abstract class _$$TemplateDetailDtoImplCopyWith<$Res>
    implements $TemplateDetailDtoCopyWith<$Res> {
  factory _$$TemplateDetailDtoImplCopyWith(
    _$TemplateDetailDtoImpl value,
    $Res Function(_$TemplateDetailDtoImpl) then,
  ) = __$$TemplateDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    String name,
    String description,
    int taskCount,
    List<TemplateTaskDto> tasks,
  });
}

class __$$TemplateDetailDtoImplCopyWithImpl<$Res>
    extends _$TemplateDetailDtoCopyWithImpl<$Res, _$TemplateDetailDtoImpl>
    implements _$$TemplateDetailDtoImplCopyWith<$Res> {
  __$$TemplateDetailDtoImplCopyWithImpl(
    _$TemplateDetailDtoImpl _value,
    $Res Function(_$TemplateDetailDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? description = null,
    Object? taskCount = null,
    Object? tasks = null,
  }) {
    return _then(
      _$TemplateDetailDtoImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
        description: null == description
            ? _value.description
            : description as String,
        taskCount: null == taskCount ? _value.taskCount : taskCount as int,
        tasks: null == tasks ? _value._tasks : tasks as List<TemplateTaskDto>,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TemplateDetailDtoImpl extends _TemplateDetailDto {
  const _$TemplateDetailDtoImpl({
    required this.key,
    required this.name,
    required this.description,
    required this.taskCount,
    required final List<TemplateTaskDto> tasks,
  }) : _tasks = tasks,
       super._();

  factory _$TemplateDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateDetailDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final String description;
  @override
  final int taskCount;
  final List<TemplateTaskDto> _tasks;
  @override
  List<TemplateTaskDto> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'TemplateDetailDto(key: $key, name: $name, description: $description, taskCount: $taskCount, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateDetailDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    key,
    name,
    description,
    taskCount,
    const DeepCollectionEquality().hash(_tasks),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateDetailDtoImplCopyWith<_$TemplateDetailDtoImpl> get copyWith =>
      __$$TemplateDetailDtoImplCopyWithImpl<_$TemplateDetailDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateDetailDtoImplToJson(this);
  }
}

abstract class _TemplateDetailDto extends TemplateDetailDto {
  const factory _TemplateDetailDto({
    required final String key,
    required final String name,
    required final String description,
    required final int taskCount,
    required final List<TemplateTaskDto> tasks,
  }) = _$TemplateDetailDtoImpl;
  const _TemplateDetailDto._() : super._();

  factory _TemplateDetailDto.fromJson(Map<String, dynamic> json) =
      _$TemplateDetailDtoImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  String get description;
  @override
  int get taskCount;
  @override
  List<TemplateTaskDto> get tasks;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateDetailDtoImplCopyWith<_$TemplateDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateTaskDto _$TemplateTaskDtoFromJson(Map<String, dynamic> json) {
  return _TemplateTaskDto.fromJson(json);
}

mixin _$TemplateTaskDto {
  String get activityKey => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get categoryKey => throw _privateConstructorUsedError;
  String get recurrenceLabel => throw _privateConstructorUsedError;
  TaskDistribution get distribution => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  int get effort => throw _privateConstructorUsedError;
  int get mentalLoad => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateTaskDtoCopyWith<TemplateTaskDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateTaskDtoCopyWith<$Res> {
  factory $TemplateTaskDtoCopyWith(
    TemplateTaskDto value,
    $Res Function(TemplateTaskDto) then,
  ) = _$TemplateTaskDtoCopyWithImpl<$Res, TemplateTaskDto>;
  @useResult
  $Res call({
    String activityKey,
    String name,
    String categoryKey,
    String recurrenceLabel,
    TaskDistribution distribution,
    int estimatedDurationMinutes,
    int effort,
    int mentalLoad,
  });
}

class _$TemplateTaskDtoCopyWithImpl<$Res, $Val extends TemplateTaskDto>
    implements $TemplateTaskDtoCopyWith<$Res> {
  _$TemplateTaskDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityKey = null,
    Object? name = null,
    Object? categoryKey = null,
    Object? recurrenceLabel = null,
    Object? distribution = null,
    Object? estimatedDurationMinutes = null,
    Object? effort = null,
    Object? mentalLoad = null,
  }) {
    return _then(
      _value.copyWith(
            activityKey: null == activityKey
                ? _value.activityKey
                : activityKey as String,
            name: null == name ? _value.name : name as String,
            categoryKey: null == categoryKey
                ? _value.categoryKey
                : categoryKey as String,
            recurrenceLabel: null == recurrenceLabel
                ? _value.recurrenceLabel
                : recurrenceLabel as String,
            distribution: null == distribution
                ? _value.distribution
                : distribution as TaskDistribution,
            estimatedDurationMinutes: null == estimatedDurationMinutes
                ? _value.estimatedDurationMinutes
                : estimatedDurationMinutes as int,
            effort: null == effort ? _value.effort : effort as int,
            mentalLoad: null == mentalLoad
                ? _value.mentalLoad
                : mentalLoad as int,
          )
          as $Val,
    );
  }
}

abstract class _$$TemplateTaskDtoImplCopyWith<$Res>
    implements $TemplateTaskDtoCopyWith<$Res> {
  factory _$$TemplateTaskDtoImplCopyWith(
    _$TemplateTaskDtoImpl value,
    $Res Function(_$TemplateTaskDtoImpl) then,
  ) = __$$TemplateTaskDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String activityKey,
    String name,
    String categoryKey,
    String recurrenceLabel,
    TaskDistribution distribution,
    int estimatedDurationMinutes,
    int effort,
    int mentalLoad,
  });
}

class __$$TemplateTaskDtoImplCopyWithImpl<$Res>
    extends _$TemplateTaskDtoCopyWithImpl<$Res, _$TemplateTaskDtoImpl>
    implements _$$TemplateTaskDtoImplCopyWith<$Res> {
  __$$TemplateTaskDtoImplCopyWithImpl(
    _$TemplateTaskDtoImpl _value,
    $Res Function(_$TemplateTaskDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityKey = null,
    Object? name = null,
    Object? categoryKey = null,
    Object? recurrenceLabel = null,
    Object? distribution = null,
    Object? estimatedDurationMinutes = null,
    Object? effort = null,
    Object? mentalLoad = null,
  }) {
    return _then(
      _$TemplateTaskDtoImpl(
        activityKey: null == activityKey
            ? _value.activityKey
            : activityKey as String,
        name: null == name ? _value.name : name as String,
        categoryKey: null == categoryKey
            ? _value.categoryKey
            : categoryKey as String,
        recurrenceLabel: null == recurrenceLabel
            ? _value.recurrenceLabel
            : recurrenceLabel as String,
        distribution: null == distribution
            ? _value.distribution
            : distribution as TaskDistribution,
        estimatedDurationMinutes: null == estimatedDurationMinutes
            ? _value.estimatedDurationMinutes
            : estimatedDurationMinutes as int,
        effort: null == effort ? _value.effort : effort as int,
        mentalLoad: null == mentalLoad ? _value.mentalLoad : mentalLoad as int,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TemplateTaskDtoImpl extends _TemplateTaskDto {
  const _$TemplateTaskDtoImpl({
    required this.activityKey,
    required this.name,
    required this.categoryKey,
    required this.recurrenceLabel,
    required this.distribution,
    required this.estimatedDurationMinutes,
    required this.effort,
    required this.mentalLoad,
  }) : super._();

  factory _$TemplateTaskDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateTaskDtoImplFromJson(json);

  @override
  final String activityKey;
  @override
  final String name;
  @override
  final String categoryKey;
  @override
  final String recurrenceLabel;
  @override
  final TaskDistribution distribution;
  @override
  final int estimatedDurationMinutes;
  @override
  final int effort;
  @override
  final int mentalLoad;

  @override
  String toString() {
    return 'TemplateTaskDto(activityKey: $activityKey, name: $name, categoryKey: $categoryKey, recurrenceLabel: $recurrenceLabel, distribution: $distribution, estimatedDurationMinutes: $estimatedDurationMinutes, effort: $effort, mentalLoad: $mentalLoad)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateTaskDtoImpl &&
            (identical(other.activityKey, activityKey) ||
                other.activityKey == activityKey) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey) &&
            (identical(other.recurrenceLabel, recurrenceLabel) ||
                other.recurrenceLabel == recurrenceLabel) &&
            (identical(other.distribution, distribution) ||
                other.distribution == distribution) &&
            (identical(
                  other.estimatedDurationMinutes,
                  estimatedDurationMinutes,
                ) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.effort, effort) || other.effort == effort) &&
            (identical(other.mentalLoad, mentalLoad) ||
                other.mentalLoad == mentalLoad));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activityKey,
    name,
    categoryKey,
    recurrenceLabel,
    distribution,
    estimatedDurationMinutes,
    effort,
    mentalLoad,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateTaskDtoImplCopyWith<_$TemplateTaskDtoImpl> get copyWith =>
      __$$TemplateTaskDtoImplCopyWithImpl<_$TemplateTaskDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateTaskDtoImplToJson(this);
  }
}

abstract class _TemplateTaskDto extends TemplateTaskDto {
  const factory _TemplateTaskDto({
    required final String activityKey,
    required final String name,
    required final String categoryKey,
    required final String recurrenceLabel,
    required final TaskDistribution distribution,
    required final int estimatedDurationMinutes,
    required final int effort,
    required final int mentalLoad,
  }) = _$TemplateTaskDtoImpl;
  const _TemplateTaskDto._() : super._();

  factory _TemplateTaskDto.fromJson(Map<String, dynamic> json) =
      _$TemplateTaskDtoImpl.fromJson;

  @override
  String get activityKey;
  @override
  String get name;
  @override
  String get categoryKey;
  @override
  String get recurrenceLabel;
  @override
  TaskDistribution get distribution;
  @override
  int get estimatedDurationMinutes;
  @override
  int get effort;
  @override
  int get mentalLoad;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateTaskDtoImplCopyWith<_$TemplateTaskDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateApplicationDto _$TemplateApplicationDtoFromJson(
  Map<String, dynamic> json,
) {
  return _TemplateApplicationDto.fromJson(json);
}

mixin _$TemplateApplicationDto {
  List<String> get templateKeys => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  UserReferenceDto get appliedBy => throw _privateConstructorUsedError;
  DateTime get appliedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateApplicationDtoCopyWith<TemplateApplicationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateApplicationDtoCopyWith<$Res> {
  factory $TemplateApplicationDtoCopyWith(
    TemplateApplicationDto value,
    $Res Function(TemplateApplicationDto) then,
  ) = _$TemplateApplicationDtoCopyWithImpl<$Res, TemplateApplicationDto>;
  @useResult
  $Res call({
    List<String> templateKeys,
    int taskCount,
    UserReferenceDto appliedBy,
    DateTime appliedAt,
  });

  $UserReferenceDtoCopyWith<$Res> get appliedBy;
}

class _$TemplateApplicationDtoCopyWithImpl<
  $Res,
  $Val extends TemplateApplicationDto
>
    implements $TemplateApplicationDtoCopyWith<$Res> {
  _$TemplateApplicationDtoCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateKeys = null,
    Object? taskCount = null,
    Object? appliedBy = null,
    Object? appliedAt = null,
  }) {
    return _then(
      _value.copyWith(
            templateKeys: null == templateKeys
                ? _value.templateKeys
                : templateKeys as List<String>,
            taskCount: null == taskCount ? _value.taskCount : taskCount as int,
            appliedBy: null == appliedBy
                ? _value.appliedBy
                : appliedBy as UserReferenceDto,
            appliedAt: null == appliedAt
                ? _value.appliedAt
                : appliedAt as DateTime,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $UserReferenceDtoCopyWith<$Res> get appliedBy {
    return $UserReferenceDtoCopyWith<$Res>(_value.appliedBy, (value) {
      return _then(_value.copyWith(appliedBy: value) as $Val);
    });
  }
}

abstract class _$$TemplateApplicationDtoImplCopyWith<$Res>
    implements $TemplateApplicationDtoCopyWith<$Res> {
  factory _$$TemplateApplicationDtoImplCopyWith(
    _$TemplateApplicationDtoImpl value,
    $Res Function(_$TemplateApplicationDtoImpl) then,
  ) = __$$TemplateApplicationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> templateKeys,
    int taskCount,
    UserReferenceDto appliedBy,
    DateTime appliedAt,
  });

  @override
  $UserReferenceDtoCopyWith<$Res> get appliedBy;
}

class __$$TemplateApplicationDtoImplCopyWithImpl<$Res>
    extends
        _$TemplateApplicationDtoCopyWithImpl<$Res, _$TemplateApplicationDtoImpl>
    implements _$$TemplateApplicationDtoImplCopyWith<$Res> {
  __$$TemplateApplicationDtoImplCopyWithImpl(
    _$TemplateApplicationDtoImpl _value,
    $Res Function(_$TemplateApplicationDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateKeys = null,
    Object? taskCount = null,
    Object? appliedBy = null,
    Object? appliedAt = null,
  }) {
    return _then(
      _$TemplateApplicationDtoImpl(
        templateKeys: null == templateKeys
            ? _value._templateKeys
            : templateKeys as List<String>,
        taskCount: null == taskCount ? _value.taskCount : taskCount as int,
        appliedBy: null == appliedBy
            ? _value.appliedBy
            : appliedBy as UserReferenceDto,
        appliedAt: null == appliedAt ? _value.appliedAt : appliedAt as DateTime,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TemplateApplicationDtoImpl extends _TemplateApplicationDto {
  const _$TemplateApplicationDtoImpl({
    required final List<String> templateKeys,
    required this.taskCount,
    required this.appliedBy,
    required this.appliedAt,
  }) : _templateKeys = templateKeys,
       super._();

  factory _$TemplateApplicationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateApplicationDtoImplFromJson(json);

  final List<String> _templateKeys;
  @override
  List<String> get templateKeys {
    if (_templateKeys is EqualUnmodifiableListView) return _templateKeys;
    return EqualUnmodifiableListView(_templateKeys);
  }

  @override
  final int taskCount;
  @override
  final UserReferenceDto appliedBy;
  @override
  final DateTime appliedAt;

  @override
  String toString() {
    return 'TemplateApplicationDto(templateKeys: $templateKeys, taskCount: $taskCount, appliedBy: $appliedBy, appliedAt: $appliedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateApplicationDtoImpl &&
            const DeepCollectionEquality().equals(
              other._templateKeys,
              _templateKeys,
            ) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount) &&
            (identical(other.appliedBy, appliedBy) ||
                other.appliedBy == appliedBy) &&
            (identical(other.appliedAt, appliedAt) ||
                other.appliedAt == appliedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_templateKeys),
    taskCount,
    appliedBy,
    appliedAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateApplicationDtoImplCopyWith<_$TemplateApplicationDtoImpl>
  get copyWith =>
      __$$TemplateApplicationDtoImplCopyWithImpl<_$TemplateApplicationDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateApplicationDtoImplToJson(this);
  }
}

abstract class _TemplateApplicationDto extends TemplateApplicationDto {
  const factory _TemplateApplicationDto({
    required final List<String> templateKeys,
    required final int taskCount,
    required final UserReferenceDto appliedBy,
    required final DateTime appliedAt,
  }) = _$TemplateApplicationDtoImpl;
  const _TemplateApplicationDto._() : super._();

  factory _TemplateApplicationDto.fromJson(Map<String, dynamic> json) =
      _$TemplateApplicationDtoImpl.fromJson;

  @override
  List<String> get templateKeys;
  @override
  int get taskCount;
  @override
  UserReferenceDto get appliedBy;
  @override
  DateTime get appliedAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateApplicationDtoImplCopyWith<_$TemplateApplicationDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserReferenceDto _$UserReferenceDtoFromJson(Map<String, dynamic> json) {
  return _UserReferenceDto.fromJson(json);
}

mixin _$UserReferenceDto {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserReferenceDtoCopyWith<UserReferenceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $UserReferenceDtoCopyWith<$Res> {
  factory $UserReferenceDtoCopyWith(
    UserReferenceDto value,
    $Res Function(UserReferenceDto) then,
  ) = _$UserReferenceDtoCopyWithImpl<$Res, UserReferenceDto>;
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class _$UserReferenceDtoCopyWithImpl<$Res, $Val extends UserReferenceDto>
    implements $UserReferenceDtoCopyWith<$Res> {
  _$UserReferenceDtoCopyWithImpl(this._value, this._then);

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

abstract class _$$UserReferenceDtoImplCopyWith<$Res>
    implements $UserReferenceDtoCopyWith<$Res> {
  factory _$$UserReferenceDtoImplCopyWith(
    _$UserReferenceDtoImpl value,
    $Res Function(_$UserReferenceDtoImpl) then,
  ) = __$$UserReferenceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class __$$UserReferenceDtoImplCopyWithImpl<$Res>
    extends _$UserReferenceDtoCopyWithImpl<$Res, _$UserReferenceDtoImpl>
    implements _$$UserReferenceDtoImplCopyWith<$Res> {
  __$$UserReferenceDtoImplCopyWithImpl(
    _$UserReferenceDtoImpl _value,
    $Res Function(_$UserReferenceDtoImpl) _then,
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
      _$UserReferenceDtoImpl(
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

@JsonSerializable(fieldRename: FieldRename.snake)
class _$UserReferenceDtoImpl extends _UserReferenceDto {
  const _$UserReferenceDtoImpl({
    required this.userId,
    required this.displayName,
    required this.avatar,
    required this.isActive,
  }) : super._();

  factory _$UserReferenceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserReferenceDtoImplFromJson(json);

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
    return 'UserReferenceDto(userId: $userId, displayName: $displayName, avatar: $avatar, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserReferenceDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, displayName, avatar, isActive);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserReferenceDtoImplCopyWith<_$UserReferenceDtoImpl> get copyWith =>
      __$$UserReferenceDtoImplCopyWithImpl<_$UserReferenceDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserReferenceDtoImplToJson(this);
  }
}

abstract class _UserReferenceDto extends UserReferenceDto {
  const factory _UserReferenceDto({
    required final String userId,
    required final String displayName,
    required final AvatarChoice? avatar,
    required final bool isActive,
  }) = _$UserReferenceDtoImpl;
  const _UserReferenceDto._() : super._();

  factory _UserReferenceDto.fromJson(Map<String, dynamic> json) =
      _$UserReferenceDtoImpl.fromJson;

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
  _$$UserReferenceDtoImplCopyWith<_$UserReferenceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
