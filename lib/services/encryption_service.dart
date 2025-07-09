import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';

class EncryptionService {
  static late encrypt.Encrypter _encrypter;
  static late encrypt.IV _iv;
  static bool _isInitialized = false;

  static void initializeKey(List<int> keyBytes) {
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _isInitialized = true;
  }

  static String encryptText(String plainText) {
    if (!_isInitialized) {
      throw Exception("EncryptionService not initialized");
    }
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    if (!_isInitialized) {
      throw Exception("EncryptionService not initialized");
    }
    final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
