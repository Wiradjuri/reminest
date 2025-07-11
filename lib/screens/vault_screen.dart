import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';
import 'add_entry_screen.dart';

class VaultScreen extends StatefulWidget {
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<JournalEntry> vaultEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVaultEntries();
  }

  Future<void> fetchVaultEntries() async {
    setState(() => _isLoading = true);
    try {
      final databaseService = DatabaseService();
      final allEntries = await databaseService.getAllEntries();
      vaultEntries = allEntries.where((entry) => entry.isInVault).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vault entries: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteEntry(JournalEntry entry) async {
     final theme = Theme.of(context);
    
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text('Delete Entry', style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Text(
          'Are you sure you want to delete this entry?',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.deleteEntry(entry.id!);
        fetchVaultEntries();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete entry: $e')),
        );
      }
    }
  }

  Widget _buildVaultEntryCard(JournalEntry entry) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          entry.title,
          style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.body.length > 100 ? '${entry.body.substring(0, 100)}...' : entry.body,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            SizedBox(height: 4),
            Text(
              'Created: ${entry.createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
            ),
            if (entry.reviewDate.isAfter(DateTime.now()))
              Text(
                'Locked until: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteEntry(entry),
          tooltip: 'Delete entry (vault entries cannot be edited)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Vault'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVaultEntries,
            tooltip: 'Refresh Vault',
          ),
        ],
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            )
          : vaultEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No locked entries in your vault.',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Go Back',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: vaultEntries.length,
                  itemBuilder: (context, index) {
                    final entry = vaultEntries[index];
                    return _buildVaultEntryCard(entry);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryScreen(forceVault: true),
            ),
          );
          if (result == true) {
            fetchVaultEntries(); // Refresh vault entries if a new one was added
          }
        },
        backgroundColor: theme.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add new vault entry',
      ),
    );
  }
}
