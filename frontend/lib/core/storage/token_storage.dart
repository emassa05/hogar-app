import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/token_pair.dart';

part 'token_storage.g.dart';

abstract interface class TokenStorage {
  Future<TokenPair?> read();
  Future<void> write(TokenPair tokens);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this.storage);
  final FlutterSecureStorage storage;
  static const _key = 'session_token_pair';

  @override
  Future<TokenPair?> read() async {
    final raw = await storage.read(key: _key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw const FormatException();
      final pair = TokenPair.fromJson(json);
      if (pair.accessToken.isEmpty || pair.refreshToken.isEmpty) {
        throw const FormatException();
      }
      return pair;
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(TokenPair tokens) =>
      storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => storage.delete(key: _key);
}

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => const SecureTokenStorage(
  FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);
