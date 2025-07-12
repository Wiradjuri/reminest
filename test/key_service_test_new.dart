import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyService', () {
    setUp(() async {
      // Clear all stored data before each test
      await KeyService.clearAllPasswordData();
      await KeyService.clearVaultPin();
    });

    group('Password Management', () {
      test('savePassword and getPassword work correctly', () async {
        const testPassword = 'testPassword123';
        
        await KeyService.savePassword(testPassword);
        final retrievedPassword = await KeyService.getPassword();
        
        expect(retrievedPassword, equals(testPassword));
      });

      test('getPassword returns null when no password is saved', () async {
        final retrievedPassword = await KeyService.getPassword();
        expect(retrievedPassword, isNull);
      });

      test('hasPassword returns false when no password is set', () async {
        final hasPassword = await KeyService.hasPassword();
        expect(hasPassword, isFalse);
      });

      test('hasPassword returns true when password is set', () async {
        const testPassword = 'testPassword123';
        await KeyService.savePassword(testPassword);
        
        final hasPassword = await KeyService.hasPassword();
        expect(hasPassword, isTrue);
      });

      test('verifyPassword works correctly', () async {
        const testPassword = 'testPassword123';
        await KeyService.savePassword(testPassword);
        
        expect(await KeyService.verifyPassword(testPassword), isTrue);
        expect(await KeyService.verifyPassword('wrongPassword'), isFalse);
      });

      test('getStoredPassword retrieves saved password', () async {
        const testPassword = 'storedPassword123';
        await KeyService.savePassword(testPassword);
        
        final storedPassword = await KeyService.getStoredPassword();
        expect(storedPassword, equals(testPassword));
      });

      test('clearAllPasswordData removes password', () async {
        const testPassword = 'testPassword123';
        await KeyService.savePassword(testPassword);
        
        await KeyService.clearAllPasswordData();
        
        final hasPassword = await KeyService.hasPassword();
        expect(hasPassword, isFalse);
        
        final retrievedPassword = await KeyService.getPassword();
        expect(retrievedPassword, isNull);
      });

      test('setPasswordSetFlag and hasSetPassword work correctly', () async {
        expect(await KeyService.hasSetPassword(), isFalse);
        
        await KeyService.setPasswordSetFlag();
        expect(await KeyService.hasSetPassword(), isTrue);
      });
    });

    group('Vault PIN Management', () {
      test('saveVaultPin and verifyVaultPin work correctly', () async {
        const testPin = '123456';
        
        await KeyService.saveVaultPin(testPin);
        expect(await KeyService.verifyVaultPin(testPin), isTrue);
        expect(await KeyService.verifyVaultPin('654321'), isFalse);
      });

      test('hasVaultPin returns correct status', () async {
        expect(await KeyService.hasVaultPin(), isFalse);
        
        const testPin = '123456';
        await KeyService.saveVaultPin(testPin);
        
        expect(await KeyService.hasVaultPin(), isTrue);
      });

      test('clearVaultPin removes vault PIN', () async {
        const testPin = '123456';
        await KeyService.saveVaultPin(testPin);
        
        await KeyService.clearVaultPin();
        
        expect(await KeyService.hasVaultPin(), isFalse);
      });

      test('vault PIN verification fails after clearing', () async {
        const testPin = '123456';
        await KeyService.saveVaultPin(testPin);
        
        await KeyService.clearVaultPin();
        
        expect(await KeyService.verifyVaultPin(testPin), isFalse);
      });
    });

    group('Security tests', () {
      test('different PINs produce different verification results', () async {
        const pin1 = '123456';
        const pin2 = '654321';
        
        await KeyService.saveVaultPin(pin1);
        expect(await KeyService.verifyVaultPin(pin1), isTrue);
        expect(await KeyService.verifyVaultPin(pin2), isFalse);
        
        await KeyService.clearVaultPin();
        await KeyService.saveVaultPin(pin2);
        expect(await KeyService.verifyVaultPin(pin1), isFalse);
        expect(await KeyService.verifyVaultPin(pin2), isTrue);
      });

      test('password storage handles special characters', () async {
        const complexPassword = 'P@ssw0rd!@#\$%^&*()_+-=[]{}|;:,.<>?';
        
        await KeyService.savePassword(complexPassword);
        final retrieved = await KeyService.getPassword();
        
        expect(retrieved, equals(complexPassword));
        expect(await KeyService.verifyPassword(complexPassword), isTrue);
      });

      test('PIN verification handles valid PIN lengths', () async {
        const validPins = ['1234', '12345', '123456']; // Only 4-6 digit PINs are valid
        
        for (final pin in validPins) {
          await KeyService.clearVaultPin();
          await KeyService.saveVaultPin(pin);
          expect(await KeyService.verifyVaultPin(pin), isTrue);
        }
      });

      test('invalid PIN lengths should throw error', () async {
        const invalidPins = ['1', '12', '123', '1234567890']; // Too short or too long
        
        for (final pin in invalidPins) {
          expect(() => KeyService.saveVaultPin(pin), throwsArgumentError);
        }
      });

      test('empty PIN handling should throw error', () async {
        const emptyPin = '';
        expect(() => KeyService.saveVaultPin(emptyPin), throwsArgumentError);
      });
    });

    group('Integration tests', () {
      test('password and PIN can coexist independently', () async {
        const testPassword = 'myPassword123';
        const testPin = '987654';
        
        await KeyService.savePassword(testPassword);
        await KeyService.saveVaultPin(testPin);
        
        expect(await KeyService.hasPassword(), isTrue);
        expect(await KeyService.hasVaultPin(), isTrue);
        expect(await KeyService.verifyPassword(testPassword), isTrue);
        expect(await KeyService.verifyVaultPin(testPin), isTrue);
        
        // Clearing password should not affect PIN
        await KeyService.clearAllPasswordData();
        expect(await KeyService.hasPassword(), isFalse);
        expect(await KeyService.hasVaultPin(), isTrue);
        expect(await KeyService.verifyVaultPin(testPin), isTrue);
      });
    });
  });
}
