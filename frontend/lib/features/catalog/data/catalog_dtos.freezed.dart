part of 'catalog_dtos.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskCategoryDto _$TaskCategoryDtoFromJson(Map<String, dynamic> json) {
  return _TaskCategoryDto.fromJson(json);
}

mixin _$TaskCategoryDto {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCategoryDtoCopyWith<TaskCategoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TaskCategoryDtoCopyWith<$Res> {
  factory $TaskCategoryDtoCopyWith(
    TaskCategoryDto value,
    $Res Function(TaskCategoryDto) then,
  ) = _$TaskCategoryDtoCopyWithImpl<$Res, TaskCategoryDto>;
  @useResult
  $Res call({String key, String name});
}

class _$TaskCategoryDtoCopyWithImpl<$Res, $Val extends TaskCategoryDto>
    implements $TaskCategoryDtoCopyWith<$Res> {
  _$TaskCategoryDtoCopyWithImpl(this._value, this._then);

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

abstract class _$$TaskCategoryDtoImplCopyWith<$Res>
    implements $TaskCategoryDtoCopyWith<$Res> {
  factory _$$TaskCategoryDtoImplCopyWith(
    _$TaskCategoryDtoImpl value,
    $Res Function(_$TaskCategoryDtoImpl) then,
  ) = __$$TaskCategoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name});
}

class __$$TaskCategoryDtoImplCopyWithImpl<$Res>
    extends _$TaskCategoryDtoCopyWithImpl<$Res, _$TaskCategoryDtoImpl>
    implements _$$TaskCategoryDtoImplCopyWith<$Res> {
  __$$TaskCategoryDtoImplCopyWithImpl(
    _$TaskCategoryDtoImpl _value,
    $Res Function(_$TaskCategoryDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? name = null}) {
    return _then(
      _$TaskCategoryDtoImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TaskCategoryDtoImpl extends _TaskCategoryDto {
  const _$TaskCategoryDtoImpl({required this.key, required this.name})
    : super._();

  factory _$TaskCategoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskCategoryDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String name;

  @override
  String toString() {
    return 'TaskCategoryDto(key: $key, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskCategoryDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, name);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskCategoryDtoImplCopyWith<_$TaskCategoryDtoImpl> get copyWith =>
      __$$TaskCategoryDtoImplCopyWithImpl<_$TaskCategoryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskCategoryDtoImplToJson(this);
  }
}

abstract class _TaskCategoryDto extends TaskCategoryDto {
  const factory _TaskCategoryDto({
    required final String key,
    required final String name,
  }) = _$TaskCategoryDtoImpl;
  const _TaskCategoryDto._() : super._();

  factory _TaskCategoryDto.fromJson(Map<String, dynamic> json) =
      _$TaskCategoryDtoImpl.fromJson;

  @override
  String get key;
  @override
  String get name;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskCategoryDtoImplCopyWith<_$TaskCategoryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityDto _$ActivityDtoFromJson(Map<String, dynamic> json) {
  return _ActivityDto.fromJson(json);
}

mixin _$ActivityDto {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get categoryKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityDtoCopyWith<ActivityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ActivityDtoCopyWith<$Res> {
  factory $ActivityDtoCopyWith(
    ActivityDto value,
    $Res Function(ActivityDto) then,
  ) = _$ActivityDtoCopyWithImpl<$Res, ActivityDto>;
  @useResult
  $Res call({String key, String name, String categoryKey});
}

class _$ActivityDtoCopyWithImpl<$Res, $Val extends ActivityDto>
    implements $ActivityDtoCopyWith<$Res> {
  _$ActivityDtoCopyWithImpl(this._value, this._then);

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

abstract class _$$ActivityDtoImplCopyWith<$Res>
    implements $ActivityDtoCopyWith<$Res> {
  factory _$$ActivityDtoImplCopyWith(
    _$ActivityDtoImpl value,
    $Res Function(_$ActivityDtoImpl) then,
  ) = __$$ActivityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, String categoryKey});
}

class __$$ActivityDtoImplCopyWithImpl<$Res>
    extends _$ActivityDtoCopyWithImpl<$Res, _$ActivityDtoImpl>
    implements _$$ActivityDtoImplCopyWith<$Res> {
  __$$ActivityDtoImplCopyWithImpl(
    _$ActivityDtoImpl _value,
    $Res Function(_$ActivityDtoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? categoryKey = null,
  }) {
    return _then(
      _$ActivityDtoImpl(
        key: null == key ? _value.key : key as String,
        name: null == name ? _value.name : name as String,
        categoryKey: null == categoryKey
            ? _value.categoryKey
            : categoryKey as String,
      ),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ActivityDtoImpl extends _ActivityDto {
  const _$ActivityDtoImpl({
    required this.key,
    required this.name,
    required this.categoryKey,
  }) : super._();

  factory _$ActivityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final String categoryKey;

  @override
  String toString() {
    return 'ActivityDto(key: $key, name: $name, categoryKey: $categoryKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, name, categoryKey);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityDtoImplCopyWith<_$ActivityDtoImpl> get copyWith =>
      __$$ActivityDtoImplCopyWithImpl<_$ActivityDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityDtoImplToJson(this);
  }
}

abstract class _ActivityDto extends ActivityDto {
  const factory _ActivityDto({
    required final String key,
    required final String name,
    required final String categoryKey,
  }) = _$ActivityDtoImpl;
  const _ActivityDto._() : super._();

  factory _ActivityDto.fromJson(Map<String, dynamic> json) =
      _$ActivityDtoImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  String get categoryKey;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityDtoImplCopyWith<_$ActivityDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
