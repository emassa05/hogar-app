import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../../../core/session/session_user.dart';
import '../domain/household_entities.dart';
import '../domain/household_repository.dart';
import 'household_remote_data_source.dart';
part 'household_repository_impl.g.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  const HouseholdRepositoryImpl(this.remote);
  final HouseholdRemoteDataSource remote;
  @override
  Future<Result<List<HouseholdSummary>>> list() => capture(
    () async => (await remote.list())
        .map((value) => value.toDomain())
        .toList(growable: false),
  );
  @override
  Future<Result<HouseholdDetail>> create(String name, String actionKey) =>
      capture(() async => (await remote.create(name, actionKey)).toDomain());
  @override
  Future<Result<HouseholdDetail>> detail(String id) =>
      capture(() async => (await remote.detail(id)).toDomain());
  @override
  Future<Result<HouseholdDetail>> update(String id, int version, String name) =>
      capture(() async => (await remote.update(id, version, name)).toDomain());
  @override
  Future<Result<Invitation>> invitation(String id) =>
      capture(() async => (await remote.invitation(id)).toDomain());
  @override
  Future<Result<Invitation>> regenerateInvitation(String id) =>
      capture(() async => (await remote.regenerateInvitation(id)).toDomain());
  @override
  Future<Result<InvitationPreview>> preview(String code) =>
      capture(() async => (await remote.preview(code)).toDomain());
  @override
  Future<Result<HouseholdDetail>> accept(String code) =>
      capture(() async => (await remote.accept(code)).toDomain());
  @override
  Future<Result<Member>> changeRole(
    String id,
    String userId,
    MemberRole role,
  ) => capture(
    () async => (await remote.changeRole(id, userId, role)).toDomain(),
  );
  @override
  Future<Result<SessionUser>> selectActive(String id) =>
      capture(() => remote.selectActive(id));
  @override
  Future<Result<void>> removeMember(String id, String userId) =>
      capture(() => remote.removeMember(id, userId));
  @override
  Future<Result<void>> leave(String id) => capture(() => remote.leave(id));
}

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) => HouseholdRepositoryImpl(
  HouseholdRemoteDataSource(ref.watch(dioClientProvider)),
);
