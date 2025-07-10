import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Password hashing and verification should work correctly', () async {
    const password = 'TestPassword123';

    await KeyService.savePasswordHash(password);
    final isCorrect = await KeyService.verifyPassword(password);
    final isIncorrect = await KeyService.verifyPassword('WrongPassword');

    expect(isCorrect, true);
    expect(isIncorrect, false);
  });

  test('Remembered key should be saved and retrieved correctly', () async {
    final keyBytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    await KeyService.saveRememberedKey(keyBytes);
    final retrievedKey = await KeyService.getRememberedKey();

    expect(retrievedKey, isNotNull);
    expect(retrievedKey, keyBytes);
  });

  test('Password should be cleared correctly', () async {
    const password = 'TestPassword123';

    await KeyService.savePasswordHash(password);
    await KeyService.clearPassword();

    final hasPassword = await KeyService.hasPassword();
    expect(hasPassword, false);
  });
}
