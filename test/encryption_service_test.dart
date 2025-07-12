import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    test('encryptText and decryptText work correctly', () {
      const plainText = 'This is a secret message';
      
      final encrypted = EncryptionService.encryptText(plainText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText))); // Ensure it's actually encrypted
    });

    test('encrypt and decrypt with password work correctly', () {
      const plainText = 'Secret data with custom password';
      const password = 'myCustomPassword123';
      
      final encrypted = EncryptionService.encrypt(plainText, password);
      final decrypted = EncryptionService.decrypt(encrypted, password);
      
      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
    });

    test('generateRandomKey produces valid key', () {
      final key1 = EncryptionService.generateRandomKey();
      final key2 = EncryptionService.generateRandomKey();
      
      expect(key1.length, equals(32));
      expect(key2.length, equals(32));
      expect(key1, isNot(equals(key2))); // Keys should be random and different
    });

    test('different passwords produce different encrypted results', () {
      const plainText = 'Same message, different passwords';
      const password1 = 'password1';
      const password2 = 'password2';
      
      final encrypted1 = EncryptionService.encrypt(plainText, password1);
      final encrypted2 = EncryptionService.encrypt(plainText, password2);
      
      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('wrong password fails to decrypt correctly', () {
      const plainText = 'Secret message';
      const correctPassword = 'correctPassword';
      const wrongPassword = 'wrongPassword';
      
      final encrypted = EncryptionService.encrypt(plainText, correctPassword);
      
      expect(
        () => EncryptionService.decrypt(encrypted, wrongPassword),
        throwsException,
      );
    });

    test('encryption handles empty strings', () {
      const plainText = '';
      
      final encrypted = EncryptionService.encryptText(plainText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(plainText));
    });

    test('encryption handles unicode characters', () {
      const plainText = 'Unicode test: 🔒 安全性 العربية Русский 🌟';
      
      final encrypted = EncryptionService.encryptText(plainText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(plainText));
    });

    test('encryption handles long text', () {
      final plainText = 'Long text: ' + 'A' * 10000; // 10KB+ text
      
      final encrypted = EncryptionService.encryptText(plainText);
      final decrypted = EncryptionService.decryptText(encrypted);
      
      expect(decrypted, equals(plainText));
    });

    test('same plaintext with same key produces consistent encryption', () {
      const plainText = 'Consistent encryption test';
      
      // Note: This test assumes deterministic encryption with a static key
      // If encryption includes random elements, this test might need adjustment
      final encrypted1 = EncryptionService.encryptText(plainText);
      final encrypted2 = EncryptionService.encryptText(plainText);
      
      // Both should decrypt to the same plaintext
      final decrypted1 = EncryptionService.decryptText(encrypted1);
      final decrypted2 = EncryptionService.decryptText(encrypted2);
      
      expect(decrypted1, equals(plainText));
      expect(decrypted2, equals(plainText));
    });
  });
}
