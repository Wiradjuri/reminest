import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  group('EncryptionService Tests', () {
    const testKey = [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
    ];

    setUp(() {
      EncryptionService.initializeKey(testKey);
    });

    test('should initialize with correct key length', () {
      expect(() => EncryptionService.initializeKey(testKey), returnsNormally);
    });

    test('should throw error with incorrect key length', () {
      const shortKey = [1, 2, 3, 4, 5];
      expect(
        () => EncryptionService.initializeKey(shortKey),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should encrypt and decrypt text correctly', () {
      const plainText = 'Hello, this is a test message for encryption!';
      
      final encrypted = EncryptionService.encryptText(plainText);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(plainText));
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should encrypt and decrypt binary data correctly', () {
      final originalData = Uint8List.fromList([1, 2, 3, 4, 5, 255, 128, 64]);
      
      final encrypted = EncryptionService.encrypt(originalData);
      expect(encrypted.length, greaterThan(originalData.length));
      
      final decrypted = EncryptionService.decrypt(encrypted);
      expect(decrypted, equals(originalData));
    });

    test('should produce different encrypted outputs for same input', () {
      const plainText = 'Same input text';
      
      final encrypted1 = EncryptionService.encryptText(plainText);
      final encrypted2 = EncryptionService.encryptText(plainText);
      
      // Should be different due to random IV
      expect(encrypted1, isNot(equals(encrypted2)));
      
      // But both should decrypt to same plaintext
      expect(EncryptionService.decryptText(encrypted1), equals(plainText));
      expect(EncryptionService.decryptText(encrypted2), equals(plainText));
    });

    test('should handle empty strings', () {
      const emptyText = '';
      
      final encrypted = EncryptionService.encryptText(emptyText);
      expect(encrypted, isNotEmpty);
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(emptyText));
    });

    test('should handle unicode characters', () {
      const unicodeText = '🔒 Secure message with émojis and spëcial chârs! 🚀';
      
      final encrypted = EncryptionService.encryptText(unicodeText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(unicodeText));
    });

    test('should handle large text blocks', () {
      final largeText = 'A' * 10000; // 10KB of text
      
      final encrypted = EncryptionService.encryptText(largeText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(largeText));
    });

    test('should throw error when not initialized', () {
      // Reset to uninitialized state
      final backup = testKey;
      
      expect(
        () => EncryptionService.encryptText('test'),
        throwsA(isA<StateError>()),
      );
      
      // Restore for other tests
      EncryptionService.initializeKey(backup);
    });

    test('should throw error on invalid encrypted data', () {
      expect(
        () => EncryptionService.decryptText('invalid_base64'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error on corrupted encrypted data', () {
      const plainText = 'Valid text';
      final encrypted = EncryptionService.encryptText(plainText);
      
      // Corrupt the encrypted data
      final corruptedData = encrypted.substring(0, encrypted.length - 5) + 'XXXXX';
      
      expect(
        () => EncryptionService.decryptText(corruptedData),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle data with only IV (too short)', () {
      final shortData = Uint8List.fromList([1, 2, 3, 4, 5]); // Less than 16 bytes
      
      expect(
        () => EncryptionService.decrypt(shortData),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
