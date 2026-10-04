part of 'template_entities.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$TemplateSummary {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateSummaryCopyWith<TemplateSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateSummaryCopyWith<$Res> {
  factory $TemplateSummaryCopyWith(
    TemplateSummary value,
    $Res Function(TemplateSummary) then,
  ) = _$TemplateSummaryCopyWithImpl<$Res, TemplateSummary>;
  @useResult
  $Res call({String key, String name, String description, int taskCount});
}

class _$TemplateSummaryCopyWithImpl<$Res, $Val extends TemplateSummary>
    implements $TemplateSummaryCopyWith<$Res> {
  _$TemplateSummaryCopyWithImpl(this._value, this._then);

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

abstract class _$$TemplateSummaryImplCopyWith<$Res>
    implements $TemplateSummaryCopyWith<$Res> {
  factory _$$TemplateSummaryImplCopyWith(
    _$TemplateSummaryImpl value,
    $Res Function(_$TemplateSummaryImpl) then,
  ) = __$$TemplateSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, String description, int taskCount});
}

class __$$TemplateSummaryImplCopyWithImpl<$Res>
    extends _$TemplateSummaryCopyWithImpl<$Res, _$TemplateSummaryImpl>
    implements _$$TemplateSummaryImplCopyWith<$Res> {
  __$$TemplateSummaryImplCopyWithImpl(
    _$TemplateSummaryImpl _value,
    $Res Function(_$TemplateSummaryImpl) _then,
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
      _$TemplateSummaryImpl(
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

class _$TemplateSummaryImpl implements _TemplateSummary {
  const _$TemplateSummaryImpl({
    required this.key,
    required this.name,
    required this.description,
    required this.taskCount,
  });

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
    return 'TemplateSummary(key: $key, name: $name, description: $description, taskCount: $taskCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateSummaryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, key, name, description, taskCount);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateSummaryImplCopyWith<_$TemplateSummaryImpl> get copyWith =>
      __$$TemplateSummaryImplCopyWithImpl<_$TemplateSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _TemplateSummary implements TemplateSummary {
  const factory _TemplateSummary({
    required final String key,
    required final String name,
    required final String description,
    required final int taskCount,
  }) = _$TemplateSummaryImpl;

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
  _$$TemplateSummaryImplCopyWith<_$TemplateSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$TemplateDetail {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  List<TemplateTask> get tasks => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateDetailCopyWith<TemplateDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateDetailCopyWith<$Res> {
  factory $TemplateDetailCopyWith(
    TemplateDetail value,
    $Res Function(TemplateDetail) then,
  ) = _$TemplateDetailCopyWithImpl<$Res, TemplateDetail>;
  @useResult
  $Res call({
    String key,
    String name,
    String description,
    int taskCount,
    List<TemplateTask> tasks,
  });
}

class _$TemplateDetailCopyWithImpl<$Res, $Val extends TemplateDetail>
    implements $TemplateDetailCopyWith<$Res> {
  _$TemplateDetailCopyWithImpl(this._value, this._then);

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
            tasks: null == tasks ? _value.tasks : tasks as List<TemplateTask>,
          )
          as $Val,
    );
  }
}

abstract class _$$TemplateDetailImplCopyWith<$Res>
    implements $TemplateDetailCopyWith<$Res> {
  factory _$$TemplateDetailImplCopyWith(
    _$TemplateDetailImpl value,
    $Res Function(_$TemplateDetailImpl) then,
  ) = __$$TemplateDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    String name,
    String description,
    int taskCount,
    List<TemplateTask> tasks,
  });
}

class __$$TemplateDetailImplCopyWithImpl<$Res>
    extends _$TemplateDetailCopyWithImpl<$Res, _$TemplateDetailImpl>
    implements _$$TemplateDetailImplCopyWith<$Res> {
  __$$TemplateDetailImplCopyWithImpl(
    _$TemplateDetailImpl _value,
    $Res Function(_$TemplateDetailImpl) _then,
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
      _$TemplateDetailImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
        description: null == description
            ? _value.description
            : description as String,
        taskCount: null == taskCount ? _value.taskCount : taskCount as int,
        tasks: null == tasks ? _value._tasks : tasks as List<TemplateTask>,
      ),
    );
  }
}

class _$TemplateDetailImpl implements _TemplateDetail {
  const _$TemplateDetailImpl({
    required this.key,
    required this.name,
    required this.description,
    required this.taskCount,
    required final List<TemplateTask> tasks,
  }) : _tasks = tasks;

  @override
  final String key;
  @override
  final String name;
  @override
  final String description;
  @override
  final int taskCount;
  final List<TemplateTask> _tasks;
  @override
  List<TemplateTask> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'TemplateDetail(key: $key, name: $name, description: $description, taskCount: $taskCount, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateDetailImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

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
  _$$TemplateDetailImplCopyWith<_$TemplateDetailImpl> get copyWith =>
      __$$TemplateDetailImplCopyWithImpl<_$TemplateDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _TemplateDetail implements TemplateDetail {
  const factory _TemplateDetail({
    required final String key,
    required final String name,
    required final String description,
    required final int taskCount,
    required final List<TemplateTask> tasks,
  }) = _$TemplateDetailImpl;

  @override
  String get key;
  @override
  String get name;
  @override
  String get description;
  @override
  int get taskCount;
  @override
  List<TemplateTask> get tasks;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateDetailImplCopyWith<_$TemplateDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$TemplateTask {
  String get activityKey => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get categoryKey => throw _privateConstructorUsedError;
  String get recurrenceLabel => throw _privateConstructorUsedError;
  TaskDistribution get distribution => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  int get effort => throw _privateConstructorUsedError;
  int get mentalLoad => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateTaskCopyWith<TemplateTask> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateTaskCopyWith<$Res> {
  factory $TemplateTaskCopyWith(
    TemplateTask value,
    $Res Function(TemplateTask) then,
  ) = _$TemplateTaskCopyWithImpl<$Res, TemplateTask>;
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

class _$TemplateTaskCopyWithImpl<$Res, $Val extends TemplateTask>
    implements $TemplateTaskCopyWith<$Res> {
  _$TemplateTaskCopyWithImpl(this._value, this._then);

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

abstract class _$$TemplateTaskImplCopyWith<$Res>
    implements $TemplateTaskCopyWith<$Res> {
  factory _$$TemplateTaskImplCopyWith(
    _$TemplateTaskImpl value,
    $Res Function(_$TemplateTaskImpl) then,
  ) = __$$TemplateTaskImplCopyWithImpl<$Res>;
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

class __$$TemplateTaskImplCopyWithImpl<$Res>
    extends _$TemplateTaskCopyWithImpl<$Res, _$TemplateTaskImpl>
    implements _$$TemplateTaskImplCopyWith<$Res> {
  __$$TemplateTaskImplCopyWithImpl(
    _$TemplateTaskImpl _value,
    $Res Function(_$TemplateTaskImpl) _then,
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
      _$TemplateTaskImpl(
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

class _$TemplateTaskImpl implements _TemplateTask {
  const _$TemplateTaskImpl({
    required this.activityKey,
    required this.name,
    required this.categoryKey,
    required this.recurrenceLabel,
    required this.distribution,
    required this.estimatedDurationMinutes,
    required this.effort,
    required this.mentalLoad,
  });

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
    return 'TemplateTask(activityKey: $activityKey, name: $name, categoryKey: $categoryKey, recurrenceLabel: $recurrenceLabel, distribution: $distribution, estimatedDurationMinutes: $estimatedDurationMinutes, effort: $effort, mentalLoad: $mentalLoad)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateTaskImpl &&
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
  _$$TemplateTaskImplCopyWith<_$TemplateTaskImpl> get copyWith =>
      __$$TemplateTaskImplCopyWithImpl<_$TemplateTaskImpl>(this, _$identity);
}

abstract class _TemplateTask implements TemplateTask {
  const factory _TemplateTask({
    required final String activityKey,
    required final String name,
    required final String categoryKey,
    required final String recurrenceLabel,
    required final TaskDistribution distribution,
    required final int estimatedDurationMinutes,
    required final int effort,
    required final int mentalLoad,
  }) = _$TemplateTaskImpl;

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
  _$$TemplateTaskImplCopyWith<_$TemplateTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$TemplateApplication {
  List<String> get templateKeys => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  UserReference get appliedBy => throw _privateConstructorUsedError;
  DateTime get appliedAt => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateApplicationCopyWith<TemplateApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TemplateApplicationCopyWith<$Res> {
  factory $TemplateApplicationCopyWith(
    TemplateApplication value,
    $Res Function(TemplateApplication) then,
  ) = _$TemplateApplicationCopyWithImpl<$Res, TemplateApplication>;
  @useResult
  $Res call({
    List<String> templateKeys,
    int taskCount,
    UserReference appliedBy,
    DateTime appliedAt,
  });

  $UserReferenceCopyWith<$Res> get appliedBy;
}

class _$TemplateApplicationCopyWithImpl<$Res, $Val extends TemplateApplication>
    implements $TemplateApplicationCopyWith<$Res> {
  _$TemplateApplicationCopyWithImpl(this._value, this._then);

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
                : appliedBy as UserReference,
            appliedAt: null == appliedAt
                ? _value.appliedAt
                : appliedAt as DateTime,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $UserReferenceCopyWith<$Res> get appliedBy {
    return $UserReferenceCopyWith<$Res>(_value.appliedBy, (value) {
      return _then(_value.copyWith(appliedBy: value) as $Val);
    });
  }
}

abstract class _$$TemplateApplicationImplCopyWith<$Res>
    implements $TemplateApplicationCopyWith<$Res> {
  factory _$$TemplateApplicationImplCopyWith(
    _$TemplateApplicationImpl value,
    $Res Function(_$TemplateApplicationImpl) then,
  ) = __$$TemplateApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> templateKeys,
    int taskCount,
    UserReference appliedBy,
    DateTime appliedAt,
  });

  @override
  $UserReferenceCopyWith<$Res> get appliedBy;
}

class __$$TemplateApplicationImplCopyWithImpl<$Res>
    extends _$TemplateApplicationCopyWithImpl<$Res, _$TemplateApplicationImpl>
    implements _$$TemplateApplicationImplCopyWith<$Res> {
  __$$TemplateApplicationImplCopyWithImpl(
    _$TemplateApplicationImpl _value,
    $Res Function(_$TemplateApplicationImpl) _then,
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
      _$TemplateApplicationImpl(
        templateKeys: null == templateKeys
            ? _value._templateKeys
            : templateKeys as List<String>,
        taskCount: null == taskCount ? _value.taskCount : taskCount as int,
        appliedBy: null == appliedBy
            ? _value.appliedBy
            : appliedBy as UserReference,
        appliedAt: null == appliedAt ? _value.appliedAt : appliedAt as DateTime,
      ),
    );
  }
}

class _$TemplateApplicationImpl implements _TemplateApplication {
  const _$TemplateApplicationImpl({
    required final List<String> templateKeys,
    required this.taskCount,
    required this.appliedBy,
    required this.appliedAt,
  }) : _templateKeys = templateKeys;

  final List<String> _templateKeys;
  @override
  List<String> get templateKeys {
    if (_templateKeys is EqualUnmodifiableListView) return _templateKeys;
    return EqualUnmodifiableListView(_templateKeys);
  }

  @override
  final int taskCount;
  @override
  final UserReference appliedBy;
  @override
  final DateTime appliedAt;

  @override
  String toString() {
    return 'TemplateApplication(templateKeys: $templateKeys, taskCount: $taskCount, appliedBy: $appliedBy, appliedAt: $appliedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateApplicationImpl &&
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
  _$$TemplateApplicationImplCopyWith<_$TemplateApplicationImpl> get copyWith =>
      __$$TemplateApplicationImplCopyWithImpl<_$TemplateApplicationImpl>(
        this,
        _$identity,
      );
}

abstract class _TemplateApplication implements TemplateApplication {
  const factory _TemplateApplication({
    required final List<String> templateKeys,
    required final int taskCount,
    required final UserReference appliedBy,
    required final DateTime appliedAt,
  }) = _$TemplateApplicationImpl;

  @override
  List<String> get templateKeys;
  @override
  int get taskCount;
  @override
  UserReference get appliedBy;
  @override
  DateTime get appliedAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateApplicationImplCopyWith<_$TemplateApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$UserReference {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  AvatarChoice? get avatar => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserReferenceCopyWith<UserReference> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $UserReferenceCopyWith<$Res> {
  factory $UserReferenceCopyWith(
    UserReference value,
    $Res Function(UserReference) then,
  ) = _$UserReferenceCopyWithImpl<$Res, UserReference>;
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class _$UserReferenceCopyWithImpl<$Res, $Val extends UserReference>
    implements $UserReferenceCopyWith<$Res> {
  _$UserReferenceCopyWithImpl(this._value, this._then);

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

abstract class _$$UserReferenceImplCopyWith<$Res>
    implements $UserReferenceCopyWith<$Res> {
  factory _$$UserReferenceImplCopyWith(
    _$UserReferenceImpl value,
    $Res Function(_$UserReferenceImpl) then,
  ) = __$$UserReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String displayName,
    AvatarChoice? avatar,
    bool isActive,
  });
}

class __$$UserReferenceImplCopyWithImpl<$Res>
    extends _$UserReferenceCopyWithImpl<$Res, _$UserReferenceImpl>
    implements _$$UserReferenceImplCopyWith<$Res> {
  __$$UserReferenceImplCopyWithImpl(
    _$UserReferenceImpl _value,
    $Res Function(_$UserReferenceImpl) _then,
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
      _$UserReferenceImpl(
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

class _$UserReferenceImpl implements _UserReference {
  const _$UserReferenceImpl({
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
    return 'UserReference(userId: $userId, displayName: $displayName, avatar: $avatar, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserReferenceImpl &&
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
  _$$UserReferenceImplCopyWith<_$UserReferenceImpl> get copyWith =>
      __$$UserReferenceImplCopyWithImpl<_$UserReferenceImpl>(this, _$identity);
}

abstract class _UserReference implements UserReference {
  const factory _UserReference({
    required final String userId,
    required final String displayName,
    required final AvatarChoice? avatar,
    required final bool isActive,
  }) = _$UserReferenceImpl;

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
  _$$UserReferenceImplCopyWith<_$UserReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
