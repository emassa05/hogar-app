import 'package:dio/dio.dart';

import '../../../core/network/request_options.dart';
import '../../../core/session/session_user.dart';
import '../domain/auth_entities.dart';
import 'auth_dtos.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this.client);
  final Dio client;

  Future<Map<String, dynamic>> _publicPost(String path, Object? body) async {
    final response = await client.post<Map<String, dynamic>>(path, data: body, options: RequestOptionsFactory.public);
    return response.data!;
  }
  Future<PhoneVerificationDto> requestCode(String phone, VerificationPurpose purpose) async => PhoneVerificationDto.fromJson(await _publicPost('/auth/phone-verifications', {'phone': phone, 'purpose': purpose == VerificationPurpose.registration ? 'registration' : 'password_reset'}));
  Future<PhoneVerificationDto> resendCode(String id) async => PhoneVerificationDto.fromJson(await _publicPost('/auth/phone-verifications/$id/resend', null));
  Future<VerificationTokenDto> confirmCode(String id, String code) async => VerificationTokenDto.fromJson(await _publicPost('/auth/phone-verifications/$id/confirm', {'code': code}));
  Future<AuthSessionDto> register({required String verificationToken, required String password, required String name, AvatarChoice? avatar}) async => AuthSessionDto.fromJson(await _publicPost('/auth/register', {'verification_token': verificationToken, 'password': password, 'name': name, 'avatar': avatar?.name}));
  Future<AuthSessionDto> login(String phone, String password) async => AuthSessionDto.fromJson(await _publicPost('/auth/login', {'phone': phone, 'password': password}));
  Future<AuthSessionDto> resetPassword(String token, String password) async => AuthSessionDto.fromJson(await _publicPost('/auth/password-reset', {'verification_token': token, 'new_password': password}));
  Future<SessionUser> currentUser() async => SessionUser.fromJson((await client.get<Map<String, dynamic>>('/users/me')).data!);
  Future<SessionUser> updateAvatar(AvatarChoice? avatar) async => SessionUser.fromJson((await client.patch<Map<String, dynamic>>('/users/me', data: {'avatar': avatar?.name})).data!);
  Future<void> logout(String refreshToken) async { await client.post<void>('/auth/logout', data: {'refresh_token': refreshToken}); }
}
