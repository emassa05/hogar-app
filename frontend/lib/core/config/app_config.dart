import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

class AppConfig {
  const AppConfig({
    this.apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1',
    ),
  });
  final String apiBaseUrl;
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
}

@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) => const AppConfig();
