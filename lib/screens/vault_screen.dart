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
      final databaseService = DatabaseService();
      final allEntries = await databaseService.getAllEntries();
      
      setState(() {
        // Show ALL vault entries regardless of unlock status
        vaultEntries = allEntries.where((entry) => entry.isInVault).toList();
        // Sort by creation date (newest first)
        vaultEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
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
        title: Text('Delete Vault Entry', style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Text(
          'Are you sure you want to permanently delete this vault entry?\n\n"${entry.title}"\n\nThis action cannot be undone.',
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
    final now = DateTime.now();
    final isUnlocked = entry.reviewDate.isBefore(now) || entry.reviewDate.isAtSameMomentAs(now);
    
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          isUnlocked ? Icons.lock_open : Icons.lock,
          color: isUnlocked ? Colors.green : Colors.orange,
        ),
        title: Text(
          entry.title,
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color, 
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show content only if unlocked
            if (isUnlocked)
              Text(
                entry.body.length > 100 ? '${entry.body.substring(0, 100)}...' : entry.body,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Content locked until unlock date',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 4),
            Text(
              'Created: ${entry.createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
            ),
            if (isUnlocked)
              Text(
                'Unlocked: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
              )
            else
              Text(
                'Unlocks: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDeleteEntry(entry);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: isUnlocked ? () {
          // Show full entry details when tapped (only if unlocked)
          _showEntryDetails(entry);
        } : () {
          // Show locked message when tapped
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This entry is locked until ${entry.reviewDate.toLocal().toString().split(' ')[0]}'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  void _showEntryDetails(JournalEntry entry) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          entry.title,
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.body,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              SizedBox(height: 16),
              Text(
                'Created: ${entry.createdAt.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              ),
              Text(
                'Unlocked: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (entry.imagePath != null) ...[
                SizedBox(height: 16),
                Text(
                  'Attachment: ${entry.imagePath!.split('/').last}',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.primaryColor)),
          ),
        ],
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
                      Icon(
                        Icons.security,
                        size: 64,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No vault entries',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), 
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create entries and store them in the vault with time-locked access. Entries will automatically unlock on their scheduled date.',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5), 
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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
    );
  }
}
