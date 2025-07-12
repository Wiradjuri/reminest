import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/password_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await PasswordService.clearPasswordData();
  });

  tearDown(() async {
    await PasswordService.clearPasswordData();
  });

  group('PasswordService', () {
    test('setPassword creates a passkey and verifyPassword works', () async {
      const password = 'testPassword123';
      
      final passkey = await PasswordService.setPassword(password);
      expect(passkey, isNotNull);
      expect(passkey.length, greaterThan(0));
      
      final isVerified = await PasswordService.verifyPassword(password);
      expect(isVerified, isTrue);
    });

    test('verifyPassword fails with wrong password', () async {
      const password = 'correctPassword';
      await PasswordService.setPassword(password);
      
      final isVerified = await PasswordService.verifyPassword('wrongPassword');
      expect(isVerified, isFalse);
    });

    test('isPasswordSet returns correct status', () async {
      const password = 'testPassword123';
      
      // Initially no password should be set
      expect(await PasswordService.isPasswordSet(), isFalse);
      
      // After setting password
      await PasswordService.setPassword(password);
      final isSet = await PasswordService.isPasswordSet();
      expect(isSet, isTrue);
    });

    test('getRecoveryPasskey returns the passkey', () async {
      const password = 'testPassword123';
      
      final passkey = await PasswordService.setPassword(password);
      final storedPasskey = await PasswordService.getRecoveryPasskey();
      
      expect(storedPasskey, equals(passkey));
    });

    test('resetPasswordWithPasskey works correctly', () async {
      const password = 'oldPassword';
      const newPassword = 'newPassword123';
      
      final passkey = await PasswordService.setPassword(password);
      
      final isReset = await PasswordService.resetPasswordWithPasskey(passkey, newPassword);
      expect(isReset, isTrue);
      
      final isVerified = await PasswordService.verifyPassword(newPassword);
      expect(isVerified, isTrue);
    });

    test('resetPasswordWithPasskey fails with wrong passkey', () async {
      const password = 'password123';
      const newPassword = 'newPassword123';
      
      await PasswordService.setPassword(password);
      
      final isReset = await PasswordService.resetPasswordWithPasskey('wrongPasskey', newPassword);
      expect(isReset, isFalse);
    });

    test('clearPasswordData removes all password data', () async {
      const password = 'passwordToBeCleared';
      
      await PasswordService.setPassword(password);
      
      await PasswordService.clearPasswordData();
      
      final isSet = await PasswordService.isPasswordSet();
      expect(isSet, isFalse);
      
      final storedPasskey = await PasswordService.getRecoveryPasskey();
      expect(storedPasskey, isNull);
    });

    test('getPasswordCreationDate returns creation date', () async {
      const password = 'testPassword123';
      
      await PasswordService.setPassword(password);
      
      final storedCreationDate = await PasswordService.getPasswordCreationDate();
      expect(storedCreationDate, isNotNull);
      expect(storedCreationDate!.isBefore(DateTime.now().add(Duration(seconds: 1))), isTrue);
    });

    test('getSecurityInfo returns security information', () async {
      const password = 'testPassword123';
      
      await PasswordService.setPassword(password);
      
      final securityInfo = await PasswordService.getSecurityInfo();
      expect(securityInfo, isNotNull);
      expect(securityInfo!.containsKey('passwordSet'), isTrue);
      expect(securityInfo['passwordSet'], isTrue);
    });

    group('Edge cases', () {
      test('handles empty password', () async {
        const emptyPassword = '';
        
        final passkey = await PasswordService.setPassword(emptyPassword);
        expect(passkey, isNotNull);
        
        final isVerified = await PasswordService.verifyPassword(emptyPassword);
        expect(isVerified, isTrue);
      });

      test('handles long password', () async {
        final longPassword = 'A' * 1000; // 1000 character password
        
        final passkey = await PasswordService.setPassword(longPassword);
        expect(passkey, isNotNull);
        
        final isVerified = await PasswordService.verifyPassword(longPassword);
        expect(isVerified, isTrue);
      });

      test('handles special characters in password', () async {
        const specialPassword = 'P@ssw0rd!@#\$%^&*()_+-=[]{}|;:,.<>?/~`';
        
        final passkey = await PasswordService.setPassword(specialPassword);
        expect(passkey, isNotNull);
        
        final isVerified = await PasswordService.verifyPassword(specialPassword);
        expect(isVerified, isTrue);
      });

      test('handles unicode characters in password', () async {
        const unicodePassword = 'пароль🔒密码🗝️مرور';
        
        final passkey = await PasswordService.setPassword(unicodePassword);
        expect(passkey, isNotNull);
        
        final isVerified = await PasswordService.verifyPassword(unicodePassword);
        expect(isVerified, isTrue);
      });
    });

    group('Security tests', () {
      test('different passwords produce different passkeys', () async {
        const password1 = 'password1';
        const password2 = 'password2';
        
        final passkey1 = await PasswordService.setPassword(password1);
        await PasswordService.clearPasswordData();
        final passkey2 = await PasswordService.setPassword(password2);
        
        expect(passkey1, isNot(equals(passkey2)));
      });

      test('passkey regeneration produces different passkeys', () async {
        const password = 'samePassword';
        
        final passkey1 = await PasswordService.setPassword(password);
        await PasswordService.clearPasswordData();
        final passkey2 = await PasswordService.setPassword(password);
        
        // Even with same password, new passkey should be generated
        expect(passkey1, isNot(equals(passkey2)));
      });
    });
  });
}
