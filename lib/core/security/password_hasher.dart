import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Minimal password hasher for learning purpose.
/// Stores values as: salt:hash
class PasswordHasher {
  const PasswordHasher();

  String hash(String plainPassword) {
    final salt = _randomSalt();
    final digest = sha256.convert(utf8.encode('$salt:$plainPassword')).toString();
    return '$salt:$digest';
  }

  bool verify({
    required String plainPassword,
    required String storedValue,
  }) {
    final parts = storedValue.split(':');
    if (parts.length != 2) return false;
    final salt = parts.first;
    final expectedHash = parts.last;
    final actualHash = sha256.convert(utf8.encode('$salt:$plainPassword')).toString();
    return actualHash == expectedHash;
  }

  String _randomSalt() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
