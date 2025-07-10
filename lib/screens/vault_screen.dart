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

  @override
  void initState() {
    super.initState();
    fetchVaultEntries();
  }

  Future<void> fetchVaultEntries() async {
    final allEntries = await DatabaseService.getEntries();
    final now = DateTime.now();
    vaultEntries = allEntries.where((entry) => entry.reviewDate.isAfter(now)).toList();
    setState(() {});
  }

  Future<void> _confirmDeleteEntry(JournalEntry entry) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );
    if (confirm) {
      await DatabaseService.deleteEntry(entry.id!);
      fetchVaultEntries();
    }
  }

  Widget _buildVaultEntryCard(JournalEntry entry) {
    final now = DateTime.now();
    final isUnlocked = entry.reviewDate.isBefore(now) || entry.reviewDate.isAtSameMomentAs(now);

    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isUnlocked ? Colors.green : Colors.blueAccent, width: 2),
      ),
      child: ListTile(
        leading: Icon(isUnlocked ? Icons.lock_open : Icons.lock_outline,
            color: isUnlocked ? Colors.green : Colors.blueAccent),
        title: Text(entry.title),
        subtitle: Text(isUnlocked
            ? 'Unlocked for review'
            : 'Locked until ${entry.reviewDate.day}/${entry.reviewDate.month}/${entry.reviewDate.year}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _confirmDeleteEntry(entry),
        ),
        onTap: isUnlocked
            ? () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(entry.title),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (entry.imagePath != null)
                            Image.file(File(entry.imagePath!), height: 200),
                          SizedBox(height: 12),
                          Text(entry.body),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text('Vault'),
      ),
      body: vaultEntries.isEmpty
          ? Center(child: Text('No entries currently in the vault.'))
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
