import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'lib/models/journal_entry.dart';
import 'lib/services/encryption_service.dart';

class DatabaseService {
  static Database? _db;

  /// Initializes the database and creates the `entries` table if it doesn't exist.
  static Future<void> initDB() async {
    try {
      final dbPath = p.join(Directory.current.path, 'journal_entries.db');
      _db = sqlite3.open(dbPath);
      _db!.execute('''
        CREATE TABLE IF NOT EXISTS entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          body TEXT,
          imagePath TEXT,
          createdAt TEXT,
          reviewDate TEXT,
          isReviewed INTEGER DEFAULT 0,
          isInVault INTEGER DEFAULT 0
        )
      ''');
      print("[DatabaseService] Database initialized at $dbPath");
    } catch (e) {
      print("[DatabaseService] Error initializing database: $e");
    }
  }

  /// Adds a new journal entry to the database.
  static Future<void> addEntry(JournalEntry entry) async {
    if (_db == null) await initDB();
    try {
      _db!.execute(
        '''
        INSERT INTO entries (title, body, imagePath, createdAt, reviewDate, isReviewed, isInVault)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          EncryptionService.encryptText(entry.title),
          EncryptionService.encryptText(entry.body),
          entry.imagePath,
          entry.createdAt.toIso8601String(),
          entry.reviewDate.toIso8601String(),
          entry.isReviewed ? 1 : 0,
          entry.isInVault ? 1 : 0,
        ],
      );
      print("[DatabaseService] Entry added: ${entry.title}");
    } catch (e) {
      print("[DatabaseService] Error adding entry: $e");
    }
  }

  /// Fetches all journal entries from the database.
  static Future<List<JournalEntry>> getEntries() async {
    if (_db == null) await initDB();
    final entries = <JournalEntry>[];
    try {
      final result = _db!.select('SELECT * FROM entries');
      for (final row in result) {
        try {
          entries.add(JournalEntry(
            id: row['id'] as int,
            title: EncryptionService.decryptText(row['title'] as String),
            body: EncryptionService.decryptText(row['body'] as String),
            imagePath: row['imagePath'] as String?,
            createdAt: DateTime.parse(row['createdAt'] as String),
            reviewDate: DateTime.parse(row['reviewDate'] as String),
            isReviewed: row['isReviewed'] == 1,
            isInVault: row['isInVault'] == 1,
          ));
        } catch (e) {
          print("[DatabaseService] Skipping corrupted entry: $e");
        }
      }
      print("[DatabaseService] Fetched ${entries.length} entries");
    } catch (e) {
      print("[DatabaseService] Error fetching entries: $e");
    }
    return entries;
  }

  /// Updates an existing journal entry.
  static Future<void> updateEntry(JournalEntry entry) async {
    if (_db == null) await initDB();
    try {
      _db!.execute('''
        UPDATE entries SET
          title = ?,
          body = ?,
          reviewDate = ?,
          imagePath = ?,
          isInVault = ?
        WHERE id = ?
      ''', [
        EncryptionService.encryptText(entry.title),
        EncryptionService.encryptText(entry.body),
        entry.reviewDate.toIso8601String(),
        entry.imagePath,
        entry.isInVault ? 1 : 0,
        entry.id,
      ]);
      print("[DatabaseService] Entry updated: ID ${entry.id}");
    } catch (e) {
      print("[DatabaseService] Error updating entry: $e");
      throw e;
    }
  }

  /// Deletes a journal entry by its ID.
  static Future<void> deleteEntry(int id) async {
    if (_db == null) await initDB();
    try {
      _db!.execute('DELETE FROM entries WHERE id = ?', [id]);
      print("[DatabaseService] Entry deleted: ID $id");
    } catch (e) {
      print("[DatabaseService] Error deleting entry: $e");
    }
  }

  /// Clears all data from the `entries` table.
  static Future<void> clearAllData() async {
    if (_db == null) await initDB();
    try {
      _db!.execute('DELETE FROM entries');
      print("[DatabaseService] All data cleared");
    } catch (e) {
      print("[DatabaseService] Error clearing all data: $e");
    }
  }

  /// Clears only vault entries (entries with isInVault = 1).
  static Future<void> clearVaultData() async {
    if (_db == null) await initDB();
    try {
      _db!.execute('DELETE FROM entries WHERE isInVault = 1');
      print("[DatabaseService] Vault data cleared");
    } catch (e) {
      print("[DatabaseService] Error clearing vault data: $e");
    }
  }

  /// Clears the entire database (alias for `clearAllData`).
  static Future<void> clearDatabase() async => clearAllData();

  /// Instance method to fetch all journal entries from the database.
  Future<List<JournalEntry>> getAllEntries() async {
    return await getEntries();
  }
}
