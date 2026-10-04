part of 'template_dtos.dart';

_$TemplateSummaryDtoImpl _$$TemplateSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TemplateSummaryDtoImpl(
  key: json['key'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  taskCount: (json['task_count'] as num).toInt(),
);

Map<String, dynamic> _$$TemplateSummaryDtoImplToJson(
  _$TemplateSummaryDtoImpl instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'description': instance.description,
  'task_count': instance.taskCount,
};

_$TemplateDetailDtoImpl _$$TemplateDetailDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TemplateDetailDtoImpl(
  key: json['key'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  taskCount: (json['task_count'] as num).toInt(),
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => TemplateTaskDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$TemplateDetailDtoImplToJson(
  _$TemplateDetailDtoImpl instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'description': instance.description,
  'task_count': instance.taskCount,
  'tasks': instance.tasks,
};

_$TemplateTaskDtoImpl _$$TemplateTaskDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TemplateTaskDtoImpl(
  activityKey: json['activity_key'] as String,
  name: json['name'] as String,
  categoryKey: json['category_key'] as String,
  recurrenceLabel: json['recurrence_label'] as String,
  distribution: $enumDecode(_$TaskDistributionEnumMap, json['distribution']),
  estimatedDurationMinutes: (json['estimated_duration_minutes'] as num).toInt(),
  effort: (json['effort'] as num).toInt(),
  mentalLoad: (json['mental_load'] as num).toInt(),
);

Map<String, dynamic> _$$TemplateTaskDtoImplToJson(
  _$TemplateTaskDtoImpl instance,
) => <String, dynamic>{
  'activity_key': instance.activityKey,
  'name': instance.name,
  'category_key': instance.categoryKey,
  'recurrence_label': instance.recurrenceLabel,
  'distribution': _$TaskDistributionEnumMap[instance.distribution]!,
  'estimated_duration_minutes': instance.estimatedDurationMinutes,
  'effort': instance.effort,
  'mental_load': instance.mentalLoad,
};

const _$TaskDistributionEnumMap = {
  TaskDistribution.fixed: 'fixed',
  TaskDistribution.rotating: 'rotating',
};

_$TemplateApplicationDtoImpl _$$TemplateApplicationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TemplateApplicationDtoImpl(
  templateKeys: (json['template_keys'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  taskCount: (json['task_count'] as num).toInt(),
  appliedBy: UserReferenceDto.fromJson(
    json['applied_by'] as Map<String, dynamic>,
  ),
  appliedAt: DateTime.parse(json['applied_at'] as String),
);

Map<String, dynamic> _$$TemplateApplicationDtoImplToJson(
  _$TemplateApplicationDtoImpl instance,
) => <String, dynamic>{
  'template_keys': instance.templateKeys,
  'task_count': instance.taskCount,
  'applied_by': instance.appliedBy,
  'applied_at': instance.appliedAt.toIso8601String(),
};

_$UserReferenceDtoImpl _$$UserReferenceDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UserReferenceDtoImpl(
  userId: json['user_id'] as String,
  displayName: json['display_name'] as String,
  avatar: $enumDecodeNullable(_$AvatarChoiceEnumMap, json['avatar']),
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$$UserReferenceDtoImplToJson(
  _$UserReferenceDtoImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'display_name': instance.displayName,
  'avatar': _$AvatarChoiceEnumMap[instance.avatar],
  'is_active': instance.isActive,
};

const _$AvatarChoiceEnumMap = {
  AvatarChoice.indigo: 'indigo',
  AvatarChoice.green: 'green',
  AvatarChoice.peach: 'peach',
  AvatarChoice.yellow: 'yellow',
  AvatarChoice.sky: 'sky',
  AvatarChoice.pink: 'pink',
};
