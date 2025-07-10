import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

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
      final allEntries = await DatabaseService.getEntries();
      final now = DateTime.now();
      vaultEntries = allEntries.where((entry) => entry.reviewDate.isAfter(now)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vault entries: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteEntry(JournalEntry entry) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text('Delete Entry', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this entry?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[300])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Color(0xFFFF4C4C))),
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
    return Card(
      color: const Color(0xFF2E2E2E),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          entry.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Unlocks on: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.grey[300]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFFFF4C4C)),
          onPressed: () => _confirmDeleteEntry(entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // VS Code dark background

      appBar: AppBar(
        title: const Text('Vault'),
        backgroundColor: const Color(0xFF9B59B6), // Sunset purple
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
            )
          : vaultEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No locked entries in your vault.',
                        style: TextStyle(color: Colors.grey[300], fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF), // Blue
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
    );
  }
}
