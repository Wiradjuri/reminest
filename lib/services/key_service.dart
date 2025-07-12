import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KeyService: Manages secure storage of vault keys, passwords, and PINs.
/// Main app password is stored recoverably for user convenience.
/// Vault PIN uses cryptographic hashing and is NON-RECOVERABLE for maximum security.
class KeyService {
  static const _passwordKey = 'app_password'; // Recoverable main password
  static const _passwordSetKey = 'app_password_set';
  static const _vaultPinKey = 'vault_pin_hash'; // Non-recoverable vault PIN
  static const _vaultPinSaltKey = 'vault_pin_salt';

  // Note: We completely remove the remembered key functionality for security
  // Users must enter their password every time for maximum security

  /// Generates a cryptographically secure random salt
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Creates a salted hash of the password for secure storage
  static String _hashPasswordWithSalt(String password, String salt) {
    final saltedPassword = password + salt;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Saves the main app password in recoverable form to SharedPreferences.
  /// This password can be retrieved for "forgot password" functionality.
  static Future<void> savePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store password in a simple encoded form (not for security, just obfuscation)
      final encodedPassword = base64Encode(utf8.encode(password));

      await prefs.setString(_passwordKey, encodedPassword);
      await prefs.setBool(_passwordSetKey, true);
      print("[KeyService] App password saved (recoverable).");
    } catch (e) {
      print("[KeyService] Error saving password: $e");
    }
  }

  /// Retrieves the main app password from SharedPreferences.
  /// Returns null if no password is stored.
  static Future<String?> getPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedPassword = prefs.getString(_passwordKey);
      if (encodedPassword != null) {
        return utf8.decode(base64Decode(encodedPassword));
      }
      return null;
    } catch (e) {
      print("[KeyService] Error retrieving password: $e");
      return null;
    }
  }

  /// Alias for getPassword() - used for password recovery functionality.
  static Future<String?> getStoredPassword() async {
    return await getPassword();
  }

  /// Verifies the provided password against the stored password.
  /// Returns true if the password matches.
  static Future<bool> verifyPassword(String password) async {
    try {
      final storedPassword = await getPassword();
      return storedPassword != null && storedPassword == password;
    } catch (e) {
      print("[KeyService] Error verifying password: $e");
      return false;
    }
  }

  /// Checks if a main app password has been set.
  static Future<bool> hasPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_passwordKey) &&
          prefs.getBool(_passwordSetKey) == true;
    } catch (e) {
      print("[KeyService] Error checking password existence: $e");
      return false;
    }
  }

  /// Generates a 32-byte encryption key from the provided password.
  /// This key is used for encrypting/decrypting journal entries.
  /// The key is derived from the password but never stored.
  static List<int> generateKeyFromPassword(String password) {
    final hash = sha256.convert(utf8.encode(password)).bytes;
    return hash.sublist(0, 32);
  }

  /// Completely clears all stored password data.
  /// This makes all encrypted data permanently inaccessible.
  /// Use only for password reset functionality.
  static Future<void> clearAllPasswordData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passwordKey);
      await prefs.remove(_passwordSetKey);
      print(
        "[KeyService] All password data cleared - encrypted data is now inaccessible.",
      );
    } catch (e) {
      print("[KeyService] Error clearing password data: $e");
    }
  }

  /// Sets a flag indicating that a password has been set.
  static Future<void> setPasswordSetFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_passwordSetKey, true);
    } catch (e) {
      print("[KeyService] Error setting password flag: $e");
    }
  }

  /// Checks if the password set flag is true.
  static Future<bool> hasSetPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_passwordSetKey) ?? false;
    } catch (e) {
      print("[KeyService] Error checking password set flag: $e");
      return false;
    }
  }

  /// Saves the vault PIN securely with salt-based hashing.
  /// The PIN is never stored in plain text.
  static Future<void> saveVaultPin(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
        throw ArgumentError("PIN must be 4-6 digits.");
      }
      final prefs = await SharedPreferences.getInstance();
      final salt = _generateSalt();
      final hashedPin = _hashPasswordWithSalt(pin, salt);

      await prefs.setString(_vaultPinKey, hashedPin);
      await prefs.setString(_vaultPinSaltKey, salt);
      print("[KeyService] Vault PIN saved securely.");
    } catch (e) {
      print("[KeyService] Error saving vault PIN: $e");
    }
  }

  /// Verifies the provided PIN against the stored salted hash.
  static Future<bool> verifyVaultPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_vaultPinKey);
      final storedSalt = prefs.getString(_vaultPinSaltKey);

      if (storedHash == null || storedSalt == null) {
        return false;
      }

      final inputHash = _hashPasswordWithSalt(pin, storedSalt);
      return storedHash == inputHash;
    } catch (e) {
      print("[KeyService] Error verifying vault PIN: $e");
      return false;
    }
  }

  /// Clears the stored vault PIN and salt.
  static Future<void> clearVaultPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vaultPinKey);
      await prefs.remove(_vaultPinSaltKey);
      print("[KeyService] Vault PIN cleared.");
    } catch (e) {
      print("[KeyService] Error clearing vault PIN: $e");
    }
  }

  /// Checks if a vault PIN has been set.
  static Future<bool> hasVaultPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_vaultPinKey);
    } catch (e) {
      print("[KeyService] Error checking vault PIN existence: $e");
      return false;
    }
  }
}
