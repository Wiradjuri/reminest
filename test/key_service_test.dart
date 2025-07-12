import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';

void main() {
  group('KeyService', () {
    test('save and get password hash', () async {
      final password = 'mysecret';
      await KeyService.savePasswordHash(password);
      final hash = await KeyService.getPasswordHash();
      expect(hash, isNotNull);
    });

    test('clear password does not throw', () async {
      await KeyService.clearPassword();
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
