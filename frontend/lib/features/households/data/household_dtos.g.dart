part of 'household_dtos.dart';

_$HouseholdSummaryDtoImpl _$$HouseholdSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$HouseholdSummaryDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  myRole: $enumDecode(_$MemberRoleEnumMap, json['my_role']),
  memberCount: (json['member_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$HouseholdSummaryDtoImplToJson(
  _$HouseholdSummaryDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'my_role': _$MemberRoleEnumMap[instance.myRole]!,
  'member_count': instance.memberCount,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$MemberRoleEnumMap = {
  MemberRole.admin: 'admin',
  MemberRole.member: 'member',
};

_$HouseholdDetailDtoImpl _$$HouseholdDetailDtoImplFromJson(
  Map<String, dynamic> json,
) => _$HouseholdDetailDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  imbalanceThresholdPercent: (json['imbalance_threshold_percent'] as num?)
      ?.toInt(),
  myRole: $enumDecode(_$MemberRoleEnumMap, json['my_role']),
  members: (json['members'] as List<dynamic>)
      .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  templatesApplied: json['templates_applied'] as bool,
  version: (json['version'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$HouseholdDetailDtoImplToJson(
  _$HouseholdDetailDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'timezone': instance.timezone,
  'imbalance_threshold_percent': instance.imbalanceThresholdPercent,
  'my_role': _$MemberRoleEnumMap[instance.myRole]!,
  'members': instance.members,
  'templates_applied': instance.templatesApplied,
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
};

_$MemberDtoImpl _$$MemberDtoImplFromJson(Map<String, dynamic> json) =>
    _$MemberDtoImpl(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      avatar: $enumDecodeNullable(_$AvatarChoiceEnumMap, json['avatar']),
      role: $enumDecode(_$MemberRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      isMe: json['is_me'] as bool,
    );

Map<String, dynamic> _$$MemberDtoImplToJson(_$MemberDtoImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'nickname': instance.nickname,
      'avatar': _$AvatarChoiceEnumMap[instance.avatar],
      'role': _$MemberRoleEnumMap[instance.role]!,
      'joined_at': instance.joinedAt.toIso8601String(),
      'is_me': instance.isMe,
    };

const _$AvatarChoiceEnumMap = {
  AvatarChoice.indigo: 'indigo',
  AvatarChoice.green: 'green',
  AvatarChoice.peach: 'peach',
  AvatarChoice.yellow: 'yellow',
  AvatarChoice.sky: 'sky',
  AvatarChoice.pink: 'pink',
};

_$InvitationDtoImpl _$$InvitationDtoImplFromJson(Map<String, dynamic> json) =>
    _$InvitationDtoImpl(
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      shareUrl: json['share_url'] as String,
    );

Map<String, dynamic> _$$InvitationDtoImplToJson(_$InvitationDtoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'expires_at': instance.expiresAt.toIso8601String(),
      'share_url': instance.shareUrl,
    };

_$InvitationPreviewDtoImpl _$$InvitationPreviewDtoImplFromJson(
  Map<String, dynamic> json,
) => _$InvitationPreviewDtoImpl(
  householdId: json['household_id'] as String,
  householdName: json['household_name'] as String,
  memberCount: (json['member_count'] as num).toInt(),
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$$InvitationPreviewDtoImplToJson(
  _$InvitationPreviewDtoImpl instance,
) => <String, dynamic>{
  'household_id': instance.householdId,
  'household_name': instance.householdName,
  'member_count': instance.memberCount,
  'expires_at': instance.expiresAt.toIso8601String(),
};
