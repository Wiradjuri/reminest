import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/password_service.dart';
import 'package:flutter/services.dart';

void main() {
  group('PasswordService Tests', () {
    setUpAll(() {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Clean up any existing password files before each test
      await PasswordService.clearPasswordData();
    });

    tearDown(() async {
      // Clean up after each test
      await PasswordService.clearPasswordData();
    });

    test('should generate secure passkey', () {
      final passkey1 = PasswordService.generatePasskey();
      final passkey2 = PasswordService.generatePasskey();
      
      expect(passkey1.length, equals(16));
      expect(passkey2.length, equals(16));
      expect(passkey1, isNot(equals(passkey2))); // Should be different
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(passkey1), isTrue);
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(passkey2), isTrue);
    });

    test('should check if password is set', () async {
      expect(await PasswordService.isPasswordSet(), isFalse);
      
      await PasswordService.setPassword('testpassword123');
      expect(await PasswordService.isPasswordSet(), isTrue);
    });

    test('should set and verify password', () async {
      const password = 'mySecurePassword123';
      
      final passkey = await PasswordService.setPassword(password);
      expect(passkey, isNotNull);
      expect(passkey.length, equals(16));
      
      expect(await PasswordService.verifyPassword(password), isTrue);
      expect(await PasswordService.verifyPassword('wrongpassword'), isFalse);
    });

    test('should get recovery passkey', () async {
      const password = 'testpassword123';
      
      final originalPasskey = await PasswordService.setPassword(password);
      final retrievedPasskey = await PasswordService.getRecoveryPasskey();
      
      expect(retrievedPasskey, equals(originalPasskey));
    });

    test('should reset password with valid passkey', () async {
      const oldPassword = 'oldpassword123';
      const newPassword = 'newpassword456';
      
      final passkey = await PasswordService.setPassword(oldPassword);
      
      expect(await PasswordService.verifyPassword(oldPassword), isTrue);
      
      final resetSuccess = await PasswordService.resetPasswordWithPasskey(passkey, newPassword);
      expect(resetSuccess, isTrue);
      
      expect(await PasswordService.verifyPassword(oldPassword), isFalse);
      expect(await PasswordService.verifyPassword(newPassword), isTrue);
    });

    test('should fail to reset password with invalid passkey', () async {
      const password = 'testpassword123';
      const newPassword = 'newpassword456';
      
      await PasswordService.setPassword(password);
      
      final resetSuccess = await PasswordService.resetPasswordWithPasskey('INVALIDPASSKEY1', newPassword);
      expect(resetSuccess, isFalse);
      
      // Original password should still work
      expect(await PasswordService.verifyPassword(password), isTrue);
    });

    test('should get password creation date', () async {
      const password = 'testpassword123';
      
      expect(await PasswordService.getPasswordCreationDate(), isNull);
      
      final beforeSet = DateTime.now();
      await PasswordService.setPassword(password);
      final afterSet = DateTime.now();
      
      final creationDate = await PasswordService.getPasswordCreationDate();
      expect(creationDate, isNotNull);
      expect(creationDate!.isAfter(beforeSet.subtract(Duration(seconds: 1))), isTrue);
      expect(creationDate.isBefore(afterSet.add(Duration(seconds: 1))), isTrue);
    });

    test('should get security info', () async {
      const password = 'testpassword123';
      
      expect(await PasswordService.getSecurityInfo(), isNull);
      
      await PasswordService.setPassword(password);
      final securityInfo = await PasswordService.getSecurityInfo();
      
      expect(securityInfo, isNotNull);
      expect(securityInfo!['algorithm'], equals('PBKDF2-SHA256'));
      expect(securityInfo['iterations'], equals(100000));
      expect(securityInfo['version'], equals('2.0'));
      expect(securityInfo['isSecure'], isTrue);
      expect(securityInfo['created'], isNotNull);
    });

    test('should clear password data', () async {
      const password = 'testpassword123';
      
      await PasswordService.setPassword(password);
      expect(await PasswordService.isPasswordSet(), isTrue);
      
      await PasswordService.clearPasswordData();
      expect(await PasswordService.isPasswordSet(), isFalse);
      expect(await PasswordService.getRecoveryPasskey(), isNull);
    });

    test('should handle verification with no password set', () async {
      expect(await PasswordService.verifyPassword('anypassword'), isFalse);
    });

    test('should handle empty password verification gracefully', () async {
      const password = 'testpassword123';
      await PasswordService.setPassword(password);
      
      expect(await PasswordService.verifyPassword(''), isFalse);
    });

    test('should use high iteration count for security', () async {
      const password = 'testpassword123';
      
      await PasswordService.setPassword(password);
      final securityInfo = await PasswordService.getSecurityInfo();
      
      expect(securityInfo!['iterations'], greaterThanOrEqualTo(100000));
      expect(securityInfo['isSecure'], isTrue);
    });
  });
}
