import '../lib/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService', () {
    test('init initializes the database', () async {
      await DatabaseService.init();
      expect(DatabaseService.database, isNotNull);
    });

    test('getEntries returns a list (may be empty)', () async {
      await DatabaseService.init();
      final entries = await DatabaseService.getEntries();
      expect(entries, isA<List>());
    });

    test('addEntry inserts an entry without throwing', () async {
      await DatabaseService.init();
      final entry = {
        'title': 'Test Title',
        'content': 'Test Content',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await DatabaseService.addEntry(entry);
      final entries = await DatabaseService.getEntries();
      expect(entries, anyElement(containsPair('title', 'Test Title')));
    });

    test('updateEntry does not throw', () async {
      await DatabaseService.init();
      final entry = {
        'id': 1,
        'title': 'Updated Title',
        'content': 'Updated Content',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await DatabaseService.updateEntry(entry);
      expect(true, isTrue);
    });

    test('deleteEntry does not throw', () async {
      await DatabaseService.init();
      await DatabaseService.deleteEntry(1);
      expect(true, isTrue);
    });
  });
}
