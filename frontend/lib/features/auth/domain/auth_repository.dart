import '../../../core/result/result.dart';
import '../../../core/session/session_user.dart';
import 'auth_entities.dart';

abstract interface class AuthRepository {
  Future<Result<PhoneVerification>> requestCode(
    String phone,
    VerificationPurpose purpose,
  );
  Future<Result<PhoneVerification>> resendCode(String verificationId);
  Future<Result<VerificationProof>> confirmCode(
    String verificationId,
    String code,
  );
  Future<Result<AuthenticatedSession>> register({
    required String verificationToken,
    required String password,
    required String name,
    AvatarChoice? avatar,
  });
  Future<Result<AuthenticatedSession>> login(String phone, String password);
  Future<Result<AuthenticatedSession>> resetPassword(
    String verificationToken,
    String password,
  );
  Future<Result<SessionUser>> currentUser();
  Future<Result<SessionUser>> updateAvatar(AvatarChoice? avatar);
  Future<Result<void>> logout(String refreshToken);
}
