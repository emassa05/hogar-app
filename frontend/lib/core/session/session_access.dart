import 'token_pair.dart';

abstract interface class SessionAccess {
  TokenPair? get tokens;
  int get epoch;
  Future<bool> replaceTokens(TokenPair pair, {required int expectedEpoch});
  Future<void> expire({int? expectedEpoch});
}
