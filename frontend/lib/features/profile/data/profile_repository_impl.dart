import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/profile_entities.dart';
import '../domain/profile_repository.dart';
import 'profile_remote_data_source.dart';
part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this.remote);
  final ProfileRemoteDataSource remote;
  @override
  Future<Result<MemberProfile>> profile(String id, {String userId = 'me'}) =>
      capture(
        () async => (await remote.profile(id, userId: userId)).toDomain(),
      );
  @override
  Future<Result<MemberProfile>> updateNickname(String id, String? nickname) =>
      capture(
        () async => (await remote.updateNickname(id, nickname)).toDomain(),
      );
  @override
  Future<Result<MemberProfile>> update(
    String id,
    String? nickname,
    int? capacity,
  ) => capture(
    () async => (await remote.update(id, nickname, capacity)).toDomain(),
  );
  @override
  Future<Result<Availability>> availability(String id, Availability value) =>
      capture(() async => (await remote.availability(id, value)).toDomain());
  @override
  Future<Result<Restriction>> addRestriction(
    String id,
    RestrictionInput input,
  ) => capture(() async => (await remote.addRestriction(id, input)).toDomain());
  @override
  Future<Result<Restriction>> editRestriction(
    String id,
    String restrictionId,
    RestrictionInput input,
  ) => capture(
    () async =>
        (await remote.editRestriction(id, restrictionId, input)).toDomain(),
  );
  @override
  Future<Result<void>> removeRestriction(String id, String restrictionId) =>
      capture(() => remote.removeRestriction(id, restrictionId));
  @override
  Future<Result<Preferences>> preferences(String id, List<String> keys) =>
      capture(() async => (await remote.preferences(id, keys)).toDomain());
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  ProfileRemoteDataSource(ref.watch(dioClientProvider)),
);
