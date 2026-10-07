import '../../../core/result/result.dart';
import '../../../core/session/session_user.dart';
import 'household_entities.dart';

abstract interface class HouseholdRepository {
  Future<Result<List<HouseholdSummary>>> list();
  Future<Result<HouseholdDetail>> create(String name, String actionKey);
  Future<Result<HouseholdDetail>> detail(String id);
  Future<Result<HouseholdDetail>> update(String id, int version, String name);
  Future<Result<Invitation>> invitation(String id);
  Future<Result<Invitation>> regenerateInvitation(String id);
  Future<Result<InvitationPreview>> preview(String code);
  Future<Result<HouseholdDetail>> accept(String code);
  Future<Result<Member>> changeRole(String id, String userId, MemberRole role);
  Future<Result<SessionUser>> selectActive(String id);
  Future<Result<void>> removeMember(String id, String userId);
  Future<Result<void>> leave(String id);
}
