import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef HttpResponder = Future<ResponseBody> Function(RequestOptions request);

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.respond);
  final HttpResponder respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? data, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody apiError(
  String code, [
  int status = 401,
  Map<String, dynamic> details = const {},
]) => jsonResponse({
  'error': {
    'code': code,
    'message': 'technical message',
    'details': details,
    'request_id': 'request-id',
  },
}, status);

Map<String, dynamic> requestBody(RequestOptions request) =>
    request.data is String
    ? jsonDecode(request.data as String) as Map<String, dynamic>
    : request.data as Map<String, dynamic>;
