import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

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
    entries = await DatabaseService.getEntries();
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

  Future<void> _exportEntries() async {
    final userProfile = Platform.environment['USERPROFILE'] ?? 'C:\\';
    final documentsPath = '$userProfile\\Documents';
    final path = '$documentsPath\\mental_health_vault_export.txt';
    final file = File(path);

    StringBuffer buffer = StringBuffer();
    for (var entry in entries) {
      buffer.writeln('Title: ${entry.title}');
      buffer.writeln('Date: ${entry.createdAt}');
      buffer.writeln('Review Date: ${entry.reviewDate}');
      buffer.writeln('Body: ${entry.body}');
      buffer.writeln('-----------------------------');
    }

    await file.writeAsString(buffer.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to $path')),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Vault'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportEntries,
          ),
          IconButton(
            icon: Icon(Icons.lock),
            onPressed: () {
              Navigator.pushNamed(context, '/vault');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search entries...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredEntries.isEmpty
          ? Center(child: Text('No entries found.'))
          : ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                return ListTile(
                  leading: entry.imagePath != null
                      ? Image.file(
                          File(entry.imagePath!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.note),
                  title: Text(entry.title),
                  subtitle: Text(entry.body.length > 50
                      ? entry.body.substring(0, 50) + '...'
                      : entry.body),
                  trailing: Text(
                      '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          fetchEntries(); // Refresh after adding
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
