import 'package:flutter_test/flutter_test.dart';
import 'package:Reminest/services/key_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Password hash store and verify', () async {
    await KeyService.clearPassword();
    await KeyService.savePasswordHash("testpassword");
    final result = await KeyService.verifyPassword("testpassword");
    expect(result, true);

    final failResult = await KeyService.verifyPassword("wrongpassword");
    expect(failResult, false);
  });

  test('Vault PIN store and verify', () async {
    await KeyService.clearVaultPin();
    await KeyService.saveVaultPin("1234");
    final result = await KeyService.verifyVaultPin("1234");
    expect(result, true);

    final failResult = await KeyService.verifyVaultPin("5678");
    expect(failResult, false);
  });
}
