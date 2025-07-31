import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PasswordService {
  static Directory? _overrideDirectory;
  static const String _passwordFileName = 'app_password.sec';
  static const String _passkeyFileName = 'recovery_passkey.sec';
  static const int _iterations = 100000;
  static const String _algorithm = 'PBKDF2-SHA256';
  static const String _version = '2.0';

  /// Override the app directory for testing purposes
  static void overrideAppDirectory(Directory directory) {
    _overrideDirectory = directory;
  }

  /// Get the application directory
  static Future<Directory> _getAppDirectory() async {
    if (_overrideDirectory != null) {
      return _overrideDirectory!;
    }
    
    if (kIsWeb) {
      throw UnsupportedError('Password storage is not supported on web platform');
    }
    
    return await getApplicationDocumentsDirectory();
  }

  /// Generate a secure 16-character passkey
  static String generatePasskey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random.secure();
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Check if a password is currently set
  static Future<bool> isPasswordSet() async {
    try {
      final dir = await _getAppDirectory();
      final passwordFile = File(p.join(dir.path, _passwordFileName));
      return await passwordFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Set a new password and return the recovery passkey
  static Future<String> setPassword(String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    final dir = await _getAppDirectory();
    final passwordFile = File(p.join(dir.path, _passwordFileName));
    final passkeyFile = File(p.join(dir.path, _passkeyFileName));

    // Generate salt and passkey
    final salt = _generateSalt();
    final passkey = generatePasskey();
    final createdAt = DateTime.now().toIso8601String();

    // Hash the password
    final hashedPassword = _hashPassword(password, salt);

    // Create password data
    final passwordData = {
      'hash': hashedPassword,
      'salt': base64.encode(salt),
      'algorithm': _algorithm,
      'iterations': _iterations,
      'version': _version,
      'created': createdAt,
      'isSecure': true,
    };

    // Save password and passkey files
    await passwordFile.writeAsString(json.encode(passwordData));
    await passkeyFile.writeAsString(passkey);

    return passkey;
  }

  /// Verify a password against the stored hash
  static Future<bool> verifyPassword(String password) async {
    try {
      final dir = await _getAppDirectory();
      final passwordFile = File(p.join(dir.path, _passwordFileName));

      if (!await passwordFile.exists()) {
        return false;
      }

      final passwordData = json.decode(await passwordFile.readAsString());
      final storedHash = passwordData['hash'];
      final salt = base64.decode(passwordData['salt']);

      final inputHash = _hashPassword(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  /// Get the recovery passkey
  static Future<String?> getRecoveryPasskey() async {
    try {
      final dir = await _getAppDirectory();
      final passkeyFile = File(p.join(dir.path, _passkeyFileName));

      if (!await passkeyFile.exists()) {
        return null;
      }

      return await passkeyFile.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Reset password using the recovery passkey
  static Future<bool> resetPasswordWithPasskey(String passkey, String newPassword) async {
    try {
      final storedPasskey = await getRecoveryPasskey();
      if (storedPasskey == null || storedPasskey != passkey) {
        return false;
      }

      await setPassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get password creation date
  static Future<DateTime?> getPasswordCreationDate() async {
    try {
      final dir = await _getAppDirectory();
      final passwordFile = File(p.join(dir.path, _passwordFileName));

      if (!await passwordFile.exists()) {
        return null;
      }

      final passwordData = json.decode(await passwordFile.readAsString());
      return DateTime.parse(passwordData['created']);
    } catch (e) {
      return null;
    }
  }

  /// Get security information
  static Future<Map<String, dynamic>?> getSecurityInfo() async {
    try {
      final dir = await _getAppDirectory();
      final passwordFile = File(p.join(dir.path, _passwordFileName));

      if (!await passwordFile.exists()) {
        return null;
      }

      final passwordData = json.decode(await passwordFile.readAsString());
      return {
        'algorithm': passwordData['algorithm'],
        'iterations': passwordData['iterations'],
        'version': passwordData['version'],
        'created': passwordData['created'],
        'isSecure': passwordData['isSecure'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Clear all password data
  static Future<void> clearPasswordData() async {
    try {
      final dir = await _getAppDirectory();
      final passwordFile = File(p.join(dir.path, _passwordFileName));
      final passkeyFile = File(p.join(dir.path, _passkeyFileName));

      // Securely delete files if they exist
      if (await passwordFile.exists()) {
        await _secureDelete(passwordFile);
      }
      if (await passkeyFile.exists()) {
        await _secureDelete(passkeyFile);
      }
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  /// Alias for clearPasswordData
  static Future<void> clearPassword() async {
    await clearPasswordData();
  }

  /// Generate a random salt
  static Uint8List _generateSalt() {
    final random = math.Random.secure();
    final salt = Uint8List(32);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Hash a password with salt using PBKDF2
  static String _hashPassword(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final key = _pbkdf2(passwordBytes, salt, _iterations, 32);
    return base64.encode(key);
  }

  /// PBKDF2 implementation
  static Uint8List _pbkdf2(List<int> password, Uint8List salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password);
    final result = Uint8List(keyLength);
    var resultOffset = 0;
    var blockIndex = 1;

    while (resultOffset < keyLength) {
      final block = _pbkdf2Block(hmac, salt, iterations, blockIndex);
      final blockLength = math.min(block.length, keyLength - resultOffset);
      result.setRange(resultOffset, resultOffset + blockLength, block);
      resultOffset += blockLength;
      blockIndex++;
    }

    return result;
  }

  /// PBKDF2 block generation
  static Uint8List _pbkdf2Block(Hmac hmac, Uint8List salt, int iterations, int blockIndex) {
    final saltWithIndex = Uint8List(salt.length + 4);
    saltWithIndex.setRange(0, salt.length, salt);
    saltWithIndex[salt.length] = (blockIndex >> 24) & 0xff;
    saltWithIndex[salt.length + 1] = (blockIndex >> 16) & 0xff;
    saltWithIndex[salt.length + 2] = (blockIndex >> 8) & 0xff;
    saltWithIndex[salt.length + 3] = blockIndex & 0xff;

    var u = Uint8List.fromList(hmac.convert(saltWithIndex).bytes);
    final result = Uint8List.fromList(u);

    for (int i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  /// Securely delete a file by overwriting it with random data
  static Future<void> _secureDelete(File file) async {
    try {
      if (await file.exists()) {
        final fileSize = await file.length();
        final random = math.Random.secure();
        
        // Overwrite with random data multiple times
        for (int pass = 0; pass < 3; pass++) {
          final randomData = Uint8List(fileSize);
          for (int i = 0; i < randomData.length; i++) {
            randomData[i] = random.nextInt(256);
          }
          await file.writeAsBytes(randomData);
        }
        
        // Finally delete the file
        await file.delete();
      }
    } catch (e) {
      // If secure delete fails, try regular delete
      try {
        await file.delete();
      } catch (e) {
        // Ignore deletion errors
      }
    }
  }
}
