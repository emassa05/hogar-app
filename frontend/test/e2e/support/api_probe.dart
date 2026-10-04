import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ApiRecord {
  ApiRecord(Response<dynamic> response)
    : method = response.requestOptions.method,
      path = response.requestOptions.path,
      status = response.statusCode,
      requestId = response.requestOptions.headers['X-Request-ID'] as String,
      echoedRequestId = response.headers.value('X-Request-ID'),
      authenticated = response.requestOptions.headers.containsKey(
        'Authorization',
      ),
      idempotencyKey =
          response.requestOptions.headers['Idempotency-Key'] as String?,
      error = _error(response.data);

  final String method;
  final String path;
  final int? status;
  final String requestId;
  final String? echoedRequestId;
  final bool authenticated;
  final String? idempotencyKey;
  final Map<String, dynamic>? error;

  static Map<String, dynamic>? _error(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final error = data['error'];
    if (error is! Map<String, dynamic>) return null;
    final details = error['details'];
    return {
      'code': error['code'],
      'message': error['message'],
      'request_id': error['request_id'],
      if (details is Map<String, dynamic>)
        'details': {
          for (final key in [
            'remaining_attempts',
            'retry_after_seconds',
            'current_version',
            'fields',
          ])
            if (details.containsKey(key)) key: details[key],
        },
    };
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'path': path,
    'status': status,
    'request_id': requestId,
    'echoed_request_id': echoedRequestId,
    'authenticated': authenticated,
    if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    if (error != null) 'response': {'error': error},
  };
}

class ApiProbe extends Interceptor {
  ApiProbe(this.records);

  final List<ApiRecord> records;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    records.add(ApiRecord(response));
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final response = error.response;
    if (response != null) records.add(ApiRecord(response));
    handler.next(error);
  }

  void expectLast(
    String method,
    String path,
    int status, {
    bool? authenticated,
  }) {
    final record = records.last;
    expect(record.method, method);
    expect(record.path, path);
    expect(record.status, status);
    expect(record.echoedRequestId, record.requestId);
    expect(
      record.requestId,
      matches(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ),
    );
    if (authenticated != null) {
      expect(record.authenticated, authenticated);
    }
  }

  static Future<void> writeEvidence(List<ApiRecord> records) async {
    final directory = Directory('build/e2e');
    await directory.create(recursive: true);
    await File('${directory.path}/evidence.json').writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(records.map((record) => record.toJson()).toList()),
    );
  }
}
