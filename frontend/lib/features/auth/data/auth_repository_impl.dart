import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/result/result.dart';
import '../../../core/session/session_user.dart';
import '../domain/auth_entities.dart';
import '../domain/auth_repository.dart';
import 'auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remote);
  final AuthRemoteDataSource remote;
  @override
  Future<Result<PhoneVerification>> requestCode(String phone, VerificationPurpose purpose) => capture(() async => (await remote.requestCode(phone, purpose)).toDomain());
  @override
  Future<Result<PhoneVerification>> resendCode(String verificationId) => capture(() async => (await remote.resendCode(verificationId)).toDomain());
  @override
  Future<Result<VerificationProof>> confirmCode(String verificationId, String code) => capture(() async => (await remote.confirmCode(verificationId, code)).toDomain());
  @override
  Future<Result<AuthenticatedSession>> register({required String verificationToken, required String password, required String name, AvatarChoice? avatar}) => capture(() async => (await remote.register(verificationToken: verificationToken, password: password, name: name, avatar: avatar)).toDomain());
  @override
  Future<Result<AuthenticatedSession>> login(String phone, String password) => capture(() async => (await remote.login(phone, password)).toDomain());
  @override
  Future<Result<AuthenticatedSession>> resetPassword(String verificationToken, String password) => capture(() async => (await remote.resetPassword(verificationToken, password)).toDomain());
  @override
  Future<Result<SessionUser>> currentUser() => capture(remote.currentUser);
  @override
  Future<Result<SessionUser>> updateAvatar(AvatarChoice? avatar) => capture(() => remote.updateAvatar(avatar));
  @override
  Future<Result<void>> logout(String refreshToken) => capture(() => remote.logout(refreshToken));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(AuthRemoteDataSource(ref.watch(dioClientProvider)));
