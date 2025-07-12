import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    test('encrypt and decrypt returns original text', () {
      final plainText = 'super_secret_password';
      final password = 'testpassword';
      final encrypted = EncryptionService.encrypt(plainText, password);
      final decrypted = EncryptionService.decrypt(encrypted, password);
      expect(decrypted, plainText);
    });

    test('generateRandomKey returns key of length 32', () {
      final key = EncryptionService.generateRandomKey();
      expect(key.length, 32);
    });
  });
}
