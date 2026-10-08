import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/config/app_config.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/network/dio_client.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/storage/token_storage.dart';
import 'package:hogar_app/features/auth/data/auth_repository_impl.dart';
import 'package:hogar_app/features/auth/domain/auth_entities.dart';
import 'package:hogar_app/features/auth/domain/auth_repository.dart';
import 'package:hogar_app/features/capacity/data/capacity_repository_impl.dart';
import 'package:hogar_app/features/capacity/domain/capacity_repository.dart';
import 'package:hogar_app/features/catalog/data/catalog_repository_impl.dart';
import 'package:hogar_app/features/catalog/domain/catalog_repository.dart';
import 'package:hogar_app/features/households/data/household_repository_impl.dart';
import 'package:hogar_app/features/households/domain/household_repository.dart';
import 'package:hogar_app/features/notifications/data/notification_settings_repository.dart';
import 'package:hogar_app/features/profile/data/profile_repository_impl.dart';
import 'package:hogar_app/features/profile/domain/profile_repository.dart';
import 'package:hogar_app/features/templates/data/template_repository_impl.dart';
import 'package:hogar_app/features/templates/domain/template_repository.dart';

import '../../support/memory_token_storage.dart';
import 'api_probe.dart';
import 'e2e_config.dart';
import 'sms_log.dart';

Future<T> requireSuccess<T>(Future<Result<T>> pending) async {
  final result = await pending;
  return switch (result) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => throw TestFailure(
      'Repository failed: ${error is ApiException ? '${error.statusCode} ${error.code.value}' : error.runtimeType}.',
    ),
  };
}

ApiException requireFailure<T>(
  Result<T> result,
  ApiErrorCode code,
  int status,
) {
  if (result case Failure<T>(error: final ApiException error)) {
    expect(error.code, code);
    expect(error.statusCode, status);
    expect(error.requestId, isNotEmpty);
    return error;
  }
  throw TestFailure(
    'Expected $status ${code.value}, got ${result.runtimeType}.',
  );
}

class E2eAccount {
  const E2eAccount({
    required this.phone,
    required this.password,
    required this.user,
  });
  final String phone;
  final String password;
  final SessionUser user;
}

class E2eClient {
  E2eClient(E2eConfig config, List<ApiRecord> records)
    : sms = SmsLog(config.smsLogPath),
      storage = MemoryTokenStorage() {
    container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(apiBaseUrl: config.baseUrl),
        ),
        tokenStorageProvider.overrideWithValue(storage),
      ],
    );
    probe = ApiProbe(records);
    dio.interceptors.add(probe);
  }

  final MemoryTokenStorage storage;
  final SmsLog sms;
  late final ProviderContainer container;
  late final ApiProbe probe;

  Dio get dio => container.read(dioClientProvider);
  SessionController get session =>
      container.read(sessionControllerProvider.notifier);
  SessionUser? get user => container.read(sessionControllerProvider).user;
  AuthRepository get auth => container.read(authRepositoryProvider);
  HouseholdRepository get households =>
      container.read(householdRepositoryProvider);
  ProfileRepository get profiles => container.read(profileRepositoryProvider);
  CapacityRepository get capacity => container.read(capacityRepositoryProvider);
  NotificationSettingsRepository get notificationSettings =>
      container.read(notificationSettingsRepositoryProvider);
  CatalogRepository get catalog => container.read(catalogRepositoryProvider);
  TemplateRepository get templates =>
      container.read(templateRepositoryProvider);

  Future<VerificationProof> verify(
    String phone,
    VerificationPurpose purpose, {
    bool exerciseErrors = false,
    PhoneVerification? verification,
  }) async {
    final pending =
        verification ??
        await requireSuccess<PhoneVerification>(
          auth.requestCode(phone, purpose),
        );
    probe.expectLast(
      'POST',
      '/auth/phone-verifications',
      202,
      authenticated: false,
    );
    expect(pending.phone, phone);
    expect(pending.purpose, purpose);
    expect(pending.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
    expect(pending.resendAvailableAt.isBefore(pending.expiresAt), isTrue);
    final code = await sms.codeFor(probe.records.last.requestId);
    if (exerciseErrors) {
      final wrongCode = code == '000000' ? '111111' : '000000';
      final invalid = requireFailure(
        await auth.confirmCode(pending.id, wrongCode),
        ApiErrorCode.verificationCodeInvalid,
        400,
      );
      expect(invalid.remainingAttempts, 4);
      final cooldown = requireFailure(
        await auth.resendCode(pending.id),
        ApiErrorCode.verificationResendTooSoon,
        429,
      );
      expect(cooldown.retryAfterSeconds, inInclusiveRange(1, 60));
    }
    final proof = await requireSuccess(auth.confirmCode(pending.id, code));
    probe.expectLast(
      'POST',
      '/auth/phone-verifications/${pending.id}/confirm',
      200,
      authenticated: false,
    );
    expect(proof.token.isNotEmpty, isTrue);
    expect(proof.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
    return proof;
  }

  Future<E2eAccount> register({
    String name = 'API Smoke',
    AvatarChoice? avatar = AvatarChoice.indigo,
    bool exerciseVerificationErrors = false,
  }) async {
    PhoneVerification? verification;
    final random = Random.secure();
    for (var attempt = 0; attempt < 30; attempt++) {
      final phone =
          '+5698765${random.nextInt(10000).toString().padLeft(4, '0')}';
      final result = await auth.requestCode(
        phone,
        VerificationPurpose.registration,
      );
      if (result case Success<PhoneVerification>(:final value)) {
        verification = value;
        break;
      }
      if (result case Failure<PhoneVerification>(
        error: ApiException(code: ApiErrorCode.phoneAlreadyRegistered),
      )) {
        continue;
      }
      await requireSuccess(Future.value(result));
    }
    if (verification == null) {
      throw TestFailure('Unable to allocate a unique mobile number.');
    }
    final proof = await verify(
      verification.phone,
      VerificationPurpose.registration,
      verification: verification,
      exerciseErrors: exerciseVerificationErrors,
    );
    const password = 'SmokePassword1!';
    final registered = await requireSuccess(
      auth.register(
        verificationToken: proof.token,
        password: password,
        name: name,
        avatar: avatar,
      ),
    );
    probe.expectLast('POST', '/auth/register', 201, authenticated: false);
    expect(registered.user.phone, verification.phone);
    expect(registered.user.name, name);
    expect(registered.user.avatar, avatar);
    expect(registered.user.activeHouseholdId, isNull);
    expect(registered.tokens.tokenType, 'bearer');
    expect(registered.tokens.expiresIn, greaterThan(0));
    expect(registered.tokens.accessToken.isNotEmpty, isTrue);
    expect(registered.tokens.refreshToken.isNotEmpty, isTrue);
    await establish(registered);
    return E2eAccount(
      phone: verification.phone,
      password: password,
      user: registered.user,
    );
  }

  Future<void> establish(AuthenticatedSession authenticated) =>
      session.establish(authenticated.tokens, authenticated.user);

  Future<void> close() async {
    final tokens = session.tokens;
    if (tokens != null) await auth.logout(tokens.refreshToken);
    await session.expire();
    container.dispose();
  }
}
