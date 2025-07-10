import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Reminest/models/journal_entry.dart';
import 'package:Reminest/services/database_service.dart';

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
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF9B59B6),
              onPrimary: Colors.white,
              surface: Color(0xFF2E2E2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reviewDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_isSaving) return;
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? imagePath;
    if (_selectedImage != null && await _selectedImage!.exists()) {
      imagePath = _selectedImage!.path;
    }

    final entry = JournalEntry(
      title: _titleController.text,
      body: _bodyController.text,
      reviewDate: _reviewDate,
      imagePath: imagePath,
      isInVault: _storeInVault,
      createdAt: DateTime.now(),
    );

    try {
      await DatabaseService.addEntry(entry);
      if (mounted) Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('Failed to save entry: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E), // VS Code dark
      appBar: AppBar(
        title: Text('Add Entry'),
        backgroundColor: Color(0xFF9B59B6), // Sunset purple
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B59B6)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                style: TextStyle(color: Colors.white),
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B59B6)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Review Date: ${_reviewDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.redAccent,
                      elevation: 10,
                    ),
                    onPressed: () => _selectDate(context),
                    child: Text('Change Date'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _storeInVault,
                    activeColor: Color(0xFF9B59B6),
                    checkColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _storeInVault = value ?? false;
                      });
                    },
                  ),
                  Text('Store in Vault', style: TextStyle(color: Colors.white)),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.redAccent,
                      elevation: 10,
                    ),
                    onPressed: _pickImage,
                    child: Text('Attach Photo'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.redAccent,
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSaving ? null : _saveEntry,
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
