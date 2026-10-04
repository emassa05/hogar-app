import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
part 'household_entities.freezed.dart';

enum MemberRole { admin, member }

@freezed
class HouseholdSummary with _$HouseholdSummary {
  const factory HouseholdSummary({
    required String id,
    required String name,
    required MemberRole myRole,
    required int memberCount,
    required DateTime createdAt,
  }) = _HouseholdSummary;
}

@freezed
class HouseholdDetail with _$HouseholdDetail {
  const factory HouseholdDetail({
    required String id,
    required String name,
    required String timezone,
    required int? imbalanceThresholdPercent,
    required MemberRole myRole,
    required List<Member> members,
    required bool templatesApplied,
    required int version,
    required DateTime createdAt,
  }) = _HouseholdDetail;
}

@freezed
class Member with _$Member {
  const Member._();
  const factory Member({
    required String userId,
    required String name,
    required String? nickname,
    required AvatarChoice? avatar,
    required MemberRole role,
    required DateTime joinedAt,
    required bool isMe,
  }) = _Member;
  String get displayName => nickname ?? name;
}

@freezed
class Invitation with _$Invitation {
  const factory Invitation({
    required String code,
    required DateTime expiresAt,
    required String shareUrl,
  }) = _Invitation;
}

@freezed
class InvitationPreview with _$InvitationPreview {
  const factory InvitationPreview({
    required String householdId,
    required String householdName,
    required int memberCount,
    required DateTime expiresAt,
  }) = _InvitationPreview;
}
