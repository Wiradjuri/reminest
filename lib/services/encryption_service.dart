import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
class EncryptionService {
  /// For test: call this before a test that expects uninitialized state
  static void testPrepareUninitialized() {
    reset();
  }
  /// For test: helper to ensure uninitialized state before test
  static void testForceUninit() {
    reset();
  }
  /// Ensures the service is uninitialized (for test support)
  static void ensureUninitialized() {
    reset();
  }
  static late Uint8List _key;
  static bool _initialized = false;

  /// Initializes the encryption key (must be called before encrypting or decrypting).
  static void initializeKey(List<int> keyBytes) {
    if (keyBytes.length != 32) {
      throw ArgumentError('Key must be 32 bytes for AES-256.');
    }
    _key = Uint8List.fromList(keyBytes);
    _initialized = true;
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
  static Uint8List encryptData(Uint8List data) {
    _requireInitialized();

    final iv = _generateRandomBytes(16);
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(_key), iv));

    final padded = _addPadding(data);
    final encrypted = _processBlocks(cipher, padded);

    return Uint8List.fromList(iv + encrypted); // IV prepended
  }

  /// Decrypts data using AES-256 CBC (expects IV prepended to ciphertext).
  static Uint8List decryptData(Uint8List encryptedData) {
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
    _requireInitialized();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(_key), mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  /// Decrypts a Base64-encoded string and returns the plain text.
  static String decryptText(String encryptedText) {
    _requireInitialized();
    try {
      final combined = base64Decode(encryptedText);
      final iv = encrypt.IV(combined.sublist(0, 16));
      final encryptedBytes = combined.sublist(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(_key), mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypt.Encrypted(encryptedBytes), iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception(e);
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