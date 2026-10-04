import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../../../core/session/session_controller.dart';
import '../data/auth_repository_impl.dart';

part 'session_bootstrap.g.dart';

@Riverpod(keepAlive: true)
Future<void> sessionBootstrap(Ref ref) async {
  final session = ref.read(sessionControllerProvider.notifier);
  await session.restore();
  if (session.tokens == null) return;
  final expectedEpoch = session.epoch;
  final result = await ref.read(authRepositoryProvider).currentUser();
  if (session.epoch != expectedEpoch) return;
  switch (result) {
    case Success(:final value):
      session.confirmUser(value);
    case Failure(:final error):
      if (error is UnauthenticatedException) {
        await session.expire(expectedEpoch: expectedEpoch);
      } else {
        throw error;
      }
  }
}
