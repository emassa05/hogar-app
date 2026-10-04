import 'package:flutter/foundation.dart';

import '../../../core/session/session_user.dart';
import '../../../core/session/token_pair.dart';

enum VerificationPurpose { registration, passwordReset }

@immutable
class PhoneVerification {
  const PhoneVerification({required this.id, required this.phone, required this.purpose, required this.expiresAt, required this.resendAvailableAt});
  final String id;
  final String phone;
  final VerificationPurpose purpose;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
  PhoneVerification withResendAt(DateTime date) => PhoneVerification(id: id, phone: phone, purpose: purpose, expiresAt: expiresAt, resendAvailableAt: date);
}

@immutable
class VerificationProof {
  const VerificationProof({required this.token, required this.expiresAt});
  final String token;
  final DateTime expiresAt;
}

@immutable
class AuthenticatedSession {
  const AuthenticatedSession({required this.user, required this.tokens});
  final SessionUser user;
  final TokenPair tokens;
}
