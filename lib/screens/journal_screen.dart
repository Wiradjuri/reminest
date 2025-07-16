import 'package:flutter/material.dart';
import 'package:reminest/models/journal_entry.dart';
import 'package:reminest/services/platform_database_service.dart';
import 'package:reminest/screens/add_entry_screen.dart';
import 'package:reminest/screens/edit_entry_screen.dart';
import 'package:reminest/screens/view_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final allEntries = await PlatformDatabaseService.getAllEntries();
      if (!mounted) return;
      setState(() {
        entries = allEntries.where((entry) => !entry.isInVault).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load entries: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isFutureEntry = entry.reviewDate.isAfter(now);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: isFutureEntry
            ? const Icon(Icons.schedule, color: Colors.blue)
            : Icon(Icons.book, color: theme.primaryColor),
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
            Text(
              entry.body.length > 100
                  ? '${entry.body.substring(0, 100)}...'
                  : entry.body,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 4),
            Text(
              'Created: ${entry.createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            if (isFutureEntry)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Review date: ${entry.reviewDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _viewEntry(entry),
              tooltip: 'View entry',
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.primaryColor),
              onPressed: () => _editEntry(entry),
              tooltip: 'Edit entry',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEntry(entry),
              tooltip: 'Delete entry',
            ),
          ],
        ),
        onTap: () => _viewEntry(entry),
      ),
    );
  }

  Future<void> _viewEntry(JournalEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewEntryScreen(entry: entry)),
    );
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEntryScreen(entry: entry)),
    );

    if (result == true) {
      _loadEntries(); // Refresh the list
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PlatformDatabaseService.deleteEntry(entry.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadEntries(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // No AppBar or BottomNavigationBar here; handled globally in main.dart
      body: entries.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journal entries yet.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Journal entries are always accessible with your main password, even if they have future review dates.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildEntryCard(entry);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
          if (result == true) {
            _loadEntries(); // Refresh entries if a new one was added
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add new entry',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}