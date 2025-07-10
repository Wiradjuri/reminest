import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';
import 'set_vault_pin_screen.dart';
import 'enter_vault_pin_screen.dart';
import '../services/key_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JournalEntry> entries = [];
  List<JournalEntry> filteredEntries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEntries();
    searchController.addListener(_filterEntries);
  }

  Future<void> fetchEntries() async {
    final allEntries = await DatabaseService.getEntries();
    final now = DateTime.now();

    entries = allEntries.where((entry) =>
        entry.reviewDate.isBefore(now) || entry.reviewDate.isAtSameMomentAs(now)).toList();

    filteredEntries = List.from(entries);
    setState(() {});
  }

  void _filterEntries() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredEntries = entries.where((entry) {
        return entry.title.toLowerCase().contains(query) ||
            entry.body.toLowerCase().contains(query);
      }).toList();
    });
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
      fetchEntries();
    }
  }

  void _showEntryInfo(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Created: ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}"),
            SizedBox(height: 8),
            Text("Unlocks: ${entry.reviewDate.day}/${entry.reviewDate.month}/${entry.reviewDate.year}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green, width: 2),
      ),
      child: ListTile(
        leading: entry.imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entry.imagePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.note, color: Color(0xFF5B2C6F)),
        title: Text(
          entry.title,
          style: TextStyle(color: Color(0xFF333333)),
        ),
        subtitle: Text(
          entry.body.length > 50 ? "${entry.body.substring(0, 50)}..." : entry.body,
          style: TextStyle(color: Color(0xFF555555)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, color: Color(0xFF5B2C6F)),
              tooltip: "Entry Info",
              onPressed: () => _showEntryInfo(entry),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Delete Entry",
              onPressed: () => _confirmDeleteEntry(entry),
            ),
          ],
        ),
        onTap: () => _showEntryInfo(entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text('Reminest'),
        backgroundColor: Color(0xFF5B2C6F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.lock),
            tooltip: "Open Vault",
            onPressed: () async {
              bool hasPin = await KeyService.hasVaultPin();
              if (hasPin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EnterVaultPinScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SetVaultPinScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Reminest",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B2C6F),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Encrypted personal journal. Entries here are viewable now; others remain locked in the Vault.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search entries...',
                    hintStyle: TextStyle(color: Color(0xFF888888)),
                    fillColor: Colors.white.withOpacity(0.9),
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: Color(0xFF5B2C6F)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(child: Text('No entries found.'))
                : ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return _buildEntryCard(entry);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF5B2C6F),
        foregroundColor: Colors.white,
        tooltip: 'Add Entry',
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          fetchEntries();
        },
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
