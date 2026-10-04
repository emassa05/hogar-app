part of 'catalog_entities.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

mixin _$TaskCategory {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCategoryCopyWith<TaskCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TaskCategoryCopyWith<$Res> {
  factory $TaskCategoryCopyWith(
    TaskCategory value,
    $Res Function(TaskCategory) then,
  ) = _$TaskCategoryCopyWithImpl<$Res, TaskCategory>;
  @useResult
  $Res call({String key, String name});
}

class _$TaskCategoryCopyWithImpl<$Res, $Val extends TaskCategory>
    implements $TaskCategoryCopyWith<$Res> {
  _$TaskCategoryCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            key: null == key ? _value.key : key as String,
            name: null == name ? _value.name : name as String,
          )
          as $Val,
    );
  }
}

abstract class _$$TaskCategoryImplCopyWith<$Res>
    implements $TaskCategoryCopyWith<$Res> {
  factory _$$TaskCategoryImplCopyWith(
    _$TaskCategoryImpl value,
    $Res Function(_$TaskCategoryImpl) then,
  ) = __$$TaskCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name});
}

class __$$TaskCategoryImplCopyWithImpl<$Res>
    extends _$TaskCategoryCopyWithImpl<$Res, _$TaskCategoryImpl>
    implements _$$TaskCategoryImplCopyWith<$Res> {
  __$$TaskCategoryImplCopyWithImpl(
    _$TaskCategoryImpl _value,
    $Res Function(_$TaskCategoryImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? name = null}) {
    return _then(
      _$TaskCategoryImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
      ),
    );
  }
}

class _$TaskCategoryImpl implements _TaskCategory {
  const _$TaskCategoryImpl({required this.key, required this.name});

  @override
  final String key;
  @override
  final String name;

  @override
  String toString() {
    return 'TaskCategory(key: $key, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskCategoryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, name);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskCategoryImplCopyWith<_$TaskCategoryImpl> get copyWith =>
      __$$TaskCategoryImplCopyWithImpl<_$TaskCategoryImpl>(this, _$identity);
}

abstract class _TaskCategory implements TaskCategory {
  const factory _TaskCategory({
    required final String key,
    required final String name,
  }) = _$TaskCategoryImpl;

  @override
  String get key;
  @override
  String get name;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskCategoryImplCopyWith<_$TaskCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

mixin _$Activity {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get categoryKey => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
  @useResult
  $Res call({String key, String name, String categoryKey});
}

class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? categoryKey = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key ? _value.key : key as String,
            name: null == name ? _value.name : name as String,
            categoryKey: null == categoryKey
                ? _value.categoryKey
                : categoryKey as String,
          )
          as $Val,
    );
  }
}

abstract class _$$ActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$ActivityImplCopyWith(
    _$ActivityImpl value,
    $Res Function(_$ActivityImpl) then,
  ) = __$$ActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, String categoryKey});
}

class __$$ActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$ActivityImpl>
    implements _$$ActivityImplCopyWith<$Res> {
  __$$ActivityImplCopyWithImpl(
    _$ActivityImpl _value,
    $Res Function(_$ActivityImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? categoryKey = null,
  }) {
    return _then(
      _$ActivityImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
        categoryKey: null == categoryKey
            ? _value.categoryKey
            : categoryKey as String,
      ),
    );
  }
}

class _$ActivityImpl implements _Activity {
  const _$ActivityImpl({
    required this.key,
    required this.name,
    required this.categoryKey,
  });

  @override
  final String key;
  @override
  final String name;
  @override
  final String categoryKey;

  @override
  String toString() {
    return 'Activity(key: $key, name: $name, categoryKey: $categoryKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, name, categoryKey);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      __$$ActivityImplCopyWithImpl<_$ActivityImpl>(this, _$identity);
}

abstract class _Activity implements Activity {
  const factory _Activity({
    required final String key,
    required final String name,
    required final String categoryKey,
  }) = _$ActivityImpl;

  @override
  String get key;
  @override
  String get name;
  @override
  String get categoryKey;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
