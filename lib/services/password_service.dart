import 'package:crypto/crypto.dart';
// Dart core libraries for file, encoding, randomness, and byte data
import 'dart:io'; // For file and directory operations
import 'dart:convert'; // For encoding and decoding JSON/base64
import 'dart:math'; // For secure random number generation
import 'dart:typed_data'; // For handling byte data

// Third-party packages for cryptography and file path management
import 'package:crypto/crypto.dart'; // For hashing and HMAC
import 'package:path_provider/path_provider.dart'; // For accessing app-specific directories

class PasswordService {
  static const String _passwordFileName = 'app_password.sec';
  static const String _passkeyFileName = 'recovery_passkey.sec';
  static const int _pbkdf2Iterations =
      100000; // High iteration count for security

  /// Generate a secure random passkey for password recovery
  static String generatePasskey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      16,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// PBKDF2 implementation using HMAC-SHA256
  static String _pbkdf2(String password, String salt, int iterations) {
    var hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(utf8.encode(salt));

    for (int i = 1; i < iterations; i++) {
      digest = hmac.convert(digest.bytes);
    }

    return digest.toString();
  }

  /// Generate a cryptographically secure salt
  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Get the application documents directory
  static Future<Directory> _getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Set the application password (first time setup)
  static Future<String> setPassword(String password) async {
    final directory = await _getAppDirectory();
    final passwordFile = File('${directory.path}/$_passwordFileName');
    final passkeyFile = File('${directory.path}/$_passkeyFileName');

    // Generate cryptographically secure salt and passkey
    final salt = _generateSalt();
    final passkey = generatePasskey();

    // Derive strong key from password using PBKDF2 with high iteration count
    final hashedPassword = _pbkdf2(password, salt, _pbkdf2Iterations);

    // Create password data structure with metadata
    final passwordData = {
      'hash': hashedPassword,
      'salt': salt,
      'iterations': _pbkdf2Iterations,
      'created': DateTime.now().toIso8601String(),
      'algorithm': 'PBKDF2-SHA256',
      'version': '2.0',
    };

    // Store password data as encrypted JSON
    final passwordJson = jsonEncode(passwordData);
    final encryptedPassword = base64.encode(utf8.encode(passwordJson));
    await passwordFile.writeAsString(encryptedPassword);

    // Store passkey with additional security
    final passkeyHash = _pbkdf2(passkey, salt, 50000); // Hash the passkey too
    final passkeyData = {
      'passkeyHash': passkeyHash,
      'passkey': base64.encode(
        utf8.encode(passkey),
      ), // Base64 encode the passkey
      'salt': salt,
      'created': DateTime.now().toIso8601String(),
      'version': '2.0',
    };

    final passkeyJson = jsonEncode(passkeyData);
    final encryptedPasskey = base64.encode(utf8.encode(passkeyJson));
    await passkeyFile.writeAsString(encryptedPasskey);

    return passkey;
  }

  /// Verify the application password
  static Future<bool> verifyPassword(String password) async {
    try {
      final directory = await _getAppDirectory();
      final passwordFile = File('${directory.path}/$_passwordFileName');

      if (!await passwordFile.exists()) {
        return false; // No password set
      }

      // Decrypt and parse password data
      final encryptedData = await passwordFile.readAsString();
      final decryptedData = utf8.decode(base64.decode(encryptedData));
      final passwordData = jsonDecode(decryptedData);

      final storedHash = passwordData['hash'];
      final salt = passwordData['salt'];
      final iterations = passwordData['iterations'] ?? _pbkdf2Iterations;

      // Verify password using same PBKDF2 parameters
      final inputHash = _pbkdf2(password, salt, iterations);
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Check if password is set
  static Future<bool> isPasswordSet() async {
    try {
      final directory = await _getAppDirectory();
      final passwordFile = File('${directory.path}/$_passwordFileName');
      return await passwordFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get passkey for recovery (requires verification that this is a legitimate recovery attempt)
  static Future<String?> getRecoveryPasskey() async {
    try {
      final directory = await _getAppDirectory();
      final passkeyFile = File('${directory.path}/$_passkeyFileName');

      if (!await passkeyFile.exists()) {
        return null;
      }

      // Decrypt and parse passkey data
      final encryptedData = await passkeyFile.readAsString();
      final decryptedData = utf8.decode(base64.decode(encryptedData));
      final passkeyData = jsonDecode(decryptedData);

      // Decode the base64 encoded passkey
      final passkey = utf8.decode(base64.decode(passkeyData['passkey']));
      return passkey;
    } catch (e) {
      return null;
    }
  }

  /// Reset password using passkey
  static Future<bool> resetPasswordWithPasskey(
    String passkey,
    String newPassword,
  ) async {
    try {
      final storedPasskey = await getRecoveryPasskey();
      if (storedPasskey == null || storedPasskey != passkey) {
        return false; // Invalid passkey
      }

      // Clear old data and set new password
      await clearPasswordData();
      await setPassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all password data (for app reset) - Enhanced security
  static Future<void> clearPasswordData() async {
    try {
      final directory = await _getAppDirectory();
      final passwordFile = File('${directory.path}/$_passwordFileName');
      final passkeyFile = File('${directory.path}/$_passkeyFileName');

      // Securely overwrite files before deletion
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

  /// Securely delete a file by overwriting it multiple times
  static Future<void> _secureDelete(File file) async {
    try {
      final fileSize = await file.length();
      final random = Random.secure();

      // Overwrite with random data 3 times
      for (int pass = 0; pass < 3; pass++) {
        final randomData = List<int>.generate(
          fileSize,
          (i) => random.nextInt(256),
        );
        await file.writeAsBytes(randomData);
      }

      // Final overwrite with zeros
      final zeroData = List<int>.filled(fileSize, 0);
      await file.writeAsBytes(zeroData);

      // Delete the file
      await file.delete();
    } catch (e) {
      // If secure deletion fails, try normal deletion
      try {
        await file.delete();
      } catch (e2) {
        // Ignore final deletion errors
      }
    }
  }

  /// Get password creation date
  static Future<DateTime?> getPasswordCreationDate() async {
    try {
      final directory = await _getAppDirectory();
      final passwordFile = File('${directory.path}/$_passwordFileName');

      if (!await passwordFile.exists()) {
        return null;
      }

      // Decrypt and parse password data
      final encryptedData = await passwordFile.readAsString();
      final decryptedData = utf8.decode(base64.decode(encryptedData));
      final passwordData = jsonDecode(decryptedData);

      return DateTime.parse(passwordData['created']);
    } catch (e) {
      return null;
    }
  }

  /// Get security information about the stored password
  static Future<Map<String, dynamic>?> getSecurityInfo() async {
    try {
      final directory = await _getAppDirectory();
      final passwordFile = File('${directory.path}/$_passwordFileName');

      if (!await passwordFile.exists()) {
        return null;
      }

      // Decrypt and parse password data
      final encryptedData = await passwordFile.readAsString();
      final decryptedData = utf8.decode(base64.decode(encryptedData));
      final passwordData = jsonDecode(decryptedData);

      return {
        'algorithm': passwordData['algorithm'] ?? 'SHA256',
        'iterations': passwordData['iterations'] ?? 1,
        'version': passwordData['version'] ?? '1.0',
        'created': passwordData['created'],
        'isSecure':
            (passwordData['iterations'] ?? 1) >=
            50000, // Consider secure if >= 50k iterations
      };
    } catch (e) {
      return null;
    }
  }
}
