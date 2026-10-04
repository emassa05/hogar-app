import 'package:dio/dio.dart';

import '../errors/api_error_code.dart';
import '../errors/app_exception.dart';
import '../session/session_access.dart';
import '../session/token_pair.dart';
import 'error_mapper.dart';
import 'request_options.dart';

class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this.client,
    required this.refreshClient,
    required this.session,
  });

  final Dio client;
  final Dio refreshClient;
  final SessionAccess session;
  Future<TokenPair>? _flight;
  int? _flightEpoch;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final mapped = ErrorMapper.map(err);
    final options = err.requestOptions;
    final protected =
        options.extra[RequestOptionsFactory.requiresAuth] != false;
    if (!protected ||
        mapped is! ApiException ||
        mapped.statusCode != 401 ||
        mapped.code != ApiErrorCode.unauthenticated) {
      handler.next(err);
      return;
    }
    final expectedEpoch = session.epoch;
    if (options.extra[RequestOptionsFactory.refreshRetried] == true) {
      await session.expire(expectedEpoch: expectedEpoch);
      handler.next(err.copyWith(error: const UnauthenticatedException()));
      return;
    }
    final current = session.tokens;
    if (current == null) {
      handler.next(err.copyWith(error: const UnauthenticatedException()));
      return;
    }
    try {
      final failedToken = options.headers['Authorization'];
      final pair = failedToken != 'Bearer ${current.accessToken}'
          ? current
          : await _singleRefresh(expectedEpoch);
      if (session.epoch != expectedEpoch || session.tokens == null) {
        throw const UnauthenticatedException();
      }
      final retry = options.copyWith(
        headers: {
          ...options.headers,
          'Authorization': 'Bearer ${pair.accessToken}',
        },
        extra: {...options.extra, RequestOptionsFactory.refreshRetried: true},
        data: options.data is FormData
            ? (options.data as FormData).clone()
            : options.data,
      );
      handler.resolve(await client.fetch<dynamic>(retry));
    } on DioException catch (error) {
      handler.next(error);
    } on AppException catch (error) {
      handler.next(err.copyWith(error: error));
    } on Object {
      handler.next(err.copyWith(error: const UnexpectedException()));
    }
  }

  Future<TokenPair> _singleRefresh(int expectedEpoch) async {
    if (_flight != null && _flightEpoch == expectedEpoch) return _flight!;
    final pending = _refresh(expectedEpoch);
    _flight = pending;
    _flightEpoch = expectedEpoch;
    try {
      return await pending;
    } finally {
      if (identical(_flight, pending)) {
        _flight = null;
        _flightEpoch = null;
      }
    }
  }

  Future<TokenPair> _refresh(int expectedEpoch) async {
    final refreshToken = session.tokens?.refreshToken;
    if (refreshToken == null) throw const UnauthenticatedException();
    try {
      final response = await refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: RequestOptionsFactory.public,
      );
      final pair = TokenPair.fromJson(response.data!);
      if (!await session.replaceTokens(pair, expectedEpoch: expectedEpoch)) {
        throw const UnauthenticatedException();
      }
      return pair;
    } on DioException catch (error) {
      final mapped = ErrorMapper.map(error);
      if (mapped is ApiException &&
          mapped.code == ApiErrorCode.invalidRefreshToken) {
        await session.expire(expectedEpoch: expectedEpoch);
        throw const UnauthenticatedException();
      }
      throw mapped;
    }
  }
}
