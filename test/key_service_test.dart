import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/lib/services/key_service.dart';

void main() {
  group('KeyService', () {
    test('save and get password', () async {
      final password = 'mysecret';
      await KeyService.savePassword(password);
      final storedPassword = await KeyService.getPassword();
      expect(storedPassword, password);
    });

    test('clearAllPasswordData does not throw', () async {
      await KeyService.clearAllPasswordData();
      expect(true, isTrue);
    });

    test('save and get remembered key', () async {
      final keyBytes = [1, 2, 3, 4, 5];
      await KeyService.saveRememberedKey(keyBytes);
      final retrievedKey = await KeyService.getRememberedKey();
      expect(retrievedKey, keyBytes);
    });
  });
}
