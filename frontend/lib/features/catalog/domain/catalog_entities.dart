import 'package:freezed_annotation/freezed_annotation.dart';
part 'catalog_entities.freezed.dart';

@freezed
class TaskCategory with _$TaskCategory {
  const factory TaskCategory({required String key, required String name}) =
      _TaskCategory;
}

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String key,
    required String name,
    required String categoryKey,
  }) = _Activity;
}
