import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/l10n/error_messages.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/result/result_value.dart';
import 'package:hogar_app/features/profile/data/profile_remote_data_source.dart';
import 'package:hogar_app/features/profile/data/profile_repository_impl.dart';
import 'package:hogar_app/features/profile/domain/profile_entities.dart';
import 'package:hogar_app/features/profile/domain/profile_repository.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';

void main() {
  late Dio dio;
  late ProfileRepositoryImpl repository;
  setUp(() {
    dio = Dio();
    repository = ProfileRepositoryImpl(ProfileRemoteDataSource(dio));
  });
  tearDown(() => dio.close());
  test(
    'profile permits nullable nickname and capacity without free text fields',
    () async {
      final adapter = FakeHttpAdapter(
        (request) async => jsonResponse(profileJson()),
      );
      dio.httpClientAdapter = adapter;
      final profile = (await repository.profile('household-1')).valueOrThrow;
      expect(profile.proposedCapacityPercent, isNull);
      expect(profile.displayName, 'Marta');
      await repository.update('household-1', null, null);
      expect(requestBody(adapter.requests.last), {
        'nickname': null,
        'proposed_capacity_percent': null,
      });
      expect(
        adapter.requests.last.path,
        '/households/household-1/members/me/profile',
      );
      expect(() => profile.restrictions.clear(), throwsUnsupportedError);
    },
  );
  test(
    'availability PUT replaces slots and exceptions including full day overrides',
    () async {
      final adapter = FakeHttpAdapter(
        (request) async => jsonResponse(requestBody(request)),
      );
      dio.httpClientAdapter = adapter;
      const availability = Availability(
        slots: [AvailabilitySlot(weekday: 0, period: DayPeriod.morning)],
        exceptions: [
          AvailabilityException(
            date: '2026-10-12',
            period: null,
            available: false,
          ),
        ],
      );
      expect(
        (await repository.availability(
          'household-1',
          availability,
        )).valueOrThrow,
        availability,
      );
      expect(adapter.requests.single.method, 'PUT');
      expect(requestBody(adapter.requests.single), {
        'slots': [
          {'weekday': 0, 'period': 'morning'},
        ],
        'exceptions': [
          {'date': '2026-10-12', 'period': null, 'available': false},
        ],
      });
      await repository.availability(
        'household-1',
        const Availability(slots: [], exceptions: []),
      );
      expect(requestBody(adapter.requests.last), {
        'slots': <Object?>[],
        'exceptions': <Object?>[],
      });
    },
  );
  test(
    'restriction CRUD sends catalog targets and omits end date for permanent restrictions',
    () async {
      final adapter = FakeHttpAdapter(
        (request) async => request.method == 'DELETE'
            ? jsonResponse(null, 204)
            : jsonResponse(restrictionJson()),
      );
      dio.httpClientAdapter = adapter;
      const permanent = RestrictionInput(
        target: RestrictionTarget(
          type: RestrictionTargetType.activity,
          key: 'laundry_load',
        ),
        kind: RestrictionKind.permanent,
      );
      expect(
        (await repository.addRestriction(
          'household-1',
          permanent,
        )).valueOrThrow.target.key,
        'laundry_load',
      );
      expect(requestBody(adapter.requests.last), {
        'target': {'type': 'activity', 'key': 'laundry_load'},
        'kind': 'permanent',
      });
      const temporary = RestrictionInput(
        target: RestrictionTarget(
          type: RestrictionTargetType.category,
          key: 'laundry',
        ),
        kind: RestrictionKind.temporary,
        startsOn: '2026-10-04',
        endsOn: '2026-10-12',
      );
      await repository.editRestriction(
        'household-1',
        'restriction-1',
        temporary,
      );
      expect(adapter.requests.last.method, 'PUT');
      expect(requestBody(adapter.requests.last), {
        'target': {'type': 'category', 'key': 'laundry'},
        'kind': 'temporary',
        'starts_on': '2026-10-04',
        'ends_on': '2026-10-12',
      });
      expect(
        await repository.removeRestriction('household-1', 'restriction-1'),
        isA<Success<void>>(),
      );
      expect(
        adapter.requests.last.path,
        '/households/household-1/members/me/restrictions/restriction-1',
      );
    },
  );
  test(
    'preferences sends only preferred keys and retains field level failures',
    () async {
      final adapter = FakeHttpAdapter(
        (request) async =>
            requestBody(request)['preferred_activity_keys'] is List<dynamic> &&
                (requestBody(request)['preferred_activity_keys']
                        as List<dynamic>)
                    .isEmpty
            ? apiError('VALIDATION_ERROR', 422, {
                'fields': [
                  {
                    'field': 'body.preferred_activity_keys',
                    'code': 'conflicting_values',
                  },
                ],
              })
            : jsonResponse(preferencesJson(['dog_walk'])),
      );
      dio.httpClientAdapter = adapter;
      expect(
        (await repository.preferences('household-1', [
          'dog_walk',
        ])).valueOrThrow.preferredActivityKeys,
        ['dog_walk'],
      );
      expect(requestBody(adapter.requests.last), {
        'preferred_activity_keys': ['dog_walk'],
      });
      final result = await repository.preferences('household-1', []);
      final error = (result as Failure<Preferences>).error as ApiException;
      expect(
        ErrorMessages.field(error, 'preferred_activity_keys'),
        'Esta opción es incompatible con los datos actuales.',
      );
    },
  );
}
