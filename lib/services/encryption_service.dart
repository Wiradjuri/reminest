import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'dart:math';

class EncryptionService {
  static late Uint8List _key;
  static bool _initialized = false;

  /// Initializes the encryption key (must be called before encrypting or decrypting).
  static void initializeKey(List<int> keyBytes) {
    if (_initialized) return;
    if (keyBytes.length != 32) {
      throw ArgumentError("Key must be 32 bytes for AES-256 encryption.");
    }
    _key = Uint8List.fromList(keyBytes);
    _initialized = true;
    print("[EncryptionService] Key initialized.");
  }

  /// Encrypts data using AES-256 CBC with a random IV.
  static Uint8List encrypt(Uint8List data) {
    if (!_initialized) {
      throw StateError("Encryption key is not initialized.");
    }

    // Generate a random 16-byte IV
    final iv = _generateRandomBytes(16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        true,
        ParametersWithIV(KeyParameter(_key), iv),
      );

    // Encrypt the data with padding
    final encryptedData = _processBlocks(cipher, _addPadding(data));

    // Prepend the IV to the encrypted data
    return Uint8List.fromList(iv + encryptedData);
  }

  /// Decrypts data using AES-256 CBC (expects IV prepended to ciphertext).
  static Uint8List decrypt(Uint8List encryptedData) {
    if (!_initialized) {
      throw StateError("Encryption key is not initialized.");
    }

    // Extract the IV (first 16 bytes) and the ciphertext
    final iv = encryptedData.sublist(0, 16);
    final ciphertext = encryptedData.sublist(16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        false,
        ParametersWithIV(KeyParameter(_key), iv),
      );

    // Decrypt the data and remove padding
    return _removePadding(_processBlocks(cipher, ciphertext));
  }

  /// Processes data in blocks for encryption or decryption.
  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (var offset = 0; offset < input.length;) {
      offset += cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }

  /// Adds PKCS7 padding to the data.
  static Uint8List _addPadding(Uint8List data) {
    final padLength = 16 - (data.length % 16);
    return Uint8List.fromList(data + List.filled(padLength, padLength));
  }

  /// Removes PKCS7 padding from the data.
  static Uint8List _removePadding(Uint8List data) {
    final padLength = data.last;
    if (padLength < 1 || padLength > 16) {
      throw FormatException("Invalid padding length.");
    }
    return data.sublist(0, data.length - padLength);
  }

  /// Encrypts a plain text string and returns a Base64-encoded string.
  static String encryptText(String plainText) {
    try {
      final plainBytes = utf8.encode(plainText);
      final encryptedBytes = encrypt(Uint8List.fromList(plainBytes));
      return base64Encode(encryptedBytes);
    } catch (e) {
      print("[EncryptionService] Error encrypting text: $e");
      rethrow;
    }
  }

  /// Decrypts a Base64-encoded string and returns the plain text.
  static String decryptText(String encryptedBase64) {
    try {
      final encryptedBytes = base64Decode(encryptedBase64);
      final decryptedBytes = decrypt(encryptedBytes);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      print("[EncryptionService] Error decrypting text: $e");
      rethrow;
    }
  }

  /// Generates a list of random bytes of the specified length.
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }
}
