import 'package:dio/dio.dart';

import '../session/session_access.dart';
import 'request_options.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.session);
  final SessionAccess session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[RequestOptionsFactory.requiresAuth] == false) {
      options.headers.remove('Authorization');
    } else {
      final token = session.tokens?.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
