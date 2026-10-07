import '../../../core/result/result.dart';
import 'profile_entities.dart';

class RestrictionInput {
  const RestrictionInput({
    required this.target,
    required this.kind,
    this.startsOn,
    this.endsOn,
  });
  final RestrictionTarget target;
  final RestrictionKind kind;
  final String? startsOn;
  final String? endsOn;
  Map<String, dynamic> toRequest() => {
    'target': target.toRequest(),
    'kind': kind.name,
    if (startsOn != null) 'starts_on': startsOn,
    if (kind == RestrictionKind.temporary) 'ends_on': endsOn,
  };
}

abstract interface class ProfileRepository {
  Future<Result<MemberProfile>> profile(String id, {String userId = 'me'});
  Future<Result<MemberProfile>> updateNickname(String id, String? nickname);
  Future<Result<MemberProfile>> updateCapacity(String id, int capacity);
  Future<Result<MemberProfile>> update(
    String id,
    String? nickname,
    int? capacity,
  );
  Future<Result<Availability>> availability(String id, Availability value);
  Future<Result<Restriction>> addRestriction(String id, RestrictionInput input);
  Future<Result<Restriction>> editRestriction(
    String id,
    String restrictionId,
    RestrictionInput input,
  );
  Future<Result<void>> removeRestriction(String id, String restrictionId);
  Future<Result<Preferences>> preferences(String id, List<String> keys);
}
