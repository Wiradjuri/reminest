import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/password_service.dart';
import 'dart:io';

void main() {
  group('PasswordService Tests', () {
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for each test
      tempDir = await Directory.systemTemp.createTemp('password_test_');
      PasswordService.overrideAppDirectory(tempDir);
    });

    tearDown(() async {
      // Clean up after each test
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should generate passkey of correct length', () {
      final passkey = PasswordService.generatePasskey();
      expect(passkey.length, equals(16));
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(passkey), isTrue);
    });

    test('should set and verify password correctly', () async {
      const password = 'TestPassword123!';
      
      final passkey = await PasswordService.setPassword(password);
      expect(passkey, isNotEmpty);
      expect(passkey.length, equals(16));
      
      final isValid = await PasswordService.verifyPassword(password);
      expect(isValid, isTrue);
      
      final isSet = await PasswordService.isPasswordSet();
      expect(isSet, isTrue);
    });

    test('should reject incorrect password', () async {
      const correctPassword = 'CorrectPassword123!';
      const wrongPassword = 'WrongPassword456!';
      
      await PasswordService.setPassword(correctPassword);
      
      final isValid = await PasswordService.verifyPassword(wrongPassword);
      expect(isValid, isFalse);
    });

    test('should return false for password verification when no password set', () async {
      final isValid = await PasswordService.verifyPassword('anypassword');
      expect(isValid, isFalse);
      
      final isSet = await PasswordService.isPasswordSet();
      expect(isSet, isFalse);
    });

    test('should retrieve recovery passkey', () async {
      const password = 'TestPassword123!';
      
      final passkey = await PasswordService.setPassword(password);
      final retrievedPasskey = await PasswordService.getRecoveryPasskey();
      
      expect(retrievedPasskey, equals(passkey));
    });

    test('should reset password with correct passkey', () async {
      const originalPassword = 'OriginalPassword123!';
      const newPassword = 'NewPassword456!';
      
      final passkey = await PasswordService.setPassword(originalPassword);
      
      final resetSuccess = await PasswordService.resetPasswordWithPasskey(
        passkey,
        newPassword,
      );
      expect(resetSuccess, isTrue);
      
      // Original password should no longer work
      final oldPasswordValid = await PasswordService.verifyPassword(originalPassword);
      expect(oldPasswordValid, isFalse);
      
      // New password should work
      final newPasswordValid = await PasswordService.verifyPassword(newPassword);
      expect(newPasswordValid, isTrue);
    });

    test('should reject password reset with incorrect passkey', () async {
      const password = 'TestPassword123!';
      const newPassword = 'NewPassword456!';
      const wrongPasskey = 'WRONGPASSKEY1234';
      
      await PasswordService.setPassword(password);
      
      final resetSuccess = await PasswordService.resetPasswordWithPasskey(
        wrongPasskey,
        newPassword,
      );
      expect(resetSuccess, isFalse);
      
      // Original password should still work
      final originalPasswordValid = await PasswordService.verifyPassword(password);
      expect(originalPasswordValid, isTrue);
    });

    test('should clear password data completely', () async {
      const password = 'TestPassword123!';
      
      await PasswordService.setPassword(password);
      expect(await PasswordService.isPasswordSet(), isTrue);
      
      await PasswordService.clearPasswordData();
      
      expect(await PasswordService.isPasswordSet(), isFalse);
      expect(await PasswordService.verifyPassword(password), isFalse);
      expect(await PasswordService.getRecoveryPasskey(), isNull);
    });

    test('should get password creation date', () async {
      const password = 'TestPassword123!';
      final beforeCreation = DateTime.now();
      
      await PasswordService.setPassword(password);
      
      final afterCreation = DateTime.now();
      final creationDate = await PasswordService.getPasswordCreationDate();
      
      expect(creationDate, isNotNull);
      expect(creationDate!.isAfter(beforeCreation.subtract(const Duration(seconds: 1))), isTrue);
      expect(creationDate.isBefore(afterCreation.add(const Duration(seconds: 1))), isTrue);
    });

    test('should get security info', () async {
      const password = 'TestPassword123!';
      
      await PasswordService.setPassword(password);
      final securityInfo = await PasswordService.getSecurityInfo();
      
      expect(securityInfo, isNotNull);
      expect(securityInfo!['algorithm'], equals('PBKDF2-SHA256'));
      expect(securityInfo['iterations'], equals(100000));
      expect(securityInfo['version'], equals('2.0'));
      expect(securityInfo['isSecure'], isTrue);
      expect(securityInfo['created'], isNotNull);
    });

    test('should return null security info when no password set', () async {
      final securityInfo = await PasswordService.getSecurityInfo();
      expect(securityInfo, isNull);
    });

    test('should handle file system errors gracefully', () async {
      // Use a non-existent directory to simulate file system errors
      final nonExistentDir = Directory('/non/existent/path');
      PasswordService.overrideAppDirectory(nonExistentDir);
      
      // These should not throw exceptions but return false/null
      expect(await PasswordService.isPasswordSet(), isFalse);
      expect(await PasswordService.verifyPassword('test'), isFalse);
      expect(await PasswordService.getRecoveryPasskey(), isNull);
      expect(await PasswordService.getPasswordCreationDate(), isNull);
      expect(await PasswordService.getSecurityInfo(), isNull);
    });

    test('should generate different passkeys', () {
      final passkey1 = PasswordService.generatePasskey();
      final passkey2 = PasswordService.generatePasskey();
      final passkey3 = PasswordService.generatePasskey();
      
      expect(passkey1, isNot(equals(passkey2)));
      expect(passkey2, isNot(equals(passkey3)));
      expect(passkey1, isNot(equals(passkey3)));
    });
  });
}
