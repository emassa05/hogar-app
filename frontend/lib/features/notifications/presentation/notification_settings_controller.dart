import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_operation.dart';
import '../data/notification_settings_repository.dart';
import '../domain/notification_settings.dart';

typedef NotificationActor = ({String userId, int epoch});

final notificationSettingsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      NotificationSettingsController,
      NotificationSettingsState,
      NotificationActor
    >(NotificationSettingsController.new);

class NotificationSettingsState {
  const NotificationSettingsState(
    this.settings, {
    this.busy = false,
    this.error,
    this.saved = false,
    this.uncertain = false,
    this.blockedUntil,
  });
  final NotificationSettings settings;
  final bool busy;
  final AppException? error;
  final bool saved;
  final bool uncertain;
  final DateTime? blockedUntil;
  bool get blocked => blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false;
}

class NotificationSettingsController
    extends
        AutoDisposeFamilyAsyncNotifier<
          NotificationSettingsState,
          NotificationActor
        > {
  bool _alive = true;
  int _revision = 0;

  SessionOperation _operation() {
    final revision = _revision;
    return SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () =>
          _alive &&
          revision == _revision &&
          ref.read(sessionControllerProvider).user?.id == arg.userId &&
          ref.read(sessionControllerProvider).isAuthenticated,
    );
  }

  @override
  Future<NotificationSettingsState> build(NotificationActor arg) async {
    _alive = true;
    _revision++;
    ref.onDispose(() {
      _alive = false;
      _revision++;
    });
    final operation = _operation();
    if (!operation.isCurrent || operation.epoch != arg.epoch) {
      throw const UnauthenticatedException();
    }
    final settings =
        (await ref.read(notificationSettingsRepositoryProvider).load())
            .valueOrThrow;
    operation.checkCurrent();
    return NotificationSettingsState(settings);
  }

  Future<NotificationSettings?> save(NotificationSettings draft) async {
    final current = state.valueOrNull;
    if (!_alive ||
        state.isLoading ||
        state.hasError ||
        current == null ||
        current.busy ||
        current.blocked ||
        !draft.isValid) {
      return null;
    }
    final operation = _operation();
    if (!operation.isCurrent || operation.epoch != arg.epoch) return null;
    state = AsyncData(
      NotificationSettingsState(
        current.settings,
        busy: true,
        uncertain: current.uncertain,
      ),
    );
    final repository = ref.read(notificationSettingsRepositoryProvider);
    var confirmed = current.settings;
    var uncertain = current.uncertain;
    final result = await capture(() async {
      if (uncertain) {
        confirmed = (await repository.load()).valueOrThrow;
        operation.checkCurrent();
        uncertain = false;
        if (confirmed.sameValues(draft)) return confirmed;
      }
      final response = await repository.save(draft);
      operation.checkCurrent();
      if (response case Failure<NotificationSettings>(:final error)) {
        uncertain =
            error is NetworkException ||
            error is UnexpectedException ||
            (error is ApiException && error.statusCode >= 500);
      }
      return response.valueOrThrow;
    });
    if (!operation.isCurrent) return null;
    if (result case Failure<NotificationSettings>(:final error)) {
      state = AsyncData(
        NotificationSettingsState(
          confirmed,
          error: error,
          uncertain: uncertain,
          blockedUntil: error is ApiException && error.retryAfterSeconds != null
              ? DateTime.now().toUtc().add(
                  Duration(seconds: error.retryAfterSeconds!),
                )
              : null,
        ),
      );
      return null;
    }
    final settings = result.valueOrThrow;
    state = AsyncData(NotificationSettingsState(settings, saved: true));
    return settings;
  }
}
