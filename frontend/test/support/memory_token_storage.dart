import 'package:hogar_app/core/session/token_pair.dart';
import 'package:hogar_app/core/storage/token_storage.dart';

class MemoryTokenStorage implements TokenStorage {
  TokenPair? tokens;
  bool failWrites = false;
  @override
  Future<TokenPair?> read() async => tokens;
  @override
  Future<void> write(TokenPair tokens) async {
    if (failWrites) throw StateError('storage unavailable');
    this.tokens = tokens;
  }

  @override
  Future<void> clear() async => tokens = null;
}
