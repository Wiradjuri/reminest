import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminest/services/platform_database_service.dart';
import 'package:reminest/services/encryption_service.dart';
import 'package:reminest/models/journal_entry.dart';

void main() {
  group('PlatformDatabaseService Tests', () {
    setUpAll(() {
      // Initialize encryption for testing
      EncryptionService.initializeWithRandomKey();
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      await PlatformDatabaseService.clearAllData();
    });

    test('should initialize database successfully', () async {
      await PlatformDatabaseService.initDB();
      expect(true, isTrue); // If no exception thrown, initialization succeeded
    });

    test('should add and retrieve journal entry', () async {
      final entry = JournalEntry(
        title: 'Test Entry',
        body: 'Test content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 1)),
      );

      await PlatformDatabaseService.addEntry(entry);
      final entries = await PlatformDatabaseService.getAllEntries();
      
      expect(entries.length, 1);
      expect(entries.first.title, 'Test Entry');
      expect(entries.first.body, 'Test content');
    });

    test('should filter regular entries correctly', () async {
      final regularEntry = JournalEntry(
        title: 'Regular Entry',
        body: 'Regular content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
        isInVault: false,
      );

      final vaultEntry = JournalEntry(
        title: 'Vault Entry',
        body: 'Vault content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 1)),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(regularEntry);
      await PlatformDatabaseService.addEntry(vaultEntry);

      final regularEntries = await PlatformDatabaseService.getRegularEntries();
      expect(regularEntries.length, 1);
      expect(regularEntries.first.title, 'Regular Entry');
    });

    test('should filter vault entries correctly', () async {
      final regularEntry = JournalEntry(
        title: 'Regular Entry',
        body: 'Regular content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
        isInVault: false,
      );

      final vaultEntry = JournalEntry(
        title: 'Vault Entry',
        body: 'Vault content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 1)),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(regularEntry);
      await PlatformDatabaseService.addEntry(vaultEntry);

      final vaultEntries = await PlatformDatabaseService.getVaultEntries();
      expect(vaultEntries.length, 1);
      expect(vaultEntries.first.title, 'Vault Entry');
    });

    test('should update entry correctly', () async {
      final entry = JournalEntry(
        title: 'Original Title',
        body: 'Original content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
      );

      await PlatformDatabaseService.addEntry(entry);
      final entries = await PlatformDatabaseService.getAllEntries();
      final addedEntry = entries.first;

      final updatedEntry = JournalEntry(
        id: addedEntry.id,
        title: 'Updated Title',
        body: 'Updated content',
        createdAt: addedEntry.createdAt,
        reviewDate: addedEntry.reviewDate,
      );

      await PlatformDatabaseService.updateEntry(updatedEntry);
      final updatedEntries = await PlatformDatabaseService.getAllEntries();
      
      expect(updatedEntries.length, 1);
      expect(updatedEntries.first.title, 'Updated Title');
      expect(updatedEntries.first.body, 'Updated content');
    });

    test('should delete entry correctly', () async {
      final entry = JournalEntry(
        title: 'To Delete',
        body: 'Delete me',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
      );

      await PlatformDatabaseService.addEntry(entry);
      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, 1);

      await PlatformDatabaseService.deleteEntry(entries.first.id!);
      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, 0);
    });

    test('should clear vault data only', () async {
      final regularEntry = JournalEntry(
        title: 'Regular Entry',
        body: 'Regular content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
        isInVault: false,
      );

      final vaultEntry = JournalEntry(
        title: 'Vault Entry',
        body: 'Vault content',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now().add(const Duration(days: 1)),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(regularEntry);
      await PlatformDatabaseService.addEntry(vaultEntry);

      await PlatformDatabaseService.clearVaultData();
      
      final remainingEntries = await PlatformDatabaseService.getAllEntries();
      expect(remainingEntries.length, 1);
      expect(remainingEntries.first.title, 'Regular Entry');
    });

    test('should clear all data', () async {
      final entry1 = JournalEntry(
        title: 'Entry 1',
        body: 'Content 1',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
      );

      final entry2 = JournalEntry(
        title: 'Entry 2',
        body: 'Content 2',
        createdAt: DateTime.now(),
        reviewDate: DateTime.now(),
        isInVault: true,
      );

      await PlatformDatabaseService.addEntry(entry1);
      await PlatformDatabaseService.addEntry(entry2);

      await PlatformDatabaseService.clearAllData();
      final entries = await PlatformDatabaseService.getAllEntries();
      expect(entries.length, 0);
    });
  });
}
