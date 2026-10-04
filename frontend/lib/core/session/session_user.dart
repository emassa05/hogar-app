import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_user.freezed.dart';
part 'session_user.g.dart';

enum AvatarChoice { indigo, green, peach, yellow, sky, pink }

@Freezed(toStringOverride: false)
class SessionUser with _$SessionUser {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SessionUser({
    required String id,
    required String phone,
    required String name,
    AvatarChoice? avatar,
    String? activeHouseholdId,
    required DateTime createdAt,
  }) = _SessionUser;
  factory SessionUser.fromJson(Map<String, dynamic> json) =>
      _$SessionUserFromJson(json);
}
