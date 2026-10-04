part of 'profile_dtos.dart';

_$MemberProfileDtoImpl _$$MemberProfileDtoImplFromJson(
  Map<String, dynamic> json,
) => _$MemberProfileDtoImpl(
  userId: json['user_id'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String?,
  avatar: $enumDecodeNullable(_$AvatarChoiceEnumMap, json['avatar']),
  role: $enumDecode(_$MemberRoleEnumMap, json['role']),
  isMe: json['is_me'] as bool,
  proposedCapacityPercent: (json['proposed_capacity_percent'] as num?)?.toInt(),
  approvedCapacityPercent: (json['approved_capacity_percent'] as num?)?.toInt(),
  availability: AvailabilityDto.fromJson(
    json['availability'] as Map<String, dynamic>,
  ),
  restrictions: (json['restrictions'] as List<dynamic>)
      .map((e) => RestrictionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  preferences: PreferencesDto.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$MemberProfileDtoImplToJson(
  _$MemberProfileDtoImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'name': instance.name,
  'nickname': instance.nickname,
  'avatar': _$AvatarChoiceEnumMap[instance.avatar],
  'role': _$MemberRoleEnumMap[instance.role]!,
  'is_me': instance.isMe,
  'proposed_capacity_percent': instance.proposedCapacityPercent,
  'approved_capacity_percent': instance.approvedCapacityPercent,
  'availability': instance.availability,
  'restrictions': instance.restrictions,
  'preferences': instance.preferences,
};

const _$AvatarChoiceEnumMap = {
  AvatarChoice.indigo: 'indigo',
  AvatarChoice.green: 'green',
  AvatarChoice.peach: 'peach',
  AvatarChoice.yellow: 'yellow',
  AvatarChoice.sky: 'sky',
  AvatarChoice.pink: 'pink',
};

const _$MemberRoleEnumMap = {
  MemberRole.admin: 'admin',
  MemberRole.member: 'member',
};

_$AvailabilityDtoImpl _$$AvailabilityDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AvailabilityDtoImpl(
  slots: (json['slots'] as List<dynamic>)
      .map((e) => AvailabilitySlotDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  exceptions: (json['exceptions'] as List<dynamic>)
      .map((e) => AvailabilityExceptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AvailabilityDtoImplToJson(
  _$AvailabilityDtoImpl instance,
) => <String, dynamic>{
  'slots': instance.slots,
  'exceptions': instance.exceptions,
};

_$AvailabilitySlotDtoImpl _$$AvailabilitySlotDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AvailabilitySlotDtoImpl(
  weekday: (json['weekday'] as num).toInt(),
  period: $enumDecode(_$DayPeriodEnumMap, json['period']),
);

Map<String, dynamic> _$$AvailabilitySlotDtoImplToJson(
  _$AvailabilitySlotDtoImpl instance,
) => <String, dynamic>{
  'weekday': instance.weekday,
  'period': _$DayPeriodEnumMap[instance.period]!,
};

const _$DayPeriodEnumMap = {
  DayPeriod.morning: 'morning',
  DayPeriod.afternoon: 'afternoon',
  DayPeriod.evening: 'evening',
};

_$AvailabilityExceptionDtoImpl _$$AvailabilityExceptionDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AvailabilityExceptionDtoImpl(
  date: json['date'] as String,
  period: $enumDecodeNullable(_$DayPeriodEnumMap, json['period']),
  available: json['available'] as bool,
);

Map<String, dynamic> _$$AvailabilityExceptionDtoImplToJson(
  _$AvailabilityExceptionDtoImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'period': _$DayPeriodEnumMap[instance.period],
  'available': instance.available,
};

_$RestrictionDtoImpl _$$RestrictionDtoImplFromJson(Map<String, dynamic> json) =>
    _$RestrictionDtoImpl(
      id: json['id'] as String,
      target: RestrictionTargetDto.fromJson(
        json['target'] as Map<String, dynamic>,
      ),
      targetName: json['target_name'] as String,
      kind: $enumDecode(_$RestrictionKindEnumMap, json['kind']),
      startsOn: json['starts_on'] as String,
      endsOn: json['ends_on'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RestrictionDtoImplToJson(
  _$RestrictionDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'target': instance.target,
  'target_name': instance.targetName,
  'kind': _$RestrictionKindEnumMap[instance.kind]!,
  'starts_on': instance.startsOn,
  'ends_on': instance.endsOn,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$RestrictionKindEnumMap = {
  RestrictionKind.permanent: 'permanent',
  RestrictionKind.temporary: 'temporary',
};

_$RestrictionTargetDtoImpl _$$RestrictionTargetDtoImplFromJson(
  Map<String, dynamic> json,
) => _$RestrictionTargetDtoImpl(
  type: $enumDecode(_$RestrictionTargetTypeEnumMap, json['type']),
  key: json['key'] as String,
);

Map<String, dynamic> _$$RestrictionTargetDtoImplToJson(
  _$RestrictionTargetDtoImpl instance,
) => <String, dynamic>{
  'type': _$RestrictionTargetTypeEnumMap[instance.type]!,
  'key': instance.key,
};

const _$RestrictionTargetTypeEnumMap = {
  RestrictionTargetType.category: 'category',
  RestrictionTargetType.activity: 'activity',
};

_$PreferencesDtoImpl _$$PreferencesDtoImplFromJson(Map<String, dynamic> json) =>
    _$PreferencesDtoImpl(
      preferredActivityKeys: (json['preferred_activity_keys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PreferencesDtoImplToJson(
  _$PreferencesDtoImpl instance,
) => <String, dynamic>{
  'preferred_activity_keys': instance.preferredActivityKeys,
};
