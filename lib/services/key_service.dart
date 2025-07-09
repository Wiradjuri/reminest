import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KeyService {
  static const _keyHashKey = 'encryption_key_hash';
  static const _savedKey = 'saved_key';

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
}
