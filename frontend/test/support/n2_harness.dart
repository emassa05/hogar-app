import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hogar_app/core/network/dio_client.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/session/token_pair.dart';
import 'package:hogar_app/core/storage/token_storage.dart';
import 'fake_http_adapter.dart';
import 'memory_token_storage.dart';
import 'n2_fixtures.dart';

class N2Harness {
  N2Harness(HttpResponder respond) {
    adapter = FakeHttpAdapter(respond);
    dio = Dio()..httpClientAdapter = adapter;
    container = ProviderContainer(
      overrides: [
        dioClientProvider.overrideWithValue(dio),
        tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
      ],
    );
  }
  late final FakeHttpAdapter adapter;
  late final Dio dio;
  late final ProviderContainer container;
  Future<void> signIn({String? householdId = 'household-1'}) => container
      .read(sessionControllerProvider.notifier)
      .establish(
        const TokenPair(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'bearer',
          expiresIn: 900,
        ),
        SessionUser.fromJson(userJson(householdId: householdId)),
      );
  void dispose() {
    container.dispose();
    dio.close();
  }
}
