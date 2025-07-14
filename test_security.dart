import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';

void main() {
  group('Password Security Tests', () {
    test('password storage and retrieval', () async {
      const testPassword = 'testPassword123';
      
      // Test password saving
      await KeyService.savePassword(testPassword);
      
      // Test password verification
      final isValid = await KeyService.verifyPassword(testPassword);
      expect(isValid, true);
      
      // Test wrong password
      final isWrong = await KeyService.verifyPassword('wrongPassword');
      expect(isWrong, false);
    });

    test('password hashing consistency', () async {
      const testPassword = 'testPassword123';
      
      // Save password twice
      await KeyService.savePassword(testPassword);
      final firstHash = await KeyService.getPasswordHash();
      
      await KeyService.savePassword(testPassword);
      final secondHash = await KeyService.getPasswordHash();
      
      // Hashes should be different due to salt
      expect(firstHash != secondHash, true);
      
      // But verification should still work
      final isValid = await KeyService.verifyPassword(testPassword);
      expect(isValid, true);
    });

    test('key generation from password', () {
      const password1 = 'password123';
      const password2 = 'password456';
      
      final key1 = KeyService.generateKeyFromPassword(password1);
      final key2 = KeyService.generateKeyFromPassword(password2);
      final key1Again = KeyService.generateKeyFromPassword(password1);
      
      // Same password should generate same key
      expect(key1, equals(key1Again));
      
      // Different passwords should generate different keys
      expect(key1, isNot(equals(key2)));
    });
  });
}
