import 'package:flutter/foundation.dart';

import 'session_user.dart';

enum SessionStatus { restoring, unauthenticated, authenticated }

@immutable
class SessionState {
  const SessionState({this.status = SessionStatus.restoring, this.user});

  final SessionStatus status;
  final SessionUser? user;
  bool get isAuthenticated => status == SessionStatus.authenticated;
}
