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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
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
      reviewDate: _reviewDate,
    );

    await DatabaseService.insertEntry(entry);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Journal Entry')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body'),
                maxLines: 6,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Review on: '),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _reviewDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _reviewDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                        '${_reviewDate.day}/${_reviewDate.month}/${_reviewDate.year}'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : Text('No image selected.'),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo),
                label: Text('Add Photo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
