import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/l10n/error_messages.dart';
import 'package:hogar_app/core/network/error_mapper.dart';

void main() {
  final request = RequestOptions(path: '/test');
  test(
    'maps envelope and field validation without exposing technical copy',
    () {
      final response = Response<Object?>(
        requestOptions: request,
        statusCode: 422,
        data: {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'secret technical copy',
            'request_id': 'trace',
            'details': {
              'fields': [
                {
                  'field': 'body.password',
                  'code': 'password_missing_uppercase',
                  'message': 'English',
                },
              ],
            },
          },
        },
      );
      final error =
          ErrorMapper.map(
                DioException(requestOptions: request, response: response),
              )
              as ApiException;
      expect(error.code, ApiErrorCode.validationError);
      expect(error.requestId, 'trace');
      expect(
        ErrorMessages.field(error, 'password'),
        'Añade una letra mayúscula.',
      );
      expect(ErrorMessages.forException(error), isNot(contains('secret')));
    },
  );
  test('unknown codes and non-JSON server responses remain safe', () {
    final error =
        ErrorMapper.map(
              DioException(
                requestOptions: request,
                response: Response<Object?>(
                  requestOptions: request,
                  statusCode: 502,
                  data: '<html>error</html>',
                ),
              ),
            )
            as ApiException;
    expect(error.code, ApiErrorCode.unknown);
    for (final code in ApiErrorCode.values) {
      expect(ErrorMessages.forCode(code), isNotEmpty);
    }
    expect(ApiErrorCode.fromValue('FUTURE_CODE'), ApiErrorCode.unknown);
  });
  test('classifies network timeouts and uses Retry-After fallback', () {
    expect(
      (ErrorMapper.map(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.receiveTimeout,
                ),
              )
              as NetworkException)
          .kind,
      NetworkFailure.timeout,
    );
    final error =
        ErrorMapper.map(
              DioException(
                requestOptions: request,
                response: Response<Object?>(
                  requestOptions: request,
                  statusCode: 429,
                  headers: Headers.fromMap({
                    'Retry-After': ['60'],
                  }),
                  data: {
                    'error': {'code': 'RATE_LIMITED'},
                  },
                ),
              ),
            )
            as ApiException;
    expect(error.retryAfterSeconds, 60);
  });
}
