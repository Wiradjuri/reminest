import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'dart:math';

class EncryptionService {
  static late Uint8List _key;
  static bool _initialized = false;

  /// Initializes the encryption key (must be called before encrypting or decrypting).
  static void initializeKey(List<int> keyBytes) {
    if (keyBytes.length != 32) {
      throw ArgumentError("Key must be 32 bytes for AES-256 encryption.");
    }
    _key = Uint8List.fromList(keyBytes);
    _initialized = true;
    print("[EncryptionService] Key initialized.");
  }

  /// Alternative initialization method name for consistency
  static void initWithKey(List<int> keyBytes) {
    initializeKey(keyBytes);
  }

  /// Alternative initialization for random key (e.g., in testing)
  static void initializeWithRandomKey() {
    final randomKey = _generateRandomBytes(32);
    initializeKey(randomKey);
  }

  /// Reset encryption service (for logout/reset scenarios)
  static void reset() {
    _initialized = false;
    _key = Uint8List(0);
    print("[EncryptionService] Service reset.");
  }

  /// Encrypts data using AES-256 CBC with a random IV.
  static Uint8List encrypt(Uint8List data) {
    _requireInitialized();

    final iv = _generateRandomBytes(16);
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(_key), iv));

    final padded = _addPadding(data);
    final encrypted = _processBlocks(cipher, padded);

    return Uint8List.fromList(iv + encrypted); // IV prepended
  }

  /// Decrypts data using AES-256 CBC (expects IV prepended to ciphertext).
  static Uint8List decrypt(Uint8List encryptedData) {
    _requireInitialized();

    if (encryptedData.length < 16) {
      throw FormatException("Invalid data: too short to contain IV.");
    }

    final iv = encryptedData.sublist(0, 16);
    final ciphertext = encryptedData.sublist(16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(_key), iv));

    final decrypted = _processBlocks(cipher, ciphertext);
    return _removePadding(decrypted);
  }

  /// Encrypts a plain text string and returns a Base64-encoded string.
  static String encryptText(String plainText) {
    try {
      final bytes = utf8.encode(plainText);
      final encrypted = encrypt(Uint8List.fromList(bytes));
      return base64Encode(encrypted);
    } catch (e) {
      print("[EncryptionService] Error encrypting text: $e");
      rethrow;
    }
  }

  /// Decrypts a Base64-encoded string and returns the plain text.
  static String decryptText(String encryptedBase64) {
    try {
      final bytes = base64Decode(encryptedBase64);
      final decrypted = decrypt(bytes);
      return utf8.decode(decrypted);
    } catch (e) {
      print("[EncryptionService] Error decrypting text: $e");
      rethrow;
    }
  }

  // === INTERNAL HELPERS ===

  static void _requireInitialized() {
    if (!_initialized) {
      throw StateError("Encryption key is not initialized.");
    }
  }

  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  static Uint8List _addPadding(Uint8List data) {
    final padLength = 16 - (data.length % 16);
    return Uint8List.fromList(data + List.filled(padLength, padLength));
  }

  static Uint8List _removePadding(Uint8List data) {
    final padLength = data.last;
    if (padLength < 1 || padLength > 16) {
      throw FormatException("Invalid padding length.");
    }
    return data.sublist(0, data.length - padLength);
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (int offset = 0; offset < input.length;) {
      offset += cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }
}