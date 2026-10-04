import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/token_storage.dart';
import 'session_access.dart';
import 'session_state.dart';
import 'session_user.dart';
import 'token_pair.dart';

part 'session_controller.g.dart';

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController implements SessionAccess {
  TokenPair? _tokens;
  int _epoch = 0;
  Future<void> _storageQueue = Future.value();

  @override
  TokenPair? get tokens => _tokens;
  @override
  int get epoch => _epoch;

  @override
  SessionState build() => const SessionState();

  Future<void> _persist(Future<void> Function() action) {
    final pending = _storageQueue.then((_) => action());
    _storageQueue = pending.then(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return pending;
  }

  Future<void> restore() async {
    final currentEpoch = _epoch;
    final pair = await ref.read(tokenStorageProvider).read();
    if (currentEpoch != _epoch) return;
    _tokens = pair;
    state = SessionState(
      status: pair == null
          ? SessionStatus.unauthenticated
          : SessionStatus.restoring,
    );
  }

  Future<void> establish(TokenPair pair, SessionUser user) async {
    final expectedEpoch = ++_epoch;
    await _persist(() => ref.read(tokenStorageProvider).write(pair));
    if (expectedEpoch != _epoch) return;
    _tokens = pair;
    state = SessionState(status: SessionStatus.authenticated, user: user);
  }

  void confirmUser(SessionUser user) {
    if (_tokens != null)
      state = SessionState(status: SessionStatus.authenticated, user: user);
  }

  @override
  Future<bool> replaceTokens(
    TokenPair pair, {
    required int expectedEpoch,
  }) async {
    if (expectedEpoch != _epoch || _tokens == null) return false;
    await _persist(() async {
      if (expectedEpoch == _epoch)
        await ref.read(tokenStorageProvider).write(pair);
    });
    if (expectedEpoch != _epoch) return false;
    _tokens = pair;
    return true;
  }

  @override
  Future<void> expire({int? expectedEpoch}) async {
    if (expectedEpoch != null && expectedEpoch != _epoch) return;
    ++_epoch;
    _tokens = null;
    state = const SessionState(status: SessionStatus.unauthenticated);
    await _persist(() => ref.read(tokenStorageProvider).clear());
  }
}
