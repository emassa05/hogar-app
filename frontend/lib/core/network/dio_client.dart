import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../session/session_controller.dart';
import 'auth_interceptor.dart';
import 'error_mapper.dart';
import 'refresh_interceptor.dart';
import 'request_id_interceptor.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final base = BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.connectTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );
  final client = Dio(base);
  final refresh = Dio(base.copyWith());
  refresh.interceptors.addAll([
    RequestIdInterceptor(),
    ErrorMapperInterceptor(),
  ]);
  final session = ref.read(sessionControllerProvider.notifier);
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
  ref.onDispose(() {
    client.close(force: true);
    refresh.close(force: true);
  });
  return client;
}
