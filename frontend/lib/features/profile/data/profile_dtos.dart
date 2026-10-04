import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
import '../../households/domain/household_entities.dart';
import '../domain/profile_entities.dart';
part 'profile_dtos.freezed.dart';
part 'profile_dtos.g.dart';

@freezed
class MemberProfileDto with _$MemberProfileDto {
  const MemberProfileDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberProfileDto({
    required String userId,
    required String name,
    required String? nickname,
    required AvatarChoice? avatar,
    required MemberRole role,
    required bool isMe,
    required int? proposedCapacityPercent,
    required int? approvedCapacityPercent,
    required AvailabilityDto availability,
    required List<RestrictionDto> restrictions,
    required PreferencesDto preferences,
  }) = _MemberProfileDto;
  factory MemberProfileDto.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileDtoFromJson(json);
  MemberProfile toDomain() => MemberProfile(
    userId: userId,
    name: name,
    nickname: nickname,
    avatar: avatar,
    role: role,
    isMe: isMe,
    proposedCapacityPercent: proposedCapacityPercent,
    approvedCapacityPercent: approvedCapacityPercent,
    availability: availability.toDomain(),
    restrictions: List.unmodifiable(
      restrictions.map((value) => value.toDomain()),
    ),
    preferences: preferences.toDomain(),
  );
}

@freezed
class AvailabilityDto with _$AvailabilityDto {
  const AvailabilityDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AvailabilityDto({
    required List<AvailabilitySlotDto> slots,
    required List<AvailabilityExceptionDto> exceptions,
  }) = _AvailabilityDto;
  factory AvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityDtoFromJson(json);
  Availability toDomain() => Availability(
    slots: List.unmodifiable(slots.map((value) => value.toDomain())),
    exceptions: List.unmodifiable(exceptions.map((value) => value.toDomain())),
  );
}

@freezed
class AvailabilitySlotDto with _$AvailabilitySlotDto {
  const AvailabilitySlotDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AvailabilitySlotDto({
    required int weekday,
    required DayPeriod period,
  }) = _AvailabilitySlotDto;
  factory AvailabilitySlotDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotDtoFromJson(json);
  AvailabilitySlot toDomain() =>
      AvailabilitySlot(weekday: weekday, period: period);
}

@freezed
class AvailabilityExceptionDto with _$AvailabilityExceptionDto {
  const AvailabilityExceptionDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AvailabilityExceptionDto({
    required String date,
    required DayPeriod? period,
    required bool available,
  }) = _AvailabilityExceptionDto;
  factory AvailabilityExceptionDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityExceptionDtoFromJson(json);
  AvailabilityException toDomain() =>
      AvailabilityException(date: date, period: period, available: available);
}

@freezed
class RestrictionDto with _$RestrictionDto {
  const RestrictionDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RestrictionDto({
    required String id,
    required RestrictionTargetDto target,
    required String targetName,
    required RestrictionKind kind,
    required String startsOn,
    required String? endsOn,
    required bool isActive,
    required DateTime createdAt,
  }) = _RestrictionDto;
  factory RestrictionDto.fromJson(Map<String, dynamic> json) =>
      _$RestrictionDtoFromJson(json);
  Restriction toDomain() => Restriction(
    id: id,
    target: target.toDomain(),
    targetName: targetName,
    kind: kind,
    startsOn: startsOn,
    endsOn: endsOn,
    isActive: isActive,
    createdAt: createdAt,
  );
}

@freezed
class RestrictionTargetDto with _$RestrictionTargetDto {
  const RestrictionTargetDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RestrictionTargetDto({
    required RestrictionTargetType type,
    required String key,
  }) = _RestrictionTargetDto;
  factory RestrictionTargetDto.fromJson(Map<String, dynamic> json) =>
      _$RestrictionTargetDtoFromJson(json);
  RestrictionTarget toDomain() => RestrictionTarget(type: type, key: key);
}

@freezed
class PreferencesDto with _$PreferencesDto {
  const PreferencesDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PreferencesDto({required List<String> preferredActivityKeys}) =
      _PreferencesDto;
  factory PreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$PreferencesDtoFromJson(json);
  Preferences toDomain() => Preferences(
    preferredActivityKeys: List.unmodifiable(preferredActivityKeys),
  );
}
