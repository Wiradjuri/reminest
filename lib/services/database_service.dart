import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        imagePath TEXT,
        createdAt TEXT,
        reviewDate TEXT,
        isReviewed INTEGER
      )
    ''');
  }

  static Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  static Future<List<JournalEntry>> getEntries() async {
    final db = await database;
    final result = await db.query('entries', orderBy: 'createdAt DESC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }
}
