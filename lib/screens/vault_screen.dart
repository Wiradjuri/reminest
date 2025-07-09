import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

class VaultScreen extends StatefulWidget {
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<JournalEntry> dueEntries = [];

  @override
  void initState() {
    super.initState();
    fetchDueEntries();
  }

  Future<void> fetchDueEntries() async {
    final allEntries = await DatabaseService.getEntries();
    final now = DateTime.now();
    dueEntries =
        allEntries.where((entry) => entry.reviewDate.isBefore(now)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vault Review')),
      body: dueEntries.isEmpty
          ? Center(child: Text('No entries ready for review.'))
          : ListView.builder(
              itemCount: dueEntries.length,
              itemBuilder: (context, index) {
                final entry = dueEntries[index];
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
    );
  }
}
