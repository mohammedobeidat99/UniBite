import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Cryptographic utility for salted SHA-256 password hashing in GP1 local auth.
///
/// Stored hashes follow the `<salt>$<digest>` format so no plain-text password
/// is ever persisted to local storage.
class PasswordHasher {
  PasswordHasher._();

  static final Random _random = Random.secure();

  /// Generates a random 16-byte Base64-encoded salt.
  static String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Hashes [password] with a provided or randomly generated [salt].
  static String hashPassword(String password, {String? salt}) {
    final effectiveSalt = salt ?? generateSalt();
    final payload = utf8.encode('$effectiveSalt:$password');
    final digest = sha256.convert(payload).toString();
    return '$effectiveSalt\$$digest';
  }

  /// Verifies whether [password] matches [storedHash].
  static bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split('\$');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final expected = hashPassword(password, salt: salt);
    return _constantTimeEquals(expected, storedHash);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
