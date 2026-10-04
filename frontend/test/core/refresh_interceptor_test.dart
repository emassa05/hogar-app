import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/network/auth_interceptor.dart';
import 'package:hogar_app/core/network/error_mapper.dart';
import 'package:hogar_app/core/network/refresh_interceptor.dart';
import 'package:hogar_app/core/network/request_id_interceptor.dart';
import 'package:hogar_app/core/network/request_options.dart';
import 'package:hogar_app/core/session/session_access.dart';
import 'package:hogar_app/core/session/token_pair.dart';

import '../support/fake_http_adapter.dart';

class _Session implements SessionAccess {
  @override
  TokenPair? tokens = const TokenPair(
    accessToken: 'old',
    refreshToken: 'refresh-old',
    expiresIn: 900,
  );
  @override
  int epoch = 0;
  int logouts = 0;
  @override
  Future<bool> replaceTokens(
    TokenPair pair, {
    required int expectedEpoch,
  }) async {
    if (epoch != expectedEpoch) return false;
    tokens = pair;
    return true;
  }

  @override
  Future<void> expire({int? expectedEpoch}) async {
    if (expectedEpoch != null && expectedEpoch != epoch) return;
    epoch++;
    logouts++;
    tokens = null;
  }
}

void main() {
  late Dio client;
  late Dio refresh;
  late _Session session;
  setUp(() {
    session = _Session();
    client = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    refresh = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    client.interceptors.addAll([
      RequestIdInterceptor(),
      AuthInterceptor(session),
      RefreshInterceptor(
        client: client,
        refreshClient: refresh,
        session: session,
      ),
      ErrorMapperInterceptor(),
    ]);
    refresh.interceptors.add(ErrorMapperInterceptor());
  });
  tearDown(() {
    client.close();
    refresh.close();
  });
  test(
    'concurrent 401s share one refresh, rotate tokens and retry once',
    () async {
      final gate = Completer<void>();
      var refreshes = 0;
      final protected = FakeHttpAdapter(
        (request) async => request.headers['Authorization'] == 'Bearer new'
            ? jsonResponse({'ok': true})
            : apiError('UNAUTHENTICATED'),
      );
      client.httpClientAdapter = protected;
      refresh.httpClientAdapter = FakeHttpAdapter((request) async {
        refreshes++;
        expect(requestBody(request)['refresh_token'], 'refresh-old');
        await gate.future;
        return jsonResponse({
          'access_token': 'new',
          'refresh_token': 'refresh-new',
          'token_type': 'bearer',
          'expires_in': 900,
        });
      });
      final results = Future.wait([
        client.get<dynamic>('/one'),
        client.get<dynamic>('/two'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      gate.complete();
      expect((await results).length, 2);
      expect(refreshes, 1);
      expect(session.tokens?.refreshToken, 'refresh-new');
      expect(protected.requests.length, 4);
      expect(
        protected.requests.map((r) => r.headers['X-Request-ID']).toSet().length,
        4,
      );
    },
  );
  test('invalid refresh expires the session', () async {
    client.httpClientAdapter = FakeHttpAdapter(
      (request) async => apiError('UNAUTHENTICATED'),
    );
    refresh.httpClientAdapter = FakeHttpAdapter(
      (request) async => apiError('INVALID_REFRESH_TOKEN'),
    );
    await expectLater(
      client.get<dynamic>('/one'),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          'mapped error',
          isA<UnauthenticatedException>(),
        ),
      ),
    );
    expect(session.tokens, isNull);
    expect(session.logouts, 1);
  });
  test('failed retry never refreshes a second time', () async {
    var refreshes = 0;
    client.httpClientAdapter = FakeHttpAdapter(
      (request) async => apiError('UNAUTHENTICATED'),
    );
    refresh.httpClientAdapter = FakeHttpAdapter((request) async {
      refreshes++;
      return jsonResponse({
        'access_token': 'new',
        'refresh_token': 'refresh-new',
        'expires_in': 900,
      });
    });
    await expectLater(
      client.get<dynamic>('/one'),
      throwsA(isA<DioException>()),
    );
    expect(refreshes, 1);
    expect(session.logouts, 1);
  });
  test(
    'public credential failures do not refresh or send bearer tokens',
    () async {
      client.httpClientAdapter = FakeHttpAdapter((request) async {
        expect(request.headers['Authorization'], isNull);
        return apiError('INVALID_CREDENTIALS');
      });
      refresh.httpClientAdapter = FakeHttpAdapter(
        (request) async => throw StateError('unexpected refresh'),
      );
      await expectLater(
        client.post<dynamic>(
          '/auth/login',
          options: RequestOptionsFactory.public,
        ),
        throwsA(isA<DioException>()),
      );
      expect(session.logouts, 0);
    },
  );
  test(
    'logout during refresh cannot restore tokens or retry the old request',
    () async {
      final gate = Completer<void>();
      client.httpClientAdapter = FakeHttpAdapter(
        (request) async => apiError('UNAUTHENTICATED'),
      );
      refresh.httpClientAdapter = FakeHttpAdapter((request) async {
        await gate.future;
        return jsonResponse({
          'access_token': 'new',
          'refresh_token': 'refresh-new',
          'expires_in': 900,
        });
      });
      final pending = expectLater(
        client.get<dynamic>('/one'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await session.expire();
      gate.complete();
      await pending;
      expect(session.tokens, isNull);
    },
  );
  test(
    'transient refresh failure preserves the session for an explicit retry',
    () async {
      client.httpClientAdapter = FakeHttpAdapter(
        (request) async => apiError('UNAUTHENTICATED'),
      );
      refresh.httpClientAdapter = FakeHttpAdapter(
        (request) async => apiError('SERVICE_UNAVAILABLE', 503),
      );
      await expectLater(
        client.get<dynamic>('/one'),
        throwsA(isA<DioException>()),
      );
      expect(session.tokens, isNotNull);
      expect(session.logouts, 0);
    },
  );
}
