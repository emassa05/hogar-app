import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/storage/token_storage.dart';
import 'package:hogar_app/features/auth/data/auth_remote_data_source.dart';
import 'package:hogar_app/features/auth/data/auth_repository_impl.dart';
import 'package:hogar_app/features/auth/presentation/auth_controller.dart';

import '../support/fake_http_adapter.dart';
import '../support/memory_token_storage.dart';
import 'auth_repository_test.dart' show sessionJson, verificationJson;

void main() {
  late ProviderContainer container;
  late Dio dio;
  late MemoryTokenStorage storage;
  setUp(() {
    dio = Dio();
    storage = MemoryTokenStorage();
    container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryImpl(AuthRemoteDataSource(dio)),
        ),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    dio.close();
  });
  test(
    'registration sends draft once and clears sensitive memory after success',
    () async {
      var registrations = 0;
      dio.httpClientAdapter = FakeHttpAdapter((request) async {
        if (request.path == '/auth/phone-verifications') {
          return jsonResponse(verificationJson(), 202);
        }
        if (request.path.endsWith('/confirm')) {
          return jsonResponse({
            'verification_token': 'proof',
            'expires_at': DateTime.now()
                .add(const Duration(minutes: 15))
                .toIso8601String(),
          });
        }
        registrations++;
        expect(requestBody(request)['password'], 'Segura12');
        return jsonResponse(sessionJson(), 201);
      });
      final notifier = container.read(authControllerProvider.notifier);
      expect(await notifier.requestCode('9 8765 4321'), isTrue);
      expect(await notifier.confirmCode('482715'), isTrue);
      expect(notifier.savePassword('Segura12'), isTrue);
      expect(notifier.saveName(' Marta '), isTrue);
      expect(await notifier.register(skipAvatar: true), isTrue);
      expect(registrations, 1);
      expect(storage.tokens, isNotNull);
      expect(container.read(sessionControllerProvider).isAuthenticated, isTrue);
      expect(container.read(authControllerProvider).password, isEmpty);
      expect(container.read(authControllerProvider).proof, isNull);
      expect(container.read(authControllerProvider).accountCreated, isTrue);
    },
  );
  test('rate limits block new login attempts until server deadline', () async {
    var requests = 0;
    dio.httpClientAdapter = FakeHttpAdapter((request) async {
      requests++;
      return apiError('ACCOUNT_LOCKED', 423, {'retry_after_seconds': 900});
    });
    final notifier = container.read(authControllerProvider.notifier);
    expect(await notifier.login('987654321', 'wrong'), isFalse);
    expect(
      (container.read(authControllerProvider).error as ApiException).code,
      ApiErrorCode.accountLocked,
    );
    expect(await notifier.login('987654321', 'wrong'), isFalse);
    expect(requests, 1);
    expect(container.read(sessionControllerProvider).isAuthenticated, isFalse);
  });
  test(
    'reset cancels a late SMS response and duplicate submits stay single flight',
    () async {
      final gate = Completer<void>();
      var requests = 0;
      dio.httpClientAdapter = FakeHttpAdapter((request) async {
        requests++;
        await gate.future;
        return jsonResponse(verificationJson(), 202);
      });
      final notifier = container.read(authControllerProvider.notifier);
      final pending = notifier.requestCode('987654321');
      expect(await notifier.requestCode('987654321'), isFalse);
      notifier.reset();
      gate.complete();
      expect(await pending, isFalse);
      expect(requests, 1);
      expect(container.read(authControllerProvider).verification, isNull);
    },
  );
  test(
    'secure storage failure never presents an authenticated session',
    () async {
      storage.failWrites = true;
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) async => jsonResponse(sessionJson()),
      );
      expect(
        await container
            .read(authControllerProvider.notifier)
            .login('987654321', 'Segura12'),
        isFalse,
      );
      expect(
        container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
      expect(
        container.read(authControllerProvider).error,
        isA<UnexpectedException>(),
      );
    },
  );
}
