import 'dart:convert';
import 'dart:io';

class SmsLog {
  const SmsLog(this.path);
  final String path;

  Future<int> refreshRequestCount() async {
    final file = File(path);
    final accessLog = File('${file.parent.path}/api-errors.log');
    final paths = {file.path, if (await accessLog.exists()) accessLog.path};
    var count = 0;
    for (final path in paths) {
      count += (await File(path).readAsLines())
          .where((line) => line.contains('POST /api/v1/auth/refresh HTTP/1.1'))
          .length;
    }
    return count;
  }

  Future<String> codeFor(String requestId) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(deadline)) {
      final lines = await File(path).readAsLines();
      for (final line in lines.reversed) {
        Map<String, dynamic> entry;
        try {
          final decoded = jsonDecode(line);
          if (decoded is! Map<String, dynamic>) continue;
          entry = decoded;
        } on FormatException {
          continue;
        }
        if (entry['request_id'] != requestId ||
            entry['logger'] != 'app.common.sms') {
          continue;
        }
        final message = entry['message'];
        if (message is! String) continue;
        final match = RegExp(
          r'Tu código de equilibrio es\s+(\d{3})\s+(\d{3})',
        ).firstMatch(message);
        if (match != null) return '${match[1]}${match[2]}';
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    throw StateError('No console SMS found for the verification request ID.');
  }
}
