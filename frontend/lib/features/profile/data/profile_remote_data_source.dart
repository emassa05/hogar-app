import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../domain/profile_entities.dart';
import '../domain/profile_repository.dart';
import 'profile_dtos.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this.dio);
  final Dio dio;
  String _path(String id) => '/households/$id/members/me';
  Future<MemberProfileDto> profile(String id) async =>
      MemberProfileDto.fromJson(
        ApiResponse.object(
          (await dio.get<Object?>('${_path(id)}/profile')).data,
        ),
      );
  Future<MemberProfileDto> update(
    String id,
    String? nickname,
    int? capacity,
  ) async => MemberProfileDto.fromJson(
    ApiResponse.object(
      (await dio.patch<Object?>(
        '${_path(id)}/profile',
        data: {'nickname': nickname, 'proposed_capacity_percent': capacity},
      )).data,
    ),
  );
  Future<AvailabilityDto> availability(String id, Availability value) async =>
      AvailabilityDto.fromJson(
        ApiResponse.object(
          (await dio.put<Object?>(
            '${_path(id)}/availability',
            data: {
              'slots': value.slots
                  .map(
                    (slot) => {
                      'weekday': slot.weekday,
                      'period': slot.period.name,
                    },
                  )
                  .toList(),
              'exceptions': value.exceptions
                  .map(
                    (exception) => {
                      'date': exception.date,
                      'period': exception.period?.name,
                      'available': exception.available,
                    },
                  )
                  .toList(),
            },
          )).data,
        ),
      );
  Future<RestrictionDto> addRestriction(
    String id,
    RestrictionInput input,
  ) async => RestrictionDto.fromJson(
    ApiResponse.object(
      (await dio.post<Object?>(
        '${_path(id)}/restrictions',
        data: input.toRequest(),
      )).data,
    ),
  );
  Future<RestrictionDto> editRestriction(
    String id,
    String restrictionId,
    RestrictionInput input,
  ) async => RestrictionDto.fromJson(
    ApiResponse.object(
      (await dio.put<Object?>(
        '${_path(id)}/restrictions/$restrictionId',
        data: input.toRequest(),
      )).data,
    ),
  );
  Future<void> removeRestriction(String id, String restrictionId) async {
    await dio.delete<Object?>('${_path(id)}/restrictions/$restrictionId');
  }

  Future<PreferencesDto> preferences(String id, List<String> keys) async =>
      PreferencesDto.fromJson(
        ApiResponse.object(
          (await dio.put<Object?>(
            '${_path(id)}/preferences',
            data: {'preferred_activity_keys': keys},
          )).data,
        ),
      );
}
