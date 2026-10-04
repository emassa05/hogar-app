import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/l10n/error_messages.dart';
import 'package:hogar_app/core/network/request_options.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/session/token_pair.dart';
import 'package:hogar_app/features/auth/domain/auth_entities.dart';

import 'support/contract_report.dart';
import 'support/e2e_client.dart';

Future<void> exerciseAuth(E2eClient client, ContractReport report) async {
  final account = await client.register(exerciseVerificationErrors: true);
  final current = await requireSuccess(client.auth.currentUser());
  client.probe.expectLast('GET', '/users/me', 200, authenticated: true);
  expect(current, account.user);
  expect(client.storage.tokens == client.session.tokens, isTrue);

  final avatar = await requireSuccess(
    client.auth.updateAvatar(AvatarChoice.green),
  );
  expect(avatar.avatar, AvatarChoice.green);
  final noAvatar = await requireSuccess(client.auth.updateAvatar(null));
  expect(noAvatar.avatar, isNull);

  final invalid = requireFailure(
    await client.auth.login(account.phone, 'WrongPassword1!'),
    ApiErrorCode.invalidCredentials,
    401,
  );
  client.probe.expectLast('POST', '/auth/login', 401, authenticated: false);
  expect(invalid.remainingAttempts, 4);
  expect(ErrorMessages.forException(invalid), contains('4 intentos'));
  final login = await requireSuccess(
    client.auth.login(account.phone, account.password),
  );
  client.probe.expectLast('POST', '/auth/login', 200, authenticated: false);
  await client.auth.logout(client.session.tokens!.refreshToken);
  await client.establish(login);

  for (var attempt = 1; attempt <= 4; attempt++) {
    final failure = requireFailure(
      await client.auth.login(account.phone, 'WrongPassword1!'),
      ApiErrorCode.invalidCredentials,
      401,
    );
    expect(failure.remainingAttempts, 5 - attempt);
  }
  final locked = requireFailure(
    await client.auth.login(account.phone, 'WrongPassword1!'),
    ApiErrorCode.accountLocked,
    423,
  );
  expect(locked.retryAfterSeconds, inInclusiveRange(1, 900));

  final previousRefresh = client.session.tokens!.refreshToken;
  final proof = await client.verify(
    account.phone,
    VerificationPurpose.passwordReset,
  );
  const newPassword = 'ReplacementPassword2!';
  final reset = await requireSuccess(
    client.auth.resetPassword(proof.token, newPassword),
  );
  client.probe.expectLast(
    'POST',
    '/auth/password-reset',
    200,
    authenticated: false,
  );
  expect(reset.user.id, account.user.id);
  await client.establish(reset);
  expect((await requireSuccess(client.auth.currentUser())).id, account.user.id);

  await expectInvalidRefresh(client, previousRefresh);
  requireFailure(
    await client.auth.resetPassword(proof.token, newPassword),
    ApiErrorCode.invalidVerificationToken,
    401,
  );
  expect(
    requireFailure(
      await client.auth.login(account.phone, account.password),
      ApiErrorCode.invalidCredentials,
      401,
    ).remainingAttempts,
    4,
  );
  final relogin = await requireSuccess(
    client.auth.login(account.phone, newPassword),
  );
  await requireSuccess(client.auth.logout(reset.tokens.refreshToken));
  await client.establish(relogin);
  await requireSuccess(client.auth.logout(relogin.tokens.refreshToken));
  client.probe.expectLast('POST', '/auth/logout', 204, authenticated: true);
  await report.checkLogoutReplay(client, relogin.tokens.refreshToken);
  await client.session.expire();
  expect(client.storage.tokens, isNull);
  final unauthenticated = await client.auth.currentUser();
  expect(unauthenticated, isA<Failure<SessionUser>>());
  expect(
    (unauthenticated as Failure<SessionUser>).error,
    isA<UnauthenticatedException>(),
  );
  client.probe.expectLast('GET', '/users/me', 401, authenticated: false);
  expect(
    client.probe.records.last.error?['code'],
    ApiErrorCode.unauthenticated.value,
  );
}

Future<void> expectInvalidRefresh(E2eClient client, String token) async {
  try {
    await client.dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': token},
      options: RequestOptionsFactory.public,
    );
  } on DioException catch (error) {
    final mapped = error.error;
    expect(mapped, isA<ApiException>());
    final exception = mapped! as ApiException;
    expect(exception.code, ApiErrorCode.invalidRefreshToken);
    expect(exception.statusCode, 401);
    client.probe.expectLast('POST', '/auth/refresh', 401, authenticated: false);
    return;
  }
  throw TestFailure('A reused or revoked refresh token was accepted.');
}

Future<void> exerciseRefresh(E2eClient client) async {
  final account = await client.register(name: 'Refresh Smoke', avatar: null);
  final original = client.session.tokens!;
  final baseline = await client.sms.refreshRequestCount();
  await client.session.establish(
    original.copyWith(accessToken: 'invalid-e2e-access-token'),
    account.user,
  );
  final concurrent = await Future.wait(
    List.generate(3, (_) => requireSuccess(client.auth.currentUser())),
  );
  expect(concurrent.every((user) => user.id == account.user.id), isTrue);
  expect(client.session.tokens!.refreshToken != original.refreshToken, isTrue);
  expect(client.storage.tokens == client.session.tokens, isTrue);
  expect(await client.sms.refreshRequestCount() - baseline, 1);

  final rotated = client.session.tokens!;
  final response = await client.dio.post<Map<String, dynamic>>(
    '/auth/refresh',
    data: {'refresh_token': rotated.refreshToken},
    options: RequestOptionsFactory.public,
  );
  client.probe.expectLast('POST', '/auth/refresh', 200, authenticated: false);
  final tokens = TokenPair.fromJson(response.data!);
  expect(tokens.refreshToken != rotated.refreshToken, isTrue);
  expect(tokens.accessToken.isNotEmpty, isTrue);
  expect(tokens.tokenType, 'bearer');
  expect(tokens.expiresIn, greaterThan(0));
  await client.session.establish(tokens, account.user);

  await expectInvalidRefresh(client, rotated.refreshToken);
  final revoked = await client.auth.currentUser();
  expect(revoked, isA<Failure<SessionUser>>());
  expect(
    (revoked as Failure<SessionUser>).error,
    isA<UnauthenticatedException>(),
  );
  expect(client.session.tokens, isNull);
  expect(client.storage.tokens, isNull);
}
