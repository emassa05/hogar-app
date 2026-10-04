import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/result/result_value.dart';
import 'package:hogar_app/features/households/data/household_remote_data_source.dart';
import 'package:hogar_app/features/households/data/household_repository_impl.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';

void main() {
  late Dio dio;
  late HouseholdRepositoryImpl repository;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
    repository = HouseholdRepositoryImpl(HouseholdRemoteDataSource(dio));
  });
  tearDown(() => dio.close());
  test(
    'household reads and mutations serialize versions and idempotency keys',
    () async {
      final adapter = FakeHttpAdapter((request) async {
        if (request.method == 'GET' && request.path == '/households') {
          return jsonResponse([summaryJson()]);
        }
        return jsonResponse(
          householdJson(version: 3),
          request.method == 'POST' ? 201 : 200,
        );
      });
      dio.httpClientAdapter = adapter;
      expect((await repository.list()).valueOrThrow.single.memberCount, 1);
      expect(
        (await repository.create(
          'Casa Los Robles',
          'action-1',
        )).valueOrThrow.myRole,
        MemberRole.admin,
      );
      expect(adapter.requests.last.headers['Idempotency-Key'], 'action-1');
      expect(requestBody(adapter.requests.last), {
        'name': 'Casa Los Robles',
        'timezone': 'America/Santiago',
      });
      expect(adapter.requests.last.uri.path, '/api/v1/households');
      expect((await repository.detail('household-1')).valueOrThrow.version, 3);
      await repository.update('household-1', 3, 'Casa nueva');
      expect(requestBody(adapter.requests.last), {
        'version': 3,
        'name': 'Casa nueva',
      });
      expect(adapter.requests.last.method, 'PATCH');
    },
  );
  test(
    'invitation and member endpoints map final schemas including explicit active household',
    () async {
      final adapter = FakeHttpAdapter((request) async {
        if (request.path == '/users/me') return jsonResponse(userJson());
        if (request.path.endsWith('/regenerate') ||
            request.path.endsWith('/invitation')) {
          return jsonResponse(invitationJson());
        }
        if (request.path.startsWith('/invitations') &&
            request.method == 'GET') {
          return jsonResponse(previewJson());
        }
        if (request.path.endsWith('/accept')) {
          return jsonResponse(householdJson(role: 'member'), 201);
        }
        if (request.method == 'DELETE') return jsonResponse(null, 204);
        return jsonResponse(memberJson(id: 'user-2', isMe: false));
      });
      dio.httpClientAdapter = adapter;
      expect(
        (await repository.invitation('household-1')).valueOrThrow.code,
        '7QK2-M9XA',
      );
      await repository.regenerateInvitation('household-1');
      expect(
        adapter.requests.last.path,
        '/households/household-1/invitation/regenerate',
      );
      final preview = (await repository.preview('7QK2-M9XA')).valueOrThrow;
      expect(preview.householdName, 'Casa Los Robles');
      expect(preview.memberCount, 4);
      expect(
        (await repository.accept('7QK2-M9XA')).valueOrThrow.myRole,
        MemberRole.member,
      );
      await repository.changeRole('household-1', 'user-2', MemberRole.admin);
      expect(requestBody(adapter.requests.last), {'role': 'admin'});
      expect(
        await repository.removeMember('household-1', 'user-2'),
        isA<Success<void>>(),
      );
      expect(adapter.requests.last.method, 'DELETE');
      expect(
        (await repository.selectActive(
          'household-1',
        )).valueOrThrow.activeHouseholdId,
        'household-1',
      );
      expect(requestBody(adapter.requests.last), {
        'active_household_id': 'household-1',
      });
    },
  );
  test(
    'conflicts and validation fields remain typed without exposing technical messages',
    () async {
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) async =>
            apiError('VERSION_CONFLICT', 412, {'current_version': 4}),
      );
      final result = await repository.update('household-1', 1, 'Cambio');
      expect(result, isA<Failure<HouseholdDetail>>());
      final error = (result as Failure<HouseholdDetail>).error as ApiException;
      expect(error.code, ApiErrorCode.versionConflict);
      expect(error.statusCode, 412);
      expect(error.requestId, 'request-id');
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) async => jsonResponse(['invalid object']),
      );
      expect(
        (await repository.list() as Failure<List<HouseholdSummary>>).error,
        isA<UnexpectedException>(),
      );
    },
  );
}
