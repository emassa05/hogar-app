part of 'session_user.dart';

_$SessionUserImpl _$$SessionUserImplFromJson(Map<String, dynamic> json) =>
    _$SessionUserImpl(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      avatar: $enumDecodeNullable(_$AvatarChoiceEnumMap, json['avatar']),
      activeHouseholdId: json['active_household_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SessionUserImplToJson(_$SessionUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'avatar': _$AvatarChoiceEnumMap[instance.avatar],
      'active_household_id': instance.activeHouseholdId,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AvatarChoiceEnumMap = {
  AvatarChoice.indigo: 'indigo',
  AvatarChoice.green: 'green',
  AvatarChoice.peach: 'peach',
  AvatarChoice.yellow: 'yellow',
  AvatarChoice.sky: 'sky',
  AvatarChoice.pink: 'pink',
};
