import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const EditEntryScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  DateTime? _lockUntilDate;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _bodyController = TextEditingController(text: widget.entry.body);
    _lockUntilDate = widget.entry.reviewDate.isAfter(DateTime.now()) ? widget.entry.reviewDate : null;
    
    // Load existing image if any
    if (widget.entry.imagePath != null && widget.entry.imagePath!.isNotEmpty) {
      _selectedImage = File(widget.entry.imagePath!);
    }
  }

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

  Future<void> _selectLockDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _lockUntilDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _lockUntilDate = picked;
      });
    }
  }

  void _clearLockDate() {
    setState(() {
      _lockUntilDate = null;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
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

    final updatedEntry = JournalEntry(
      id: widget.entry.id,
      title: _titleController.text,
      body: _bodyController.text,
      reviewDate: _lockUntilDate ?? DateTime.now(),
      imagePath: imagePath,
      isInVault: widget.entry.isInVault, // Keep original vault status
      createdAt: widget.entry.createdAt, // Keep original creation date
    );

    try {
      await DatabaseService.updateEntry(updatedEntry);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Failed to update entry: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update entry: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Entry'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSaving)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveEntry,
              tooltip: 'Save changes',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Enter a title for your entry',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Body Field
              Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _bodyController,
                maxLines: 10,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts here...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              SizedBox(height: 20),

              // Lock Date Section
              Text(
                'Lock Until Date (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _lockUntilDate != null
                            ? 'Lock until: ${_lockUntilDate!.toLocal().toString().split(' ')[0]}'
                            : 'No lock date set',
                        style: TextStyle(
                          color: _lockUntilDate != null 
                              ? theme.textTheme.bodyLarge?.color 
                              : theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _selectLockDate(context),
                    icon: Icon(Icons.calendar_today, color: theme.primaryColor),
                    tooltip: 'Select lock date',
                  ),
                  if (_lockUntilDate != null)
                    IconButton(
                      onPressed: _clearLockDate,
                      icon: Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Clear lock date',
                    ),
                ],
              ),

              SizedBox(height: 20),

              // Image Section
              Text(
                'Attach Image (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              
              if (_selectedImage != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text('Change Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _removeImage,
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: _pickImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, 
                             size: 32, color: theme.hintColor),
                        SizedBox(height: 8),
                        Text('Tap to add an image', 
                             style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving Changes...'),
                          ],
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
