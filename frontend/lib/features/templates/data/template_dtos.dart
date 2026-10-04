import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
import '../domain/template_entities.dart';
part 'template_dtos.freezed.dart';
part 'template_dtos.g.dart';

@freezed
class TemplateSummaryDto with _$TemplateSummaryDto {
  const TemplateSummaryDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TemplateSummaryDto({
    required String key,
    required String name,
    required String description,
    required int taskCount,
  }) = _TemplateSummaryDto;
  factory TemplateSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateSummaryDtoFromJson(json);
  TemplateSummary toDomain() => TemplateSummary(
    key: key,
    name: name,
    description: description,
    taskCount: taskCount,
  );
}

@freezed
class TemplateDetailDto with _$TemplateDetailDto {
  const TemplateDetailDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TemplateDetailDto({
    required String key,
    required String name,
    required String description,
    required int taskCount,
    required List<TemplateTaskDto> tasks,
  }) = _TemplateDetailDto;
  factory TemplateDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateDetailDtoFromJson(json);
  TemplateDetail toDomain() => TemplateDetail(
    key: key,
    name: name,
    description: description,
    taskCount: taskCount,
    tasks: List.unmodifiable(tasks.map((value) => value.toDomain())),
  );
}

@freezed
class TemplateTaskDto with _$TemplateTaskDto {
  const TemplateTaskDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TemplateTaskDto({
    required String activityKey,
    required String name,
    required String categoryKey,
    required String recurrenceLabel,
    required TaskDistribution distribution,
    required int estimatedDurationMinutes,
    required int effort,
    required int mentalLoad,
  }) = _TemplateTaskDto;
  factory TemplateTaskDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateTaskDtoFromJson(json);
  TemplateTask toDomain() => TemplateTask(
    activityKey: activityKey,
    name: name,
    categoryKey: categoryKey,
    recurrenceLabel: recurrenceLabel,
    distribution: distribution,
    estimatedDurationMinutes: estimatedDurationMinutes,
    effort: effort,
    mentalLoad: mentalLoad,
  );
}

@freezed
class TemplateApplicationDto with _$TemplateApplicationDto {
  const TemplateApplicationDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TemplateApplicationDto({
    required List<String> templateKeys,
    required int taskCount,
    required UserReferenceDto appliedBy,
    required DateTime appliedAt,
  }) = _TemplateApplicationDto;
  factory TemplateApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateApplicationDtoFromJson(json);
  TemplateApplication toDomain() => TemplateApplication(
    templateKeys: List.unmodifiable(templateKeys),
    taskCount: taskCount,
    appliedBy: appliedBy.toDomain(),
    appliedAt: appliedAt,
  );
}

@freezed
class UserReferenceDto with _$UserReferenceDto {
  const UserReferenceDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserReferenceDto({
    required String userId,
    required String displayName,
    required AvatarChoice? avatar,
    required bool isActive,
  }) = _UserReferenceDto;
  factory UserReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$UserReferenceDtoFromJson(json);
  UserReference toDomain() => UserReference(
    userId: userId,
    displayName: displayName,
    avatar: avatar,
    isActive: isActive,
  );
}
