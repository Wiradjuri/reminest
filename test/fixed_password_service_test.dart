// Comprehensive tests for PasswordService using the arrange-act-assert pattern.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:reminest/services/password_service.dart';

void main() {
  group('PasswordService', () {
    late Directory tempDir;

    setUp(() async {
      // Arrange
      tempDir = await Directory.systemTemp.createTemp('password_service_test');
      PasswordService.overrideAppDirectory(tempDir);
      await PasswordService.clearPasswordData();
    });

    tearDown(() async {
      // Arrange
      await PasswordService.clearPasswordData();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('setPassword and verifyPassword - happy path', () async {
      // Arrange
      const password = 'MySecurePassword123!';

      // Act
      final passkey = await PasswordService.setPassword(password);
      final isSet = await PasswordService.isPasswordSet();
      final verify = await PasswordService.verifyPassword(password);

      // Assert
      expect(passkey, isA<String>());
      expect(passkey.length, 16);
      expect(isSet, isTrue);
      expect(verify, isTrue);
    });

    test('verifyPassword returns false for wrong password', () async {
      // Arrange
      await PasswordService.setPassword('correct');
      
      // Act
      final result = await PasswordService.verifyPassword('wrong');

      // Assert
      expect(result, isFalse);
    });

    test('verifyPassword returns false if password file missing', () async {
      // Act
      final result = await PasswordService.verifyPassword('any');

      // Assert
      expect(result, isFalse);
    });

    test('isPasswordSet returns false if file missing', () async {
      // Act
      final result = await PasswordService.isPasswordSet();

      // Assert
      expect(result, isFalse);
    });

    test('setPassword throws ArgumentError for empty password', () async {
      // Act & Assert
      expect(() => PasswordService.setPassword(''), throwsArgumentError);
    });

    test('generatePasskey returns 16-char string', () {
      // Act
      final passkey = PasswordService.generatePasskey();

      // Assert
      expect(passkey, isA<String>());
      expect(passkey.length, 16);
      expect(RegExp(r'^[A-Z0-9]{16}$').hasMatch(passkey), isTrue);
    });

    test('getRecoveryPasskey returns correct passkey after setPassword', () async {
      // Arrange
      final password = 'TestPassword!';
      final passkey = await PasswordService.setPassword(password);

      // Act
      final recovery = await PasswordService.getRecoveryPasskey();

      // Assert
      expect(recovery, equals(passkey));
    });

    test('getRecoveryPasskey returns null if file missing', () async {
      // Act
      final recovery = await PasswordService.getRecoveryPasskey();

      // Assert
      expect(recovery, isNull);
    });

    test('resetPasswordWithPasskey works for correct passkey', () async {
      // Arrange
      final password = 'oldPass';
      final newPassword = 'newPass';
      final passkey = await PasswordService.setPassword(password);

      // Act
      final result = await PasswordService.resetPasswordWithPasskey(passkey, newPassword);
      final verifyOld = await PasswordService.verifyPassword(password);
      final verifyNew = await PasswordService.verifyPassword(newPassword);

      // Assert
      expect(result, isTrue);
      expect(verifyOld, isFalse);
      expect(verifyNew, isTrue);
    });

    test('resetPasswordWithPasskey fails for wrong passkey', () async {
      // Arrange
      await PasswordService.setPassword('oldPass');

      // Act
      final result = await PasswordService.resetPasswordWithPasskey('WRONGPASSKEY', 'newPass');

      // Assert
      expect(result, isFalse);
    });

    test('clearPasswordData deletes password and passkey files', () async {
      // Arrange
      await PasswordService.setPassword('toDelete');
      final dir = tempDir;
      final passwordFile = File(p.join(dir.path, 'app_password.sec'));
      final passkeyFile = File(p.join(dir.path, 'recovery_passkey.sec'));
      expect(await passwordFile.exists(), isTrue);
      expect(await passkeyFile.exists(), isTrue);

      // Act
      await PasswordService.clearPasswordData();

      // Assert
      expect(await passwordFile.exists(), isFalse);
      expect(await passkeyFile.exists(), isFalse);
    });

    test('getPasswordCreationDate returns correct date', () async {
      // Arrange
      await PasswordService.setPassword('dateTest');

      // Act
      final date = await PasswordService.getPasswordCreationDate();

      // Assert
      expect(date, isA<DateTime>());
      expect(date!.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('getPasswordCreationDate returns null if file missing', () async {
      // Act
      final date = await PasswordService.getPasswordCreationDate();

      // Assert
      expect(date, isNull);
    });

    test('getSecurityInfo returns correct info', () async {
      // Arrange
      await PasswordService.setPassword('infoTest');

      // Act
      final info = await PasswordService.getSecurityInfo();

      // Assert
      expect(info, isA<Map<String, dynamic>>());
      expect(info!['algorithm'], equals('PBKDF2-SHA256'));
      expect(info['iterations'], equals(100000));
      expect(info['version'], equals('2.0'));
      expect(info['created'], isA<String>());
      expect(info['isSecure'], isTrue);
    });

    test('getSecurityInfo returns null if file missing', () async {
      // Act
      final info = await PasswordService.getSecurityInfo();

      // Assert
      expect(info, isNull);
    });

    test('clearPassword is an alias for clearPasswordData', () async {
      // Arrange
      await PasswordService.setPassword('aliasTest');
      final dir = tempDir;
      final passwordFile = File(p.join(dir.path, 'app_password.sec'));
      expect(await passwordFile.exists(), isTrue);

      // Act
      await PasswordService.clearPassword();

      // Assert
      expect(await passwordFile.exists(), isFalse);
    });

    test('secure delete handles file not found gracefully', () async {
      // Arrange
      final file = File(p.join(tempDir.path, 'nonexistent.sec'));
      if (await file.exists()) await file.delete();

      // Act & Assert
      await PasswordService.clearPasswordData(); // Should not throw
    });

    test('overrideAppDirectory allows test injection', () async {
      // Arrange
      final newDir = await Directory.systemTemp.createTemp('override_test');
      PasswordService.overrideAppDirectory(newDir);

      // Act
      await PasswordService.setPassword('overrideTest');
      final passwordFile = File(p.join(newDir.path, 'app_password.sec'));

      // Assert
      expect(await passwordFile.exists(), isTrue);

      // Clean up
      await newDir.delete(recursive: true);
    });

    test('getAppDirectory throws on web', () async {
      // This is not possible to test in a non-web environment, but we can check the code path.
      // Skipped in this environment.
    });
  });
}
