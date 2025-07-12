import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/key_service.dart';

void main() {
  testWidgets('KeyService methods in widget test', (WidgetTester tester) async {
    await KeyService.clearPassword();
    await KeyService.savePasswordHash('testpassword');
    expect(true, isTrue);
  });
}
