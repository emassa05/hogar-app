import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../core/session/session_user.dart';
import '../domain/household_entities.dart';
import 'household_dtos.dart';

class HouseholdRemoteDataSource {
  const HouseholdRemoteDataSource(this.dio);
  final Dio dio;
  Future<List<HouseholdSummaryDto>> list() async => ApiResponse.objects(
    (await dio.get<Object?>('/households')).data,
  ).map(HouseholdSummaryDto.fromJson).toList();
  Future<HouseholdDetailDto> create(String name, String actionKey) async =>
      HouseholdDetailDto.fromJson(
        ApiResponse.object(
          (await dio.post<Object?>(
            '/households',
            data: {'name': name, 'timezone': 'America/Santiago'},
            options: Options(headers: {'Idempotency-Key': actionKey}),
          )).data,
        ),
      );
  Future<HouseholdDetailDto> detail(String id) async =>
      HouseholdDetailDto.fromJson(
        ApiResponse.object((await dio.get<Object?>('/households/$id')).data),
      );
  Future<HouseholdDetailDto> update(
    String id,
    int version,
    String name,
  ) async => HouseholdDetailDto.fromJson(
    ApiResponse.object(
      (await dio.patch<Object?>(
        '/households/$id',
        data: {'version': version, 'name': name},
      )).data,
    ),
  );
  Future<InvitationDto> invitation(String id) async => InvitationDto.fromJson(
    ApiResponse.object(
      (await dio.get<Object?>('/households/$id/invitation')).data,
    ),
  );
  Future<InvitationDto> regenerateInvitation(String id) async =>
      InvitationDto.fromJson(
        ApiResponse.object(
          (await dio.post<Object?>(
            '/households/$id/invitation/regenerate',
          )).data,
        ),
      );
  Future<InvitationPreviewDto> preview(String code) async =>
      InvitationPreviewDto.fromJson(
        ApiResponse.object((await dio.get<Object?>('/invitations/$code')).data),
      );
  Future<HouseholdDetailDto> accept(String code) async =>
      HouseholdDetailDto.fromJson(
        ApiResponse.object(
          (await dio.post<Object?>('/invitations/$code/accept')).data,
        ),
      );
  Future<MemberDto> changeRole(
    String id,
    String userId,
    MemberRole role,
  ) async => MemberDto.fromJson(
    ApiResponse.object(
      (await dio.patch<Object?>(
        '/households/$id/members/$userId',
        data: {'role': role.name},
      )).data,
    ),
  );
  Future<SessionUser> selectActive(String id) async => SessionUser.fromJson(
    ApiResponse.object(
      (await dio.patch<Object?>(
        '/users/me',
        data: {'active_household_id': id},
      )).data,
    ),
  );
  Future<void> removeMember(String id, String userId) async {
    await dio.delete<Object?>('/households/$id/members/$userId');
  }

  Future<void> leave(String id) async {
    await dio.post<Object?>('/households/$id/leave');
  }
}
