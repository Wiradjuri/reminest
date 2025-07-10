import 'package:flutter_test/flutter_test.dart';
import 'package:Reminest/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Encryption and decryption should return the original text', () {
    EncryptionService.initializeKey(List<int>.filled(32, 1)); // Dummy key

    final text = "Reminest Test Entry";
    final encrypted = EncryptionService.encryptText(text);
    final decrypted = EncryptionService.decryptText(encrypted);

    expect(decrypted, text);
  });
}
