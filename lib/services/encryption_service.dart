import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class EncryptionService {
  static late Uint8List _key;
  static bool _initialized = false;

  static void initializeKey(List<int> keyBytes) {
    if (_initialized) return;
    _key = Uint8List.fromList(keyBytes);
    _initialized = true;
    print("[EncryptionService] Key initialized.");
  }

  static Uint8List encrypt(Uint8List data) {
    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        true,
        ParametersWithIV(KeyParameter(_key), Uint8List(16)),
      );

    return _processBlocks(cipher, _addPadding(data));
  }

  static Uint8List decrypt(Uint8List encryptedData) {
    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        false,
        ParametersWithIV(KeyParameter(_key), Uint8List(16)),
      );

    return _removePadding(_processBlocks(cipher, encryptedData));
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (var offset = 0; offset < input.length;) {
      offset += cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }

  /// Padding for AES CBC (PKCS7)
  static Uint8List _addPadding(Uint8List data) {
    final padLength = 16 - (data.length % 16);
    return Uint8List.fromList(data + List.filled(padLength, padLength));
  }

  static Uint8List _removePadding(Uint8List data) {
    final padLength = data.last;
    return data.sublist(0, data.length - padLength);
  }

  /// ✅ Needed by your `database_service.dart`
  static String encryptText(String plainText) {
    final plainBytes = utf8.encode(plainText);
    final encryptedBytes = encrypt(Uint8List.fromList(plainBytes));
    return base64Encode(encryptedBytes);
  }

  static String decryptText(String encryptedBase64) {
    final encryptedBytes = base64Decode(encryptedBase64);
    final decryptedBytes = decrypt(encryptedBytes);
    return utf8.decode(decryptedBytes);
  }
}
