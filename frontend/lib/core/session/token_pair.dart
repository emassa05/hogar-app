import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_pair.freezed.dart';
part 'token_pair.g.dart';

@Freezed(toStringOverride: false)
class TokenPair with _$TokenPair {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TokenPair({
    required String accessToken,
    required String refreshToken,
    @Default('bearer') String tokenType,
    required int expiresIn,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
}
