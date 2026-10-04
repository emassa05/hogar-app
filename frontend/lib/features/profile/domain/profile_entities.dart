import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
import '../../households/domain/household_entities.dart';
part 'profile_entities.freezed.dart';

enum DayPeriod { morning, afternoon, evening }

enum RestrictionKind { permanent, temporary }

enum RestrictionTargetType { category, activity }

@freezed
class MemberProfile with _$MemberProfile {
  const MemberProfile._();
  const factory MemberProfile({
    required String userId,
    required String name,
    required String? nickname,
    required AvatarChoice? avatar,
    required MemberRole role,
    required bool isMe,
    required int? proposedCapacityPercent,
    required int? approvedCapacityPercent,
    required Availability availability,
    required List<Restriction> restrictions,
    required Preferences preferences,
  }) = _MemberProfile;
  String get displayName => nickname ?? name;
}

@freezed
class Availability with _$Availability {
  const factory Availability({
    required List<AvailabilitySlot> slots,
    required List<AvailabilityException> exceptions,
  }) = _Availability;
}

@freezed
class AvailabilitySlot with _$AvailabilitySlot {
  const AvailabilitySlot._();
  const factory AvailabilitySlot({
    required int weekday,
    required DayPeriod period,
  }) = _AvailabilitySlot;
  String get identity => '$weekday:${period.name}';
}

@freezed
class AvailabilityException with _$AvailabilityException {
  const factory AvailabilityException({
    required String date,
    required DayPeriod? period,
    required bool available,
  }) = _AvailabilityException;
}

@freezed
class Restriction with _$Restriction {
  const factory Restriction({
    required String id,
    required RestrictionTarget target,
    required String targetName,
    required RestrictionKind kind,
    required String startsOn,
    required String? endsOn,
    required bool isActive,
    required DateTime createdAt,
  }) = _Restriction;
}

@freezed
class RestrictionTarget with _$RestrictionTarget {
  const RestrictionTarget._();
  const factory RestrictionTarget({
    required RestrictionTargetType type,
    required String key,
  }) = _RestrictionTarget;
  Map<String, dynamic> toRequest() => {'type': type.name, 'key': key};
}

@freezed
class Preferences with _$Preferences {
  const factory Preferences({required List<String> preferredActivityKeys}) =
      _Preferences;
}
