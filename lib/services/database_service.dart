import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../models/journal_entry.dart';
import 'encryption_service.dart';

class DatabaseService {
  static late Database db;

  static Future<void> initDB() async {
    final dbPath = p.join(Directory.current.path, 'journal_entries.db');
    db = sqlite3.open(dbPath);

    db.execute('''
      CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        imagePath TEXT,
        createdAt TEXT,
        reviewDate TEXT,
        isReviewed INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> insertEntry(JournalEntry entry) async {
    try {
      print('[DB] Inserting: ${entry.title}, reviewDate: ${entry.reviewDate.toIso8601String()}');

      db.execute('''
        INSERT INTO entries (title, body, imagePath, createdAt, reviewDate, isReviewed)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        EncryptionService.encryptText(entry.title),
        EncryptionService.encryptText(entry.body),
        entry.imagePath,
        entry.createdAt.toIso8601String(),
        entry.reviewDate.toIso8601String(),
        entry.isReviewed ? 1 : 0,
      ]);
    } catch (e) {
      print('Error inserting entry: $e');
    }
  }

  static Future<List<JournalEntry>> getEntries() async {
    final List<JournalEntry> entries = [];
    try {
      final ResultSet result = db.select('SELECT * FROM entries');
      for (final row in result) {
        try {
          final title = EncryptionService.decryptText(row['title'] as String);
          final body = EncryptionService.decryptText(row['body'] as String);

          entries.add(JournalEntry(
            id: row['id'] as int,
            title: title,
            body: body,
            imagePath: row['imagePath'] as String?,
            createdAt: DateTime.parse(row['createdAt'] as String),
            reviewDate: DateTime.parse(row['reviewDate'] as String),
            isReviewed: (row['isReviewed'] as int) == 1,
          ));
        } catch (e) {
          print('Skipping corrupted entry with id ${row['id']}: $e');
        }
      }
    } catch (e) {
      print('Error fetching entries: $e');
    }
    return entries;
  }

  static Future<void> deleteEntry(int id) async {
    try {
      db.execute('DELETE FROM entries WHERE id = ?', [id]);
      print('Entry with id $id deleted.');
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }

  static Future<void> clearDatabase() async {
    try {
      db.execute('DELETE FROM entries');
      print('Database cleared.');
    } catch (e) {
      print('Error clearing database: $e');
    }
  }
}
