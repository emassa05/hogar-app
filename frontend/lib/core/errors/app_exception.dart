import 'dart:collection';

import 'api_error_code.dart';
import 'field_validation_error.dart';

sealed class AppException implements Exception {
  const AppException();
}

enum NetworkFailure { disconnected, timeout, cancelled }

final class NetworkException extends AppException {
  const NetworkException(this.kind);
  final NetworkFailure kind;
}

final class ApiException extends AppException {
  ApiException({
    required this.statusCode,
    required this.code,
    Map<String, dynamic> details = const {},
    this.requestId,
  }) : details = UnmodifiableMapView(details);

  final int statusCode;
  final ApiErrorCode code;
  final Map<String, dynamic> details;
  final String? requestId;

  List<FieldValidationError> get fields =>
      FieldValidationError.parse(details['fields']);
  int? get remainingAttempts => details['remaining_attempts'] is num
      ? (details['remaining_attempts'] as num).toInt()
      : null;
  int? get retryAfterSeconds => details['retry_after_seconds'] is num
      ? (details['retry_after_seconds'] as num).toInt()
      : null;
}

final class UnauthenticatedException extends AppException {
  const UnauthenticatedException();
}

final class UnexpectedException extends AppException {
  const UnexpectedException();
}
