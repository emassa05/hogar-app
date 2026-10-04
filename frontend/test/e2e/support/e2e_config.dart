import 'dart:io';

class E2eConfig {
  E2eConfig()
    : baseUrl = _setting(
        'E2E_API_BASE_URL',
        const String.fromEnvironment('E2E_API_BASE_URL'),
        fallback: 'http://localhost:8100/api/v1',
      ),
      smsLogPath = _setting(
        'E2E_SMS_LOG_PATH',
        const String.fromEnvironment('E2E_SMS_LOG_PATH'),
      );

  final String baseUrl;
  final String smsLogPath;

  static String _setting(String key, String define, {String fallback = ''}) =>
      define.isNotEmpty ? define : Platform.environment[key] ?? fallback;

  void validate() {
    final uri = Uri.parse(baseUrl);
    if (!{'localhost', '127.0.0.1', '::1'}.contains(uri.host)) {
      throw StateError('E2E_API_BASE_URL must point to a local dedicated API.');
    }
    if (smsLogPath.isEmpty || !File(smsLogPath).existsSync()) {
      throw StateError('E2E_SMS_LOG_PATH must point to the console SMS log.');
    }
  }
}
