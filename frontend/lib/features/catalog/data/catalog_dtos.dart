import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/catalog_entities.dart';
part 'catalog_dtos.freezed.dart';
part 'catalog_dtos.g.dart';

@freezed
class TaskCategoryDto with _$TaskCategoryDto {
  const TaskCategoryDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TaskCategoryDto({required String key, required String name}) =
      _TaskCategoryDto;
  factory TaskCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$TaskCategoryDtoFromJson(json);
  TaskCategory toDomain() => TaskCategory(key: key, name: name);
}

@freezed
class ActivityDto with _$ActivityDto {
  const ActivityDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ActivityDto({
    required String key,
    required String name,
    required String categoryKey,
  }) = _ActivityDto;
  factory ActivityDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityDtoFromJson(json);
  Activity toDomain() =>
      Activity(key: key, name: name, categoryKey: categoryKey);
}
