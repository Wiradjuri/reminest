import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KeyService {
  static const _keyHashKey = 'encryption_key_hash';
  static const _savedKey = 'saved_key';
  static const _hasSetPasswordKey = 'has_set_password';
  static const _vaultPinKey = 'vault_pin_hash';

  static List<int> generateKeyFromPassword(String password) {
    return sha256.convert(utf8.encode(password)).bytes;
  }

  static Future<void> savePasswordHash(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = sha256.convert(utf8.encode(password)).toString();
    await prefs.setString(_keyHashKey, hash);
  }

  static Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_keyHashKey);
    final hash = sha256.convert(utf8.encode(password)).toString();
    return storedHash == hash;
  }

  static Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyHashKey);
  }

  static Future<void> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHashKey);
    await prefs.remove(_savedKey);
    await prefs.remove(_hasSetPasswordKey);
    await prefs.remove(_vaultPinKey);
  }

  static Future<void> saveRememberedKey(List<int> keyBytes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_savedKey, base64Encode(keyBytes));
  }

  static Future<List<int>?> getRememberedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final keyString = prefs.getString(_savedKey);
    if (keyString != null) {
      return base64Decode(keyString);
    }
    return null;
  }

  static Future<void> setPasswordSetFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSetPasswordKey, true);
  }

  static Future<bool> hasSetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSetPasswordKey) ?? false;
  }

  // ✅ Vault PIN management
  static Future<void> saveVaultPin(String pin) async {
    if (pin.length != 4) throw Exception("PIN must be 4 digits.");
    final prefs = await SharedPreferences.getInstance();
    final hash = sha256.convert(utf8.encode(pin)).toString();
    await prefs.setString(_vaultPinKey, hash);
  }

  static Future<bool> verifyVaultPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_vaultPinKey);
    final hash = sha256.convert(utf8.encode(pin)).toString();
    return storedHash == hash;
  }

  static Future<bool> hasVaultPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_vaultPinKey);
  }

  static Future<void> clearVaultPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vaultPinKey);
  }
}
