import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';
import 'dart:typed_data';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService', () {
    setUpAll(() {
      // Initialize the service once for all tests
      EncryptionService.initializeKey(List<int>.generate(32, (i) => i));
    });

    test('initializeKey works correctly (verified through encryption)', () {
      // Since key is already initialized, verify it works by testing encryption
      const testText = 'Test message';
      final encrypted = EncryptionService.encryptText(testText);
      final decrypted = EncryptionService.decryptText(encrypted);
      expect(decrypted, equals(testText));
    });

    test('encrypt and decrypt work correctly', () {
      final plainText = 'This is a secret message';
      final plainBytes = Uint8List.fromList(plainText.codeUnits);

      final encryptedBytes = EncryptionService.encrypt(plainBytes);
      final decryptedBytes = EncryptionService.decrypt(encryptedBytes);

      expect(decryptedBytes, equals(plainBytes));
      expect(encryptedBytes, isNot(equals(plainBytes)));
    });

    test('encryptText and decryptText work correctly', () {
      const plainText = 'This is a secret message';

      final encryptedText = EncryptionService.encryptText(plainText);
      final decryptedText = EncryptionService.decryptText(encryptedText);

      expect(decryptedText, equals(plainText));
      expect(encryptedText, isNot(equals(plainText)));
    });

    test('encrypt and decrypt handle empty strings', () {
      const plainText = '';

      final encryptedText = EncryptionService.encryptText(plainText);
      final decryptedText = EncryptionService.decryptText(encryptedText);

      expect(decryptedText, equals(plainText));
    });

    test('encrypt and decrypt handle unicode characters', () {
      const plainText = 'Unicode test: 🔒 安全性 العربية Русский 🌟';

      final encryptedText = EncryptionService.encryptText(plainText);
      final decryptedText = EncryptionService.decryptText(encryptedText);

      expect(decryptedText, equals(plainText));
    });

    test('encrypt and decrypt handle long text', () {
      final plainText = 'Long text: ' + 'A' * 10000;

      final encryptedText = EncryptionService.encryptText(plainText);
      final decryptedText = EncryptionService.decryptText(encryptedText);

      expect(decryptedText, equals(plainText));
    });

    test('same plaintext with same key produces consistent encryption', () {
      const plainText = 'Consistent encryption test';

      final encrypted1 = EncryptionService.encryptText(plainText);
      final encrypted2 = EncryptionService.encryptText(plainText);

      final decrypted1 = EncryptionService.decryptText(encrypted1);
      final decrypted2 = EncryptionService.decryptText(encrypted2);

      expect(decrypted1, equals(plainText));
      expect(decrypted2, equals(plainText));
    });

    test('decrypt throws error for invalid ciphertext', () {
      final invalidCiphertext = Uint8List.fromList([1, 2, 3, 4]);

      expect(
        () => EncryptionService.decrypt(invalidCiphertext),
        throwsA(isA<RangeError>()),
      );
    });

    test('decryptText throws error for invalid Base64 string', () {
      const invalidBase64 = 'invalid_base64_string';

      expect(
        () => EncryptionService.decryptText(invalidBase64),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
