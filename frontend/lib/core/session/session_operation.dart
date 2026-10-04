import '../errors/app_exception.dart';
import 'session_access.dart';

class SessionOperation {
  SessionOperation(this.session, {required this.isAlive})
    : epoch = session.epoch;
  final SessionAccess session;
  final bool Function() isAlive;
  final int epoch;
  bool get isCurrent => isAlive() && session.epoch == epoch;
  void checkCurrent() {
    if (!isCurrent) throw const NetworkException(NetworkFailure.cancelled);
  }
}
