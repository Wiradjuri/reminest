import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyService {
  static const String _passwordHashKey = 'password_hash';
  static const String _passwordSaltKey = 'password_salt';
  static const String _passwordSetKey = 'password_set';
  static const String _vaultPinKey = 'vault_pin';
  static const String _vaultPinSetKey = 'vault_pin_set';

  // Generate a cryptographic key from password
  static List<int> generateKeyFromPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }

  // Generate random salt
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  // Hash password with salt
  static String hashPassword(String password, String salt) {
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);
    final combined = [...passwordBytes, ...saltBytes];
    final digest = sha256.convert(combined);
    return base64Encode(digest.bytes);
  }

  // Save password hash and salt
  static Future<void> savePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = generateSalt();
      final hash = hashPassword(password, salt);

      await prefs.setString(_passwordHashKey, hash);
      await prefs.setString(_passwordSaltKey, salt);
      await prefs.setBool(_passwordSetKey, true);
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }

  // Get stored password hash
  static Future<String?> getPasswordHash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_passwordHashKey);
    } catch (e) {
      throw Exception('Failed to get password hash: $e');
    }
  }

  // Verify password against stored hash
  static Future<bool> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_passwordHashKey);
      final salt = prefs.getString(_passwordSaltKey);

      if (storedHash == null || salt == null) return false;

      final inputHash = hashPassword(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  // Check if password is set
  static Future<bool> isPasswordSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_passwordSetKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Set password set flag
  static Future<void> setPasswordSetFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_passwordSetKey, true);
    } catch (e) {
      throw Exception('Failed to set password flag: $e');
    }
  }

  // Clear all password data
  static Future<void> clearAllPasswordData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passwordHashKey);
      await prefs.remove(_passwordSaltKey);
      await prefs.remove(_passwordSetKey);
    } catch (e) {
      throw Exception('Failed to clear password data: $e');
    }
  }

  // Vault PIN methods
  static Future<void> saveVaultPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = generateSalt();
      final hash = hashPassword(pin, salt);

      await prefs.setString(_vaultPinKey, hash);
      await prefs.setString('${_vaultPinKey}_salt', salt);
      await prefs.setBool(_vaultPinSetKey, true);
    } catch (e) {
      throw Exception('Failed to save vault PIN: $e');
    }
  }

  static Future<bool> verifyVaultPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_vaultPinKey);
      final salt = prefs.getString('${_vaultPinKey}_salt');

      if (storedHash == null || salt == null) return false;

      final inputHash = hashPassword(pin, salt);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasVaultPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_vaultPinSetKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearVaultPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vaultPinKey);
      await prefs.remove('${_vaultPinKey}_salt');
      await prefs.remove(_vaultPinSetKey);
    } catch (e) {
      throw Exception('Failed to clear vault PIN: $e');
    }
  }

  // Additional methods for test compatibility
  static Future<void> savePasswordHash(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = generateSalt();
      final hash = hashPassword(password, salt);
      
      await prefs.setString('password_hash_only', hash);
      await prefs.setString('password_hash_salt', salt);
    } catch (e) {
      throw Exception('Failed to save password hash: $e');
    }
  }

  static Future<String?> getStoredPasswordHash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('password_hash_only');
    } catch (e) {
      return null;
    }
  }

  static Future<bool> verifyPasswordHash(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('password_hash_only');
      final salt = prefs.getString('password_hash_salt');

      if (storedHash == null || salt == null) return false;

      final inputHash = hashPassword(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }
}
