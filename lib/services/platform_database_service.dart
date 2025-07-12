import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as desktop;
import 'package:path/path.dart' as p;
import '../models/journal_entry.dart';
import 'encryption_service.dart';

class PlatformDatabaseService {
  static dynamic _db;
  static bool _isInitialized = false;

  /// Initialize the appropriate database for the current platform
  static Future<void> initDB() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // For web, use shared_preferences instead of SQLite for now
        // We'll store data as JSON strings
        _isInitialized = true;
        print("[PlatformDatabaseService] Web storage initialized (using SharedPreferences)");
        return;
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms (Android/iOS)
        _db = await mobile.openDatabase(
          p.join(await mobile.getDatabasesPath(), 'journal_entries.db'),
          version: 1,
          onCreate: _createMobileTables,
        );
      } else {
        // Desktop platforms (Windows/Linux/macOS)
        desktop.sqfliteFfiInit();
        desktop.databaseFactory = desktop.databaseFactoryFfi;
        
        final dbPath = p.join(await desktop.getDatabasesPath(), 'journal_entries.db');
        _db = await desktop.databaseFactoryFfi.openDatabase(
          dbPath,
          options: desktop.OpenDatabaseOptions(
            version: 1,
            onCreate: _createDesktopTables,
          ),
        );
      }
      
      _isInitialized = true;
      print("[PlatformDatabaseService] Database initialized for ${_getPlatformName()}");
    } catch (e) {
      print("[PlatformDatabaseService] Error initializing database: $e");
      rethrow;
    }
  }

  /// Create database tables for mobile platforms
  static Future<void> _createMobileTables(mobile.Database db, int version) async {
    await db.execute('''
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
  }

  /// Create database tables for desktop platforms
  static Future<void> _createDesktopTables(desktop.Database db, int version) async {
    await db.execute('''
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
  }

  /// Get platform name for logging
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }

  /// Add a new journal entry to the database
  static Future<void> addEntry(JournalEntry entry) async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      // For web, we'll use a simple in-memory list for now
      print("[PlatformDatabaseService] Web storage not yet implemented for entries");
      return;
    }
    
    try {
      await _db!.insert('entries', {
        'title': EncryptionService.encryptText(entry.title),
        'body': EncryptionService.encryptText(entry.body),
        'imagePath': entry.imagePath,
        'createdAt': entry.createdAt.toIso8601String(),
        'reviewDate': entry.reviewDate.toIso8601String(),
        'isReviewed': entry.isReviewed ? 1 : 0,
        'isInVault': entry.isInVault ? 1 : 0,
      });
      print("[PlatformDatabaseService] Entry added successfully");
    } catch (e) {
      print("[PlatformDatabaseService] Error adding entry: $e");
      rethrow;
    }
  }

  /// Get all journal entries from the database
  static Future<List<JournalEntry>> getAllEntries() async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      // For web, return empty list for now
      return [];
    }
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query('entries');
      return maps.map((map) => _mapToJournalEntry(map)).toList();
    } catch (e) {
      print("[PlatformDatabaseService] Error getting all entries: $e");
      return [];
    }
  }

  /// Get entries that are not in the vault
  static Future<List<JournalEntry>> getRegularEntries() async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      return [];
    }
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'entries',
        where: 'isInVault = ?',
        whereArgs: [0],
      );
      return maps.map((map) => _mapToJournalEntry(map)).toList();
    } catch (e) {
      print("[PlatformDatabaseService] Error getting regular entries: $e");
      return [];
    }
  }

  /// Get entries that are in the vault
  static Future<List<JournalEntry>> getVaultEntries() async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      return [];
    }
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'entries',
        where: 'isInVault = ?',
        whereArgs: [1],
      );
      return maps.map((map) => _mapToJournalEntry(map)).toList();
    } catch (e) {
      print("[PlatformDatabaseService] Error getting vault entries: $e");
      return [];
    }
  }

  /// Update an existing journal entry
  static Future<void> updateEntry(JournalEntry entry) async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      print("[PlatformDatabaseService] Web update not yet implemented");
      return;
    }
    
    try {
      await _db!.update(
        'entries',
        {
          'title': EncryptionService.encryptText(entry.title),
          'body': EncryptionService.encryptText(entry.body),
          'imagePath': entry.imagePath,
          'reviewDate': entry.reviewDate.toIso8601String(),
          'isReviewed': entry.isReviewed ? 1 : 0,
          'isInVault': entry.isInVault ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      print("[PlatformDatabaseService] Entry updated successfully");
    } catch (e) {
      print("[PlatformDatabaseService] Error updating entry: $e");
      rethrow;
    }
  }

  /// Delete a journal entry by ID
  static Future<void> deleteEntry(int id) async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      print("[PlatformDatabaseService] Web delete not yet implemented");
      return;
    }
    
    try {
      await _db!.delete(
        'entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("[PlatformDatabaseService] Entry deleted successfully");
    } catch (e) {
      print("[PlatformDatabaseService] Error deleting entry: $e");
      rethrow;
    }
  }

  /// Clear all vault data (entries marked as in vault)
  static Future<void> clearVaultData() async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      print("[PlatformDatabaseService] Web vault clear not yet implemented");
      return;
    }
    
    try {
      await _db!.delete(
        'entries',
        where: 'isInVault = ?',
        whereArgs: [1],
      );
      print("[PlatformDatabaseService] Vault data cleared successfully");
    } catch (e) {
      print("[PlatformDatabaseService] Error clearing vault data: $e");
      rethrow;
    }
  }

  /// Clear all data from the database
  static Future<void> clearAllData() async {
    if (!_isInitialized) await initDB();
    
    if (kIsWeb) {
      print("[PlatformDatabaseService] Web clear all not yet implemented");
      return;
    }
    
    try {
      await _db!.delete('entries');
      print("[PlatformDatabaseService] All data cleared successfully");
    } catch (e) {
      print("[PlatformDatabaseService] Error clearing all data: $e");
      rethrow;
    }
  }

  /// Convert database map to JournalEntry object
  static JournalEntry _mapToJournalEntry(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: EncryptionService.decryptText(map['title']),
      body: EncryptionService.decryptText(map['body']),
      imagePath: map['imagePath'],
      createdAt: DateTime.parse(map['createdAt']),
      reviewDate: DateTime.parse(map['reviewDate']),
      isReviewed: map['isReviewed'] == 1,
      isInVault: map['isInVault'] == 1,
    );
  }

  /// Close the database connection
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _isInitialized = false;
      print("[PlatformDatabaseService] Database closed");
    }
  }
}
