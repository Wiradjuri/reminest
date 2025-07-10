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

  Future<void> _saveEntry(bool storeInVault) async {
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
      reviewDate: storeInVault ? _reviewDate : DateTime.now(),
    );

    await DatabaseService.insertEntry(entry);
    Navigator.pop(context);
  }

  void _promptVaultChoice() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Store in Vault?'),
        content: Text(
            'Would you like to store this entry in your vault for future review, or keep it available immediately?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveEntry(false);
            },
            child: Text('Keep Available'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveEntry(true);
            },
            child: Text('Store in Vault'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA), // Lavender background
      appBar: AppBar(
        title: Text('Add Journal Entry'),
        backgroundColor: Color(0xFF5B2C6F), // Deep Purple
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for your entry',
                  hintStyle: TextStyle(color: Color(0xFF888888)), // Light Gray
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: 'Body',
                  hintText: 'Write your thoughts here...',
                  hintStyle: TextStyle(color: Color(0xFF888888)), // Light Gray
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 6,
              ),
              SizedBox(height: 20),
              Text(
                'Review Date',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B2C6F)),
              ),
              SizedBox(height: 5),
              Text(
                'Choose when you can unlock this entry.',
                style: TextStyle(fontSize: 12, color: Color(0xFF333333)), // Dark Gray
              ),
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
                  '${_reviewDate.day}/${_reviewDate.month}/${_reviewDate.year}',
                  style: TextStyle(fontSize: 16, color: Color(0xFF5B2C6F)),
                ),
              ),
              SizedBox(height: 20),
              _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text('No image selected.'),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B2C6F), // Deep Purple
                  foregroundColor: Colors.white,
                ),
                onPressed: _pickImage,
                icon: Icon(Icons.photo),
                label: Text('Add Photo'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B2C6F), // Deep Purple
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _promptVaultChoice,
                  child: Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
