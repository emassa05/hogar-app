import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../domain/notification_settings.dart';

final notificationSettingsRepositoryProvider = Provider(
  (ref) => NotificationSettingsRepository(ref.watch(dioClientProvider)),
);

class NotificationSettingsRepository {
  const NotificationSettingsRepository(this.dio);
  final Dio dio;
  static const path = '/users/me/notification-settings';

  Future<Result<NotificationSettings>> load() => capture(() async {
    final response = await dio.get<Object?>(path);
    return NotificationSettings.fromJson(response.data);
  });

  Future<Result<NotificationSettings>> save(NotificationSettings value) =>
      capture(() async {
        if (!value.isValid) {
          throw const FormatException('Invalid notification settings input');
        }
        final response = await dio.put<Object?>(path, data: value.toJson());
        return NotificationSettings.fromJson(response.data);
      });
}
