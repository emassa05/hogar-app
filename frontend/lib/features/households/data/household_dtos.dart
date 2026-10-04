import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/session/session_user.dart';
import '../domain/household_entities.dart';
part 'household_dtos.freezed.dart';
part 'household_dtos.g.dart';

@freezed
class HouseholdSummaryDto with _$HouseholdSummaryDto {
  const HouseholdSummaryDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HouseholdSummaryDto({
    required String id,
    required String name,
    required MemberRole myRole,
    required int memberCount,
    required DateTime createdAt,
  }) = _HouseholdSummaryDto;
  factory HouseholdSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdSummaryDtoFromJson(json);
  HouseholdSummary toDomain() => HouseholdSummary(
    id: id,
    name: name,
    myRole: myRole,
    memberCount: memberCount,
    createdAt: createdAt,
  );
}

@freezed
class HouseholdDetailDto with _$HouseholdDetailDto {
  const HouseholdDetailDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HouseholdDetailDto({
    required String id,
    required String name,
    required String timezone,
    required int? imbalanceThresholdPercent,
    required MemberRole myRole,
    required List<MemberDto> members,
    required bool templatesApplied,
    required int version,
    required DateTime createdAt,
  }) = _HouseholdDetailDto;
  factory HouseholdDetailDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdDetailDtoFromJson(json);
  HouseholdDetail toDomain() => HouseholdDetail(
    id: id,
    name: name,
    timezone: timezone,
    imbalanceThresholdPercent: imbalanceThresholdPercent,
    myRole: myRole,
    members: List.unmodifiable(members.map((value) => value.toDomain())),
    templatesApplied: templatesApplied,
    version: version,
    createdAt: createdAt,
  );
}

@freezed
class MemberDto with _$MemberDto {
  const MemberDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberDto({
    required String userId,
    required String name,
    required String? nickname,
    required AvatarChoice? avatar,
    required MemberRole role,
    required DateTime joinedAt,
    required bool isMe,
  }) = _MemberDto;
  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);
  Member toDomain() => Member(
    userId: userId,
    name: name,
    nickname: nickname,
    avatar: avatar,
    role: role,
    joinedAt: joinedAt,
    isMe: isMe,
  );
}

@freezed
class InvitationDto with _$InvitationDto {
  const InvitationDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory InvitationDto({
    required String code,
    required DateTime expiresAt,
    required String shareUrl,
  }) = _InvitationDto;
  factory InvitationDto.fromJson(Map<String, dynamic> json) =>
      _$InvitationDtoFromJson(json);
  Invitation toDomain() =>
      Invitation(code: code, expiresAt: expiresAt, shareUrl: shareUrl);
}

@freezed
class InvitationPreviewDto with _$InvitationPreviewDto {
  const InvitationPreviewDto._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory InvitationPreviewDto({
    required String householdId,
    required String householdName,
    required int memberCount,
    required DateTime expiresAt,
  }) = _InvitationPreviewDto;
  factory InvitationPreviewDto.fromJson(Map<String, dynamic> json) =>
      _$InvitationPreviewDtoFromJson(json);
  InvitationPreview toDomain() => InvitationPreview(
    householdId: householdId,
    householdName: householdName,
    memberCount: memberCount,
    expiresAt: expiresAt,
  );
}
