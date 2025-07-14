import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('KeyService Tests', () {
    setUpAll(() {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should generate key from password', () {
      const password = 'testpassword123';
      final key = KeyService.generateKeyFromPassword(password);
      
      expect(key, isNotNull);
      expect(key.length, equals(32)); // SHA256 produces 32 bytes
      
      // Same password should produce same key
      final key2 = KeyService.generateKeyFromPassword(password);
      expect(key, equals(key2));
    });

    test('should generate different keys for different passwords', () {
      const password1 = 'password1';
      const password2 = 'password2';
      
      final key1 = KeyService.generateKeyFromPassword(password1);
      final key2 = KeyService.generateKeyFromPassword(password2);
      
      expect(key1, isNot(equals(key2)));
    });

    test('should generate random salt', () {
      final salt1 = KeyService.generateSalt();
      final salt2 = KeyService.generateSalt();
      
      expect(salt1, isNotNull);
      expect(salt2, isNotNull);
      expect(salt1, isNot(equals(salt2))); // Should be different
      expect(salt1.length, greaterThan(0));
    });

    test('should hash password with salt', () {
      const password = 'mypassword';
      final salt = KeyService.generateSalt();
      
      final hash1 = KeyService.hashPassword(password, salt);
      final hash2 = KeyService.hashPassword(password, salt);
      
      expect(hash1, equals(hash2)); // Same password + salt = same hash
      expect(hash1, isNotNull);
      expect(hash1.length, greaterThan(0));
    });

    test('should produce different hashes for different salts', () {
      const password = 'mypassword';
      final salt1 = KeyService.generateSalt();
      final salt2 = KeyService.generateSalt();
      
      final hash1 = KeyService.hashPassword(password, salt1);
      final hash2 = KeyService.hashPassword(password, salt2);
      
      expect(hash1, isNot(equals(hash2)));
    });

    test('should save and verify password', () async {
      const password = 'testpassword123';
      
      await KeyService.savePassword(password);
      
      final isCorrect = await KeyService.verifyPassword(password);
      expect(isCorrect, isTrue);
      
      final isWrong = await KeyService.verifyPassword('wrongpassword');
      expect(isWrong, isFalse);
    });

    test('should check if password is set', () async {
      expect(await KeyService.isPasswordSet(), isFalse);
      
      await KeyService.savePassword('testpassword');
      expect(await KeyService.isPasswordSet(), isTrue);
    });

    test('should set and check password set flag', () async {
      expect(await KeyService.isPasswordSet(), isFalse);
      
      await KeyService.setPasswordSetFlag();
      expect(await KeyService.isPasswordSet(), isTrue);
    });

    test('should clear all password data', () async {
      const password = 'testpassword123';
      await KeyService.savePassword(password);
      expect(await KeyService.isPasswordSet(), isTrue);
      
      await KeyService.clearAllPasswordData();
      expect(await KeyService.isPasswordSet(), isFalse);
      expect(await KeyService.verifyPassword(password), isFalse);
    });

    test('should handle vault PIN operations', () async {
      const pin = '1234';
      
      expect(await KeyService.hasVaultPin(), isFalse);
      
      await KeyService.saveVaultPin(pin);
      expect(await KeyService.hasVaultPin(), isTrue);
      
      expect(await KeyService.verifyVaultPin(pin), isTrue);
      expect(await KeyService.verifyVaultPin('5678'), isFalse);
      
      await KeyService.clearVaultPin();
      expect(await KeyService.hasVaultPin(), isFalse);
    });

    test('should get password hash', () async {
      const password = 'testpassword123';
      
      expect(await KeyService.getPasswordHash(), isNull);
      
      await KeyService.savePassword(password);
      final hash = await KeyService.getPasswordHash();
      expect(hash, isNotNull);
      expect(hash!.length, greaterThan(0));
    });

    test('should handle vault PIN verification with invalid PIN', () async {
      const pin = '1234';
      
      await KeyService.saveVaultPin(pin);
      
      expect(await KeyService.verifyVaultPin(''), isFalse);
      expect(await KeyService.verifyVaultPin('wrong'), isFalse);
      expect(await KeyService.verifyVaultPin('12345'), isFalse);
    });

    test('should handle password verification without saved password', () async {
      expect(await KeyService.verifyPassword('anypassword'), isFalse);
    });

    test('should handle vault PIN verification without saved PIN', () async {
      expect(await KeyService.verifyVaultPin('1234'), isFalse);
    });
  });
}
