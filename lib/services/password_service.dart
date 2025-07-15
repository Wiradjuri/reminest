import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PasswordService {
  static const String _passwordFileName = 'app_password.sec';
  static const String _passkeyFileName = 'recovery_passkey.sec';
  static const int _pbkdf2Iterations = 100000;

  static Directory? _overrideDirectory;

  /// Allows test injection of a mock directory
  static void overrideAppDirectory(Directory dir) {
    _overrideDirectory = dir;
  }

  /// Internal app directory getter
  static Future<Directory> _getAppDirectory() async {
    if (_overrideDirectory != null) {
      return _overrideDirectory!;
    }
    
    if (kIsWeb) {
      throw UnsupportedError('File operations not supported on web');
    }
    
    return await getApplicationDocumentsDirectory();
  }

  static String generatePasskey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String _pbkdf2(String password, String salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(utf8.encode(salt));
    for (int i = 1; i < iterations; i++) {
      digest = hmac.convert(digest.bytes);
    }
    return digest.toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  static Future<String> setPassword(String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    
    final dir = await _getAppDirectory();
    final passwordFile = File('${dir.path}/$_passwordFileName');
    final passkeyFile = File('${dir.path}/$_passkeyFileName');

    final salt = _generateSalt();
    final passkey = generatePasskey();
    final hash = _pbkdf2(password, salt, _pbkdf2Iterations);

    final passwordData = {
      'hash': hash,
      'salt': salt,
      'iterations': _pbkdf2Iterations,
      'created': DateTime.now().toIso8601String(),
      'algorithm': 'PBKDF2-SHA256',
      'version': '2.0',
    };

    final passkeyHash = _pbkdf2(passkey, salt, 50000);
    final passkeyData = {
      'passkeyHash': passkeyHash,
      'passkey': base64.encode(utf8.encode(passkey)),
      'salt': salt,
      'created': DateTime.now().toIso8601String(),
      'version': '2.0',
    };

    await passwordFile.writeAsString(base64.encode(utf8.encode(jsonEncode(passwordData))));
    await passkeyFile.writeAsString(base64.encode(utf8.encode(jsonEncode(passkeyData))));

    return passkey;
  }

  static Future<bool> verifyPassword(String password) async {
    try {
      final file = File('${(await _getAppDirectory()).path}/$_passwordFileName');
      if (!await file.exists()) return false;

      final json = jsonDecode(utf8.decode(base64.decode(await file.readAsString())));
      final inputHash = _pbkdf2(password, json['salt'], json['iterations'] ?? _pbkdf2Iterations);

      return inputHash == json['hash'];
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isPasswordSet() async {
    try {
      final file = File('${(await _getAppDirectory()).path}/$_passwordFileName');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getRecoveryPasskey() async {
    try {
      final file = File('${(await _getAppDirectory()).path}/$_passkeyFileName');
      if (!await file.exists()) return null;

      final json = jsonDecode(utf8.decode(base64.decode(await file.readAsString())));
      return utf8.decode(base64.decode(json['passkey']));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> resetPasswordWithPasskey(String passkey, String newPassword) async {
    final actual = await getRecoveryPasskey();
    if (actual == null || actual != passkey) return false;

    await clearPasswordData();
    await setPassword(newPassword);
    return true;
  }

  static Future<void> clearPasswordData() async {
    final dir = await _getAppDirectory();
    final passwordFile = File('${dir.path}/$_passwordFileName');
    final passkeyFile = File('${dir.path}/$_passkeyFileName');

    if (await passwordFile.exists()) await _secureDelete(passwordFile);
    if (await passkeyFile.exists()) await _secureDelete(passkeyFile);
  }

  static Future<void> _secureDelete(File file) async {
    try {
      final size = await file.length();
      final random = Random.secure();

      for (int i = 0; i < 3; i++) {
        await file.writeAsBytes(List<int>.generate(size, (_) => random.nextInt(256)));
      }

      await file.writeAsBytes(List.filled(size, 0));
      await file.delete();
    } catch (_) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  static Future<DateTime?> getPasswordCreationDate() async {
    try {
      final file = File('${(await _getAppDirectory()).path}/$_passwordFileName');
      if (!await file.exists()) return null;

      final json = jsonDecode(utf8.decode(base64.decode(await file.readAsString())));
      return DateTime.tryParse(json['created']);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSecurityInfo() async {
    try {
      final file = File('${(await _getAppDirectory()).path}/$_passwordFileName');
      if (!await file.exists()) return null;

      final json = jsonDecode(utf8.decode(base64.decode(await file.readAsString())));

      return {
        'algorithm': json['algorithm'] ?? 'SHA256',
        'iterations': json['iterations'] ?? 1,
        'version': json['version'] ?? '1.0',
        'created': json['created'],
        'isSecure': (json['iterations'] ?? 1) >= 50000,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPassword() async {
    await clearPasswordData();
  }
}
