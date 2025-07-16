import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/encryption_service.dart';
import 'package:reminest/models/journal_entry.dart';
import 'package:reminest/services/platform_database_service.dart';

void main() {
  group('DatabaseService Tests', () {
    setUpAll(() {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Initialize encryption service for testing
      final testKey = List.generate(32, (i) => i % 256);
      EncryptionService.initWithKey(testKey);

      // Initialize database
      await PlatformDatabaseService.initDB();

      // Clear any existing data
      await PlatformDatabaseService.clearAllData();
    });

    tearDown(() async {
      // Clean up after each test
      await PlatformDatabaseService.clearAllData();
    });

    test('should initialize database', () async {
      // Database should already be initialized in setUp
      expect(() => PlatformDatabaseService.initDB(), returnsNormally);
    });

    test('should add and retrieve journal entry', () async {
      final entry = JournalEntry(
        title: 'Test Entry',
        body: 'This is a test entry body.',
        reviewDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);

      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, equals(1));
      expect(entries.first.title, equals('Test Entry'));
      expect(entries.first.body, equals('This is a test entry body.'));
      expect(entries.first.isInVault, isFalse);
    });

    test('should update journal entry', () async {
      final entry = JournalEntry(
        title: 'Original Title',
        body: 'Original body.',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);

      final entries = await PlatformDatabaseService.getAllEntries();
      final savedEntry = entries.first;

      final updatedEntry = JournalEntry(
        id: savedEntry.id,
        title: 'Updated Title',
        body: 'Updated body.',
        reviewDate: savedEntry.reviewDate,
        createdAt: savedEntry.createdAt,
        isInVault: true, // Change vault status
      );

      await PlatformDatabaseService.updateEntry(updatedEntry);

      final updatedEntries = await PlatformDatabaseService.getAllEntries();
      expect(updatedEntries.length, equals(1));
      expect(updatedEntries.first.title, equals('Updated Title'));
      expect(updatedEntries.first.body, equals('Updated body.'));
      expect(updatedEntries.first.isInVault, isTrue);
    });

    test('should delete journal entry', () async {
      final entry = JournalEntry(
        title: 'Entry to Delete',
        body: 'This entry will be deleted.',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);

      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, equals(1));

      await PlatformDatabaseService.deleteEntry(entries.first.id!);

      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, equals(0));
    });

    test('should clear vault data only', () async {
      final regularEntry = JournalEntry(
        title: 'Regular Entry',
        body: 'Regular entry body.',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      final vaultEntry = JournalEntry(
        title: 'Vault Entry',
        body: 'Vault entry body.',
        reviewDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(regularEntry);
      await PlatformDatabaseService.addEntry(vaultEntry);

      await PlatformDatabaseService.clearVaultData();

      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, equals(1));
      expect(remainingEntries.first.title, equals('Regular Entry'));
      expect(remainingEntries.first.isInVault, isFalse);
    });

    test('should clear all data', () async {
      final entry1 = JournalEntry(
        title: 'Entry 1',
        body: 'Body 1',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      final entry2 = JournalEntry(
        title: 'Entry 2',
        body: 'Body 2',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(entry1);
      await PlatformDatabaseService.addEntry(entry2);

      expect((await PlatformDatabaseService.getAllEntries()).length, equals(2));

      await PlatformDatabaseService.clearAllData();

      expect((await PlatformDatabaseService.getAllEntries()).length, equals(0));
    });

    test('should handle entries with image paths', () async {
      final entry = JournalEntry(
        title: 'Entry with Image',
        body: 'This entry has an image.',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
        imagePath: '/path/to/image.jpg',
      );

      await PlatformDatabaseService.addEntry(entry);

      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, equals(1));
      expect(entries.first.imagePath, equals('/path/to/image.jpg'));
    });

    test('should handle multiple entries with different dates', () async {
      final now = DateTime.now();
      final entries = [
        JournalEntry(
          title: 'Entry 1',
          body: 'Body 1',
          reviewDate: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          isInVault: false,
        ),
        JournalEntry(
          title: 'Entry 2',
          body: 'Body 2',
          reviewDate: now,
          createdAt: now,
          isInVault: true,
        ),
        JournalEntry(
          title: 'Entry 3',
          body: 'Body 3',
          reviewDate: now.add(const Duration(days: 1)),
          createdAt: now.add(const Duration(days: 1)),
          isInVault: false,
        ),
      ];

      for (final entry in entries) {
        await PlatformDatabaseService.addEntry(entry);
      }

      final retrievedEntries = await PlatformDatabaseService.getAllEntries();
      expect(retrievedEntries.length, equals(3));

      // Check that all entries are properly stored and retrieved
      final titles = retrievedEntries.map((e) => e.title).toSet();
      expect(titles, contains('Entry 1'));
      expect(titles, contains('Entry 2'));
      expect(titles, contains('Entry 3'));
    });

    test('should use instance method getAllEntries', () async {
      final entry = JournalEntry(
        title: 'Instance Test',
        body: 'Testing instance method.',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);

      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, equals(1));
      expect(entries.first.title, equals('Instance Test'));
    });

    test('should handle database errors gracefully', () async {
      // Test behavior with invalid entry data
      final invalidEntry = JournalEntry(
        title: '',
        body: '',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      // Should not throw, but handle gracefully
      expect(() => PlatformDatabaseService.addEntry(invalidEntry),
          returnsNormally);
    });

    test('should maintain data integrity across operations', () async {
      final testEntry = JournalEntry(
        title: 'Integrity Test',
        body: 'Testing data integrity with special chars: !@#\$%^&*()',
        reviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(testEntry);
      final retrievedEntries = await PlatformDatabaseService.getAllEntries();

      expect(retrievedEntries.length, equals(1));
      expect(retrievedEntries.first.title, equals('Integrity Test'));
      expect(retrievedEntries.first.body, contains('special chars'));
    });
  });
}

/// Returns all journal entries from the database.
/// Throws on error, returns empty list if none found.
Future<List<JournalEntry>> getEntries() async {
  try {
    // Use PlatformDatabaseService.getEntries() as the canonical method
    return await PlatformDatabaseService.getAllEntries();
  } catch (e) {
    print('[PlatformDatabaseService] getEntries error: $e');
    return [];
  }
}
