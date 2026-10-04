part of 'catalog_dtos.dart';

_$TaskCategoryDtoImpl _$$TaskCategoryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TaskCategoryDtoImpl(
  key: json['key'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$$TaskCategoryDtoImplToJson(
  _$TaskCategoryDtoImpl instance,
) => <String, dynamic>{'key': instance.key, 'name': instance.name};

_$ActivityDtoImpl _$$ActivityDtoImplFromJson(Map<String, dynamic> json) =>
    _$ActivityDtoImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      categoryKey: json['category_key'] as String,
    );

Map<String, dynamic> _$$ActivityDtoImplToJson(_$ActivityDtoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'category_key': instance.categoryKey,
    };
