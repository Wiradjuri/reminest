import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class AddEntryScreen extends StatefulWidget {
  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  DateTime _reviewDate = DateTime.now().add(Duration(days: 7));
  File? _selectedImage;
  bool _storeInVault = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reviewDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _reviewDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    final entry = JournalEntry(
      title: _titleController.text,
      body: _bodyController.text,
      imagePath: _selectedImage?.path,
      createdAt: DateTime.now(),
      reviewDate: _storeInVault ? _reviewDate : DateTime.now(),
    );

    await DatabaseService.insertEntry(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text('Add Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: Colors.white),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Body', filled: true, fillColor: Colors.white),
              maxLines: 5,
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Store in Vault'),
              value: _storeInVault,
              onChanged: (val) {
                setState(() {
                  _storeInVault = val;
                  if (!_storeInVault) {
                    _reviewDate = DateTime.now();
                  }
                });
              },
            ),
            if (_storeInVault)
              ListTile(
                title: Text("Unlock Date: ${_reviewDate.day}/${_reviewDate.month}/${_reviewDate.year}"),
                trailing: Icon(Icons.calendar_today, color: Color(0xFF5B2C6F)),
                onTap: () => _selectDate(context),
              ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Pick Image'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
