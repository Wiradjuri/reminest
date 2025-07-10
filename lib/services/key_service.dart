import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyService {
  static const _passwordKey = 'vault_password_hash';
  static const _rememberedKeyKey = 'vault_remembered_key';
  static const _passwordSetKey = 'vault_password_set';
  static const _vaultPinKey = 'vault_pin';

  static Future<void> savePasswordHash(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = sha256.convert(utf8.encode(password)).toString();
    await prefs.setString(_passwordKey, hash);
    print("[KeyService] Password hash saved.");
  }

  static Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_passwordKey);
    final hash = sha256.convert(utf8.encode(password)).toString();
    return storedHash == hash;
  }

  static Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passwordKey);
  }

  static List<int> generateKeyFromPassword(String password) {
    final hash = sha256.convert(utf8.encode(password)).bytes;
    return hash.sublist(0, 32);
  }

  static Future<void> saveRememberedKey(List<int> keyBytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedKeyKey, base64Encode(keyBytes));
    print("[KeyService] Remembered key saved.");
  }

  static Future<List<int>?> getRememberedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_rememberedKeyKey);
    if (encoded != null) {
      print("[KeyService] Remembered key loaded.");
      return base64Decode(encoded);
    }
    return null;
  }

  static Future<void> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
    await prefs.remove(_rememberedKeyKey);
    await prefs.remove(_passwordSetKey);
    print("[KeyService] Password and remembered key cleared.");
  }

  static Future<void> setPasswordSetFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passwordSetKey, true);
  }

  static Future<bool> hasSetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_passwordSetKey) ?? false;
  }

  static Future<void> saveVaultPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vaultPinKey, pin);
  }

  static Future<bool> verifyVaultPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_vaultPinKey);
    return storedPin == pin;
  }

  static Future<void> clearVaultPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vaultPinKey);
  }

  static Future<bool> hasVaultPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_vaultPinKey);
  }

  /*
  // 🔹 If you had additional vault key encryption/decryption helpers here,
  // and your codebase uses them, uncomment them below.
  */
}
