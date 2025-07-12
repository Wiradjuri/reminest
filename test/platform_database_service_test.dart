import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/services/platform_database_service.dart';
import 'package:reminest/services/encryption_service.dart';
import 'package:reminest/models/journal_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformDatabaseService', () {
    setUpAll(() async {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Initialize encryption service with a test key
      EncryptionService.initializeKey(List<int>.generate(32, (i) => i));
    });

    setUp(() async {
      // Clear database before each test
      await PlatformDatabaseService.clearAllData();
    });

    tearDown(() async {
      // Clean up after each test
      await PlatformDatabaseService.clearAllData();
    });

    test('initDB initializes the database successfully', () async {
      await PlatformDatabaseService.initDB();
      expect(true, isTrue); // If no exception, initialization succeeded
    });

    test('addEntry and getEntries work correctly', () async {
      await PlatformDatabaseService.initDB();

      final entry = JournalEntry(
        title: 'Test Title',
        body: 'Test body content for testing',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 7)),
        isReviewed: false,
        isInVault: false,
      );

      // Add entry
      await PlatformDatabaseService.addEntry(entry);

      // Get entries
      final entries = await PlatformDatabaseService.getAllEntries();

      expect(entries.length, 1);
      expect(entries.first.title, 'Test Title');
      expect(entries.first.body, 'Test body content for testing');
      expect(entries.first.isReviewed, false);
      expect(entries.first.isInVault, false);
    });

    test('updateEntry modifies existing entry', () async {
      await PlatformDatabaseService.initDB();

      // Add initial entry
      final entry = JournalEntry(
        title: 'Original Title',
        body: 'Original body',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 7)),
        isReviewed: false,
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);
      final entries = await PlatformDatabaseService.getAllEntries();
      final addedEntry = entries.first;

      // Update entry
      final updatedEntry = JournalEntry(
        id: addedEntry.id,
        title: 'Updated Title',
        body: 'Updated body content',
        createdAt: addedEntry.createdAt,
        reviewDate: DateTime.now().add(const Duration(days: 14)),
        isReviewed: true,
        isInVault: true,
      );

      await PlatformDatabaseService.updateEntry(updatedEntry);

      // Verify update
      final updatedEntries = await PlatformDatabaseService.getAllEntries();
      expect(updatedEntries.length, 1);
      expect(updatedEntries.first.title, 'Updated Title');
      expect(updatedEntries.first.body, 'Updated body content');
      expect(updatedEntries.first.isReviewed, true);
      expect(updatedEntries.first.isInVault, true);
    });

    test('deleteEntry removes entry from database', () async {
      await PlatformDatabaseService.initDB();

      // Add entry
      final entry = JournalEntry(
        title: 'Entry to Delete',
        body: 'This entry will be deleted',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 7)),
        isReviewed: false,
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(entry);
      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, 1);

      // Delete entry
      await PlatformDatabaseService.deleteEntry(entries.first.id!);

      // Verify deletion
      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, 0);
    });

    test('clearVaultData only removes vault entries', () async {
      await PlatformDatabaseService.initDB();

      // Add vault entry
      final vaultEntry = JournalEntry(
        title: 'Vault Entry',
        body: 'This is in the vault',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 7)),
        isReviewed: false,
        isInVault: true,
      );

      // Add regular entry
      final regularEntry = JournalEntry(
        title: 'Regular Entry',
        body: 'This is not in the vault',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 7)),
        isReviewed: false,
        isInVault: false,
      );

      await PlatformDatabaseService.addEntry(vaultEntry);
      await PlatformDatabaseService.addEntry(regularEntry);

      // Verify both entries exist
      final allEntries = await PlatformDatabaseService.getAllEntries();
      expect(allEntries.length, 2);

      // Clear vault data
      await PlatformDatabaseService.clearVaultData();

      // Verify only regular entry remains
      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, 1);
      expect(remainingEntries.first.title, 'Regular Entry');
      expect(remainingEntries.first.isInVault, false);
    });

    test('clearAllData removes all entries', () async {
      await PlatformDatabaseService.initDB();

      // Add multiple entries
      for (int i = 0; i < 3; i++) {
        final entry = JournalEntry(
          title: 'Entry $i',
          body: 'Body content for entry $i',
          createdAt: DateTime.now(),
          reviewDate: DateTime.now().add(const Duration(days: 7)),
          isReviewed: i % 2 == 0,
          isInVault: i % 2 == 1,
        );
        await PlatformDatabaseService.addEntry(entry);
      }

      // Verify entries exist
      final allEntries = await PlatformDatabaseService.getAllEntries();
      expect(allEntries.length, 3);

      // Clear all data
      await PlatformDatabaseService.clearAllData();

      // Verify all entries removed
      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, 0);
    });
  });
}
