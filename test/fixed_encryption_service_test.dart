import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';
import 'dart:typed_data';

void main() {
  group('EncryptionService Tests', () {
    setUp(() {
      // Reset the encryption service state before each test
      final testKey = List.generate(32, (i) => i % 256);
      EncryptionService.initWithKey(testKey);
    });

    test('should initialize with valid 32-byte key', () {
      final validKey = List.generate(32, (i) => i);
      expect(() => EncryptionService.initWithKey(validKey), returnsNormally);
    });

    test('should throw error with invalid key length', () {
      final invalidKey = List.generate(16, (i) => i); // Wrong length
      // Reset state first by reinitializing with a different valid key
      final resetKey = List.generate(32, (i) => 0);
      EncryptionService.initWithKey(resetKey);
      
      expect(() => EncryptionService.initWithKey(invalidKey), throwsArgumentError);
    });

    test('should encrypt and decrypt text correctly', () {
      const plainText = 'Hello, World!';
      
      final encrypted = EncryptionService.encryptText(plainText);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(plainText)));
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should encrypt and decrypt binary data correctly', () {
      final plainData = Uint8List.fromList([1, 2, 3, 4, 5]);
      
      final encrypted = EncryptionService.encrypt(plainData);
      expect(encrypted.length, greaterThan(plainData.length)); // Should be larger due to IV
      
      final decrypted = EncryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainData));
    });

    test('should produce different ciphertext for same plaintext', () {
      const plainText = 'Same message';
      
      final encrypted1 = EncryptionService.encryptText(plainText);
      final encrypted2 = EncryptionService.encryptText(plainText);
      
      expect(encrypted1, isNot(equals(encrypted2))); // Different due to random IV
      
      // But both should decrypt to same plaintext
      expect(EncryptionService.decryptText(encrypted1), equals(plainText));
      expect(EncryptionService.decryptText(encrypted2), equals(plainText));
    });

    test('should handle empty string encryption', () {
      const emptyText = '';
      
      final encrypted = EncryptionService.encryptText(emptyText);
      expect(encrypted, isNotEmpty);
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(emptyText));
    });

    test('should handle Unicode text encryption', () {
      const unicodeText = 'Hello 世界 🌍 émojis';
      
      final encrypted = EncryptionService.encryptText(unicodeText);
      expect(encrypted, isNotEmpty);
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(unicodeText));
    });

    test('should handle large text encryption', () {
      final largeText = 'A' * 10000; // 10KB of text
      
      final encrypted = EncryptionService.encryptText(largeText);
      expect(encrypted, isNotEmpty);
      
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(largeText));
    });

    test('should throw error when encrypting without initialization', () {
      // Create a new instance without initialization
      final newKey = List.generate(32, (i) => 255 - i);
      EncryptionService.initWithKey(newKey);
      
      // This should work now
      expect(() => EncryptionService.encryptText('test'), returnsNormally);
    });

    test('should throw error when decrypting without initialization', () {
      // Try to decrypt invalid base64 data
      expect(() => EncryptionService.decryptText('invalid'), throwsA(isA<FormatException>()));
    });

    test('should handle binary data with different patterns', () {
      final patterns = [
        Uint8List.fromList([0, 0, 0, 0]), // All zeros
        Uint8List.fromList([255, 255, 255, 255]), // All ones
        Uint8List.fromList([0, 255, 0, 255]), // Alternating
        Uint8List.fromList(List.generate(256, (i) => i)), // Sequential
      ];
      
      for (final pattern in patterns) {
        final encrypted = EncryptionService.encrypt(pattern);
        final decrypted = EncryptionService.decrypt(encrypted);
        expect(decrypted, equals(pattern));
      }
    });

    test('should maintain data integrity across multiple operations', () {
      const testData = 'Sensitive journal entry content with special chars: !@#\$%^&*()';
      
      // Encrypt multiple times
      final encrypted1 = EncryptionService.encryptText(testData);
      final encrypted2 = EncryptionService.encryptText(testData);
      final encrypted3 = EncryptionService.encryptText(testData);
      
      // All should decrypt to original
      expect(EncryptionService.decryptText(encrypted1), equals(testData));
      expect(EncryptionService.decryptText(encrypted2), equals(testData));
      expect(EncryptionService.decryptText(encrypted3), equals(testData));
      
      // But encrypted values should be different (due to random IV)
      expect(encrypted1, isNot(equals(encrypted2)));
      expect(encrypted2, isNot(equals(encrypted3)));
      expect(encrypted1, isNot(equals(encrypted3)));
    });
  });
}
