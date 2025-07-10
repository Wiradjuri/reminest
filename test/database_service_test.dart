import 'package:flutter_test/flutter_test.dart';
import 'package:Reminest/services/database_service.dart';
import 'package:Reminest/models/journal_entry.dart';
import 'package:Reminest/services/encryption_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Insert and fetch journal entry', () async {
    EncryptionService.initializeKey(List<int>.filled(32, 1)); // Dummy key
    await DatabaseService.initDB();

    final entry = JournalEntry(
      title: "Test Entry",
      body: "This is a test body for Reminest.",
      createdAt: DateTime.now(),
      reviewDate: DateTime.now().add(Duration(days: 5)),
      isReviewed: false,
    );

    await DatabaseService.insertEntry(entry);
    final entries = await DatabaseService.getEntries();

    expect(entries.any((e) => e.title == "Test Entry"), true);
  });
}
