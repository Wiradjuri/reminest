import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyService', () {
    setUp(() async {
      // Clear all stored data before each test
      await KeyService.clearAllPasswordData();
    });

    tearDown(() async {
      // Clean up after each test
      await KeyService.clearAllPasswordData();
    });

    test('savePassword and getPassword work correctly', () async {
      const testPassword = 'mySecurePassword123';
      
      await KeyService.savePassword(testPassword);
      final retrievedPassword = await KeyService.getPassword();
      
      expect(retrievedPassword, equals(testPassword));
    });

    test('getPassword returns null when no password is saved', () async {
      final retrievedPassword = await KeyService.getPassword();
      expect(retrievedPassword, isNull);
    });

    test('saveRememberedKey and getRememberedKey work correctly', () async {
      final testKey = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      
      await KeyService.saveRememberedKey(testKey);
      final retrievedKey = await KeyService.getRememberedKey();
      
      expect(retrievedKey, equals(testKey));
    });

    test('getRememberedKey returns null when no key is saved', () async {
      final retrievedKey = await KeyService.getRememberedKey();
      expect(retrievedKey, isNull);
    });

    test('clearAllPasswordData removes all stored data', () async {
      const testPassword = 'passwordToBeCleared';
      final testKey = [100, 200, 300];
      
      // Save data
      await KeyService.savePassword(testPassword);
      await KeyService.saveRememberedKey(testKey);
      
      // Verify data is saved
      expect(await KeyService.getPassword(), equals(testPassword));
      expect(await KeyService.getRememberedKey(), equals(testKey));
      
      // Clear all data
      await KeyService.clearAllPasswordData();
      
      // Verify data is cleared
      expect(await KeyService.getPassword(), isNull);
      expect(await KeyService.getRememberedKey(), isNull);
    });

    test('password storage handles empty string', () async {
      const emptyPassword = '';
      
      await KeyService.savePassword(emptyPassword);
      final retrievedPassword = await KeyService.getPassword();
      
      expect(retrievedPassword, equals(emptyPassword));
    });

    test('key storage handles empty list', () async {
      final emptyKey = <int>[];
      
      await KeyService.saveRememberedKey(emptyKey);
      final retrievedKey = await KeyService.getRememberedKey();
      
      expect(retrievedKey, equals(emptyKey));
    });

    test('password storage handles unicode characters', () async {
      const unicodePassword = 'пароль密码🔑العربية';
      
      await KeyService.savePassword(unicodePassword);
      final retrievedPassword = await KeyService.getPassword();
      
      expect(retrievedPassword, equals(unicodePassword));
    });

    test('key storage handles large key data', () async {
      final largeKey = List.generate(1000, (index) => index % 256);
      
      await KeyService.saveRememberedKey(largeKey);
      final retrievedKey = await KeyService.getRememberedKey();
      
      expect(retrievedKey, equals(largeKey));
    });

    test('overwriting password works correctly', () async {
      const firstPassword = 'firstPassword';
      const secondPassword = 'secondPassword';
      
      // Save first password
      await KeyService.savePassword(firstPassword);
      expect(await KeyService.getPassword(), equals(firstPassword));
      
      // Overwrite with second password
      await KeyService.savePassword(secondPassword);
      expect(await KeyService.getPassword(), equals(secondPassword));
    });

    test('overwriting remembered key works correctly', () async {
      final firstKey = [1, 2, 3];
      final secondKey = [4, 5, 6, 7, 8];
      
      // Save first key
      await KeyService.saveRememberedKey(firstKey);
      expect(await KeyService.getRememberedKey(), equals(firstKey));
      
      // Overwrite with second key
      await KeyService.saveRememberedKey(secondKey);
      expect(await KeyService.getRememberedKey(), equals(secondKey));
    });

    test('multiple operations in sequence work correctly', () async {
      // Multiple saves and retrievals
      for (int i = 0; i < 5; i++) {
        final password = 'password$i';
        final key = List.generate(i + 1, (index) => index);
        
        await KeyService.savePassword(password);
        await KeyService.saveRememberedKey(key);
        
        expect(await KeyService.getPassword(), equals(password));
        expect(await KeyService.getRememberedKey(), equals(key));
      }
    });
  });
}
