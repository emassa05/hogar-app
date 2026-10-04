import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

abstract final class RequestOptionsFactory {
  static Options get public => Options(extra: {requiresAuth: false});
  static const requiresAuth = 'requires_auth';
  static const refreshRetried = 'refresh_retried';
}

class IdempotentAction {
  IdempotentAction() : key = const Uuid().v4();
  final String key;
  Options get options => Options(headers: {'Idempotency-Key': key});
}
