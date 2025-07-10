import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KeyService: Manages secure storage of vault keys, passwords, and PINs.
class KeyService {
  static const _passwordKey = 'vault_password_hash';
  static const _rememberedKeyKey = 'vault_remembered_key';
  static const _passwordSetKey = 'vault_password_set';
  static const _vaultPinKey = 'vault_pin';

  /// Saves the hashed password to SharedPreferences.
  static Future<void> savePasswordHash(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = sha256.convert(utf8.encode(password)).toString();
      await prefs.setString(_passwordKey, hash);
      print("[KeyService] Password hash saved.");
    } catch (e) {
      print("[KeyService] Error saving password hash: $e");
    }
  }

  /// Verifies the provided password against the stored hash.
  static Future<bool> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_passwordKey);
      final hash = sha256.convert(utf8.encode(password)).toString();
      return storedHash == hash;
    } catch (e) {
      print("[KeyService] Error verifying password: $e");
      return false;
    }
  }

  /// Checks if a password has been set.
  static Future<bool> hasPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_passwordKey);
    } catch (e) {
      print("[KeyService] Error checking password existence: $e");
      return false;
    }
  }

  /// Generates a 32-byte encryption key from the provided password.
  static List<int> generateKeyFromPassword(String password) {
    final hash = sha256.convert(utf8.encode(password)).bytes;
    return hash.sublist(0, 32);
  }

  /// Saves a remembered encryption key to SharedPreferences.
  static Future<void> saveRememberedKey(List<int> keyBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_rememberedKeyKey, base64Encode(keyBytes));
      print("[KeyService] Remembered key saved.");
    } catch (e) {
      print("[KeyService] Error saving remembered key: $e");
    }
  }

  /// Retrieves the remembered encryption key from SharedPreferences.
  static Future<List<int>?> getRememberedKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_rememberedKeyKey);
      if (encoded != null) {
        print("[KeyService] Remembered key loaded.");
        return base64Decode(encoded);
      }
    } catch (e) {
      print("[KeyService] Error retrieving remembered key: $e");
    }
    return null;
  }

  /// Clears the stored password and remembered key.
  static Future<void> clearPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passwordKey);
      await prefs.remove(_rememberedKeyKey);
      await prefs.remove(_passwordSetKey);
      print("[KeyService] Password and remembered key cleared.");
    } catch (e) {
      print("[KeyService] Error clearing password: $e");
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

  /// Saves the vault PIN to SharedPreferences.
  static Future<void> saveVaultPin(String pin) async {
    try {
      if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
        throw ArgumentError("PIN must be exactly 4 digits.");
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_vaultPinKey, pin);
      print("[KeyService] Vault PIN saved.");
    } catch (e) {
      print("[KeyService] Error saving vault PIN: $e");
    }
  }

  /// Verifies the provided PIN against the stored PIN.
  static Future<bool> verifyVaultPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString(_vaultPinKey);
      return storedPin == pin;
    } catch (e) {
      print("[KeyService] Error verifying vault PIN: $e");
      return false;
    }
  }

  /// Clears the stored vault PIN.
  static Future<void> clearVaultPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vaultPinKey);
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
