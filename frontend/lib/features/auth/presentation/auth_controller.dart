import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/api_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_state.dart';
import '../../../core/session/session_user.dart';
import '../../../core/validation/validators.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_entities.dart';
import 'auth_flow_state.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  int _revision = 0;
  bool _alive = true;

  @override
  AuthFlowState build() {
    ref.onDispose(() => _alive = false);
    ref.listen(sessionControllerProvider, (previous, next) {
      if (previous?.isAuthenticated == true &&
          next.status == SessionStatus.unauthenticated) {
        reset();
      }
    });
    return const AuthFlowState();
  }

  void reset({VerificationPurpose purpose = VerificationPurpose.registration}) {
    _revision++;
    state = AuthFlowState(purpose: purpose);
  }

  void clearError() => state = state.copyWith(error: null);
  void chooseAvatar(AvatarChoice? avatar) =>
      state = state.copyWith(avatar: avatar, error: null);
  void dismissCelebration() => state = const AuthFlowState();

  bool savePassword(String value) {
    if (PasswordValidator.validate(value) != null) return false;
    state = state.copyWith(password: value.trim(), error: null);
    return true;
  }

  bool saveName(String value) {
    if (NameValidator.validate(value) != null) return false;
    state = state.copyWith(name: value.trim(), error: null);
    return true;
  }

  Future<bool> _run<T>(
    Future<Result<T>> Function() operation,
    void Function(T) onSuccess,
  ) async {
    if (state.busy ||
        (state.blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false)) {
      return false;
    }
    final revision = ++_revision;
    state = state.copyWith(busy: true, error: null);
    final result = await operation();
    if (!_alive || revision != _revision) return false;
    state = state.copyWith(busy: false);
    switch (result) {
      case Success<T>(:final value):
        onSuccess(value);
        return true;
      case Failure<T>(:final error):
        var blockedUntil = state.blockedUntil;
        var verification = state.verification;
        var proof = state.proof;
        if (error is ApiException) {
          if (error.retryAfterSeconds != null) {
            blockedUntil = DateTime.now().toUtc().add(
              Duration(seconds: error.retryAfterSeconds!),
            );
          }
          if (error.code == ApiErrorCode.verificationResendTooSoon &&
              blockedUntil != null) {
            verification = verification?.withResendAt(blockedUntil);
          }
          if (error.code == ApiErrorCode.invalidVerificationToken) proof = null;
        }
        state = state.copyWith(
          error: error,
          blockedUntil: blockedUntil,
          verification: verification,
          proof: proof,
          accountCreated: false,
          errorPulse:
              state.errorPulse +
              (error is ApiException &&
                      error.code == ApiErrorCode.verificationCodeInvalid
                  ? 1
                  : 0),
        );
        return false;
    }
  }

  Future<bool> requestCode(String phone) async {
    if (PhoneValidator.validate(phone) != null) return false;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .requestCode(PhoneValidator.normalize(phone), state.purpose),
      (value) => state = state.copyWith(verification: value, proof: null),
    );
  }

  Future<bool> resendCode() async {
    final verification = state.verification;
    if (verification == null ||
        verification.resendAvailableAt.isAfter(DateTime.now().toUtc())) {
      return false;
    }
    return _run(
      () => ref.read(authRepositoryProvider).resendCode(verification.id),
      (value) => state = state.copyWith(verification: value, proof: null),
    );
  }

  Future<bool> confirmCode(String code) async {
    final verification = state.verification;
    if (verification == null || !CodeValidator.isValidOtp(code)) return false;
    return _run(
      () => ref.read(authRepositoryProvider).confirmCode(verification.id, code),
      (value) => state = state.copyWith(proof: value),
    );
  }

  Future<Result<SessionUser>> _authenticate(
    Future<Result<AuthenticatedSession>> operation, {
    bool celebrate = false,
  }) async {
    final expectedRevision = _revision;
    final result = await operation;
    if (!_alive || expectedRevision != _revision) {
      return const Failure(UnauthenticatedException());
    }
    if (result case Failure<AuthenticatedSession>(:final error)) {
      return Failure(error);
    }
    final value = (result as Success<AuthenticatedSession>).value;
    return capture(() async {
      state = state.copyWith(accountCreated: celebrate);
      await ref
          .read(sessionControllerProvider.notifier)
          .establish(value.tokens, value.user);
      return value.user;
    });
  }

  Future<bool> register({bool skipAvatar = false}) async {
    final draft = state;
    if (draft.proof == null ||
        PasswordValidator.validate(draft.password) != null ||
        NameValidator.validate(draft.name) != null) {
      return false;
    }
    return _run(
      () => _authenticate(
        ref
            .read(authRepositoryProvider)
            .register(
              verificationToken: draft.proof!.token,
              password: draft.password,
              name: draft.name,
              avatar: skipAvatar ? null : draft.avatar,
            ),
        celebrate: true,
      ),
      (_) => state = const AuthFlowState(accountCreated: true),
    );
  }

  Future<bool> login(String phone, String password) async {
    if (PhoneValidator.validate(phone) != null || password.trim().isEmpty) {
      return false;
    }
    return _run(
      () => _authenticate(
        ref
            .read(authRepositoryProvider)
            .login(PhoneValidator.normalize(phone), password.trim()),
      ),
      (_) => state = const AuthFlowState(),
    );
  }

  Future<bool> resetPassword(String password) async {
    final proof = state.proof;
    if (proof == null || PasswordValidator.validate(password) != null) {
      return false;
    }
    return _run(
      () => _authenticate(
        ref
            .read(authRepositoryProvider)
            .resetPassword(proof.token, password.trim()),
      ),
      (_) => state = const AuthFlowState(),
    );
  }
}
