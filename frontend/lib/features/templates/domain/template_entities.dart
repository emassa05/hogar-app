import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
part 'template_entities.freezed.dart';

enum TaskDistribution { fixed, rotating }

@freezed
class TemplateSummary with _$TemplateSummary {
  const factory TemplateSummary({
    required String key,
    required String name,
    required String description,
    required int taskCount,
  }) = _TemplateSummary;
}

@freezed
class TemplateDetail with _$TemplateDetail {
  const factory TemplateDetail({
    required String key,
    required String name,
    required String description,
    required int taskCount,
    required List<TemplateTask> tasks,
  }) = _TemplateDetail;
}

@freezed
class TemplateTask with _$TemplateTask {
  const factory TemplateTask({
    required String activityKey,
    required String name,
    required String categoryKey,
    required String recurrenceLabel,
    required TaskDistribution distribution,
    required int estimatedDurationMinutes,
    required int effort,
    required int mentalLoad,
  }) = _TemplateTask;
}

@freezed
class TemplateApplication with _$TemplateApplication {
  const factory TemplateApplication({
    required List<String> templateKeys,
    required int taskCount,
    required UserReference appliedBy,
    required DateTime appliedAt,
  }) = _TemplateApplication;
}

@freezed
class UserReference with _$UserReference {
  const factory UserReference({
    required String userId,
    required String displayName,
    required AvatarChoice? avatar,
    required bool isActive,
  }) = _UserReference;
}
