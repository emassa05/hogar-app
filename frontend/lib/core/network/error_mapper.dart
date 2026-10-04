import 'package:dio/dio.dart';

import '../errors/api_error_code.dart';
import '../errors/app_exception.dart';

abstract final class ErrorMapper {
  static AppException map(DioException exception) {
    if (exception.error case final AppException error) return error;
    if (exception.type == DioExceptionType.connectionTimeout || exception.type == DioExceptionType.sendTimeout || exception.type == DioExceptionType.receiveTimeout) {
      return const NetworkException(NetworkFailure.timeout);
    }
    if (exception.type == DioExceptionType.cancel) return const NetworkException(NetworkFailure.cancelled);
    if (exception.type == DioExceptionType.connectionError) return const NetworkException(NetworkFailure.disconnected);
    final response = exception.response;
    if (response == null) return const NetworkException(NetworkFailure.disconnected);
    final data = response.data;
    final envelope = data is Map<String, dynamic> ? data['error'] : null;
    final error = envelope is Map<String, dynamic> ? envelope : <String, dynamic>{};
    final rawDetails = error['details'];
    final details = rawDetails is Map<String, dynamic> ? Map<String, dynamic>.of(rawDetails) : <String, dynamic>{};
    final retryAfter = int.tryParse(response.headers.value('Retry-After') ?? '');
    if (retryAfter != null) details.putIfAbsent('retry_after_seconds', () => retryAfter);
    return ApiException(statusCode: response.statusCode ?? 0, code: ApiErrorCode.fromValue(error['code']), details: details, requestId: error['request_id'] is String ? error['request_id'] as String : response.headers.value('X-Request-ID'));
  }
}

class ErrorMapperInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: ErrorMapper.map(err)));
  }
}
