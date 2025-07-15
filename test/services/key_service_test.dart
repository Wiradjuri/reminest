import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminest/services/key_service.dart';

void main() {
  group('KeyService Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should generate cryptographic key from password', () {
      const password = 'TestPassword123!';
      final key = KeyService.generateKeyFromPassword(password);
      
      expect(key.length, equals(32)); // SHA256 produces 32 bytes
      expect(key, isA<List<int>>());
    });

    test('should generate different keys for different passwords', () {
      const password1 = 'Password1';
      const password2 = 'Password2';
      
      final key1 = KeyService.generateKeyFromPassword(password1);
      final key2 = KeyService.generateKeyFromPassword(password2);
      
      expect(key1, isNot(equals(key2)));
    });

    test('should generate same key for same password', () {
      const password = 'SamePassword';
      
      final key1 = KeyService.generateKeyFromPassword(password);
      final key2 = KeyService.generateKeyFromPassword(password);
      
      expect(key1, equals(key2));
    });

    test('should generate salt of correct length', () {
      final salt = KeyService.generateSalt();
      expect(salt, isNotEmpty);
      // Base64 encoded 32 bytes should be longer than 40 characters
      expect(salt.length, greaterThan(40));
    });

    test('should generate different salts', () {
      final salt1 = KeyService.generateSalt();
      final salt2 = KeyService.generateSalt();
      final salt3 = KeyService.generateSalt();
      
      expect(salt1, isNot(equals(salt2)));
      expect(salt2, isNot(equals(salt3)));
      expect(salt1, isNot(equals(salt3)));
    });

    test('should hash password with salt correctly', () {
      const password = 'TestPassword';
      final salt = KeyService.generateSalt();
      
      final hash = KeyService.hashPassword(password, salt);
      expect(hash, isNotEmpty);
      expect(hash.length, greaterThan(40)); // Base64 encoded hash
    });

    test('should produce different hashes for different salts', () {
      const password = 'SamePassword';
      final salt1 = KeyService.generateSalt();
      final salt2 = KeyService.generateSalt();
      
      final hash1 = KeyService.hashPassword(password, salt1);
      final hash2 = KeyService.hashPassword(password, salt2);
      
      expect(hash1, isNot(equals(hash2)));
    });

    test('should save and verify password correctly', () async {
      const password = 'TestPassword123!';
      
      await KeyService.savePassword(password);
      
      final isValid = await KeyService.verifyPassword(password);
      expect(isValid, isTrue);
      
      final isSet = await KeyService.isPasswordSet();
      expect(isSet, isTrue);
    });

    test('should reject incorrect password', () async {
      const correctPassword = 'CorrectPassword';
      const wrongPassword = 'WrongPassword';
      
      await KeyService.savePassword(correctPassword);
      
      final isValid = await KeyService.verifyPassword(wrongPassword);
      expect(isValid, isFalse);
    });

    test('should return false when no password is set', () async {
      final isSet = await KeyService.isPasswordSet();
      expect(isSet, isFalse);
      
      final isValid = await KeyService.verifyPassword('anypassword');
      expect(isValid, isFalse);
    });

    test('should clear all password data', () async {
      const password = 'TestPassword123!';
      
      await KeyService.savePassword(password);
      expect(await KeyService.isPasswordSet(), isTrue);
      
      await KeyService.clearAllPasswordData();
      
      expect(await KeyService.isPasswordSet(), isFalse);
      expect(await KeyService.verifyPassword(password), isFalse);
    });

    test('should save and verify vault PIN correctly', () async {
      const pin = '1234';
      
      await KeyService.saveVaultPin(pin);
      
      final isValid = await KeyService.verifyVaultPin(pin);
      expect(isValid, isTrue);
      
      final hasPin = await KeyService.hasVaultPin();
      expect(hasPin, isTrue);
    });

    test('should reject incorrect vault PIN', () async {
      const correctPin = '1234';
      const wrongPin = '5678';
      
      await KeyService.saveVaultPin(correctPin);
      
      final isValid = await KeyService.verifyVaultPin(wrongPin);
      expect(isValid, isFalse);
    });

    test('should return false when no vault PIN is set', () async {
      final hasPin = await KeyService.hasVaultPin();
      expect(hasPin, isFalse);
      
      final isValid = await KeyService.verifyVaultPin('1234');
      expect(isValid, isFalse);
    });

    test('should clear vault PIN', () async {
      const pin = '1234';
      
      await KeyService.saveVaultPin(pin);
      expect(await KeyService.hasVaultPin(), isTrue);
      
      await KeyService.clearVaultPin();
      
      expect(await KeyService.hasVaultPin(), isFalse);
      expect(await KeyService.verifyVaultPin(pin), isFalse);
    });

    test('should handle password hash methods correctly', () async {
      const password = 'TestPassword';
      
      await KeyService.savePasswordHash(password);
      
      final hash = await KeyService.getStoredPasswordHash();
      expect(hash, isNotEmpty);
      
      final isValid = await KeyService.verifyPasswordHash(password);
      expect(isValid, isTrue);
      
      final isInvalid = await KeyService.verifyPasswordHash('wrongpassword');
      expect(isInvalid, isFalse);
    });

    test('should handle multiple PIN operations', () async {
      const pin1 = '1111';
      const pin2 = '2222';
      
      // Set first PIN
      await KeyService.saveVaultPin(pin1);
      expect(await KeyService.verifyVaultPin(pin1), isTrue);
      expect(await KeyService.verifyVaultPin(pin2), isFalse);
      
      // Change to second PIN
      await KeyService.saveVaultPin(pin2);
      expect(await KeyService.verifyVaultPin(pin1), isFalse);
      expect(await KeyService.verifyVaultPin(pin2), isTrue);
    });

    test('should handle error cases gracefully', () async {
      // Test with null/empty values should not crash
      expect(await KeyService.verifyPassword(''), isFalse);
      expect(await KeyService.verifyVaultPin(''), isFalse);
      expect(await KeyService.verifyPasswordHash(''), isFalse);
    });
  });
}
