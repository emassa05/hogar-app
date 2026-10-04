import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/features/auth/data/auth_remote_data_source.dart';
import 'package:hogar_app/features/auth/data/auth_repository_impl.dart';
import 'package:hogar_app/features/auth/domain/auth_entities.dart';

import '../support/fake_http_adapter.dart';

Map<String, dynamic> userJson() => {
  'id': 'user-id',
  'phone': '+56987654321',
  'name': 'Marta',
  'avatar': 'indigo',
  'active_household_id': null,
  'created_at': '2026-10-04T15:30:00Z',
};
Map<String, dynamic> sessionJson() => {
  'user': userJson(),
  'tokens': {
    'access_token': 'access',
    'refresh_token': 'refresh',
    'token_type': 'bearer',
    'expires_in': 900,
  },
};
Map<String, dynamic> verificationJson() => {
  'verification_id': 'verification-id',
  'phone': '+56987654321',
  'purpose': 'registration',
  'expires_at': DateTime.now()
      .toUtc()
      .add(const Duration(minutes: 10))
      .toIso8601String(),
  'resend_available_at': DateTime.now()
      .toUtc()
      .add(const Duration(seconds: 60))
      .toIso8601String(),
};

void main() {
  test(
    'auth requests serialize final contract fields and public metadata',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
      addTearDown(dio.close);
      final adapter = FakeHttpAdapter((request) async {
        expect(request.uri.path, startsWith('/api/v1/auth/'));
        expect(request.extra['requires_auth'], isFalse);
        if (request.path == '/auth/phone-verifications') {
          expect(requestBody(request)['purpose'], 'registration');
          return jsonResponse(verificationJson(), 202);
        }
        expect(requestBody(request)['avatar'], isNull);
        expect(requestBody(request)['verification_token'], 'proof');
        return jsonResponse(sessionJson(), 201);
      });
      dio.httpClientAdapter = adapter;
      final repository = AuthRepositoryImpl(AuthRemoteDataSource(dio));
      expect(
        await repository.requestCode(
          '+56987654321',
          VerificationPurpose.registration,
        ),
        isA<Success<PhoneVerification>>(),
      );
      expect(
        await repository.register(
          verificationToken: 'proof',
          password: 'Segura12',
          name: 'Marta',
        ),
        isA<Success<AuthenticatedSession>>(),
      );
    },
  );
  test(
    'repository preserves typed credential and validation failures',
    () async {
      final dio = Dio()
        ..httpClientAdapter = FakeHttpAdapter(
          (request) async =>
              apiError('INVALID_CREDENTIALS', 401, {'remaining_attempts': 4}),
        );
      addTearDown(dio.close);
      final result = await AuthRepositoryImpl(
        AuthRemoteDataSource(dio),
      ).login('+56987654321', 'password');
      expect(
        result,
        isA<Failure<AuthenticatedSession>>().having(
          (result) => (result.error as ApiException).code,
          'code',
          ApiErrorCode.invalidCredentials,
        ),
      );
    },
  );
  test('avatar updates send an explicit null to restore initials', () async {
    final dio = Dio()
      ..httpClientAdapter = FakeHttpAdapter((request) async {
        expect(requestBody(request), {'avatar': null});
        return jsonResponse(userJson()..['avatar'] = null);
      });
    addTearDown(dio.close);
    final result = await AuthRepositoryImpl(
      AuthRemoteDataSource(dio),
    ).updateAvatar(null);
    expect((result as Success<SessionUser>).value.avatar, isNull);
  });
}
