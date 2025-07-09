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

  void _showEntryDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(entry.imagePath!),
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 12),
              Text(entry.body),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))
        ],
      ),
    );
  }

  Widget _buildVaultEntryCard(JournalEntry entry) {
    final now = DateTime.now();
    final isUnlocked = entry.reviewDate.isBefore(now) || entry.reviewDate.isAtSameMomentAs(now);

    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: 1,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(
            isUnlocked ? Icons.lock_open : Icons.lock_outline,
            color: isUnlocked ? Color(0xFF5B2C6F) : Colors.grey,
          ),
          title: Text(entry.title),
          subtitle: isUnlocked
              ? Text('Unlocked and ready for review')
              : Text('Locked until ${entry.reviewDate.day}/${entry.reviewDate.month}/${entry.reviewDate.year}'),
          trailing: Text(
              '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}'),
          onTap: isUnlocked ? () => _showEntryDialog(entry) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
