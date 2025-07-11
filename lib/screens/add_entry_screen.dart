import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class AddEntryScreen extends StatefulWidget {
  final bool forceVault;

  const AddEntryScreen({Key? key, this.forceVault = false}) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  DateTime? _lockUntilDate; // Optional lock date
  File? _selectedImage;
  bool _storeInVault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.forceVault) {
      _storeInVault = true;
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
      initialDate: DateTime.now().add(Duration(days: 1)),
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

  Future<void> _saveEntry() async {
    if (_isSaving) return;
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    // Show confirmation dialog with options
    if (widget.forceVault) {
      // If forced to vault, save directly to vault
      await _performSave(storeInVault: true, lockUntilDate: _lockUntilDate);
    } else {
      await _showSaveOptionsDialog();
    }
  }

  Future<void> _showSaveOptionsDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _SaveOptionsDialog(
        hasLockDate: _lockUntilDate != null,
        lockDate: _lockUntilDate,
        initialStoreInVault: _storeInVault,
      ),
    );

    if (result != null) {
      await _performSave(
        storeInVault: result['storeInVault'] ?? false,
        lockUntilDate: result['lockUntilDate'],
      );
    }
  }

  Future<void> _performSave({
    required bool storeInVault,
    DateTime? lockUntilDate,
  }) async {
    setState(() => _isSaving = true);

    String? imagePath;
    if (_selectedImage != null && await _selectedImage!.exists()) {
      imagePath = _selectedImage!.path;
    }

    final entry = JournalEntry(
      title: _titleController.text,
      body: _bodyController.text,
      reviewDate: lockUntilDate ?? DateTime.now(), // Use lock date as review date
      imagePath: imagePath,
      isInVault: storeInVault,
      createdAt: DateTime.now(),
    );

    try {
      await DatabaseService.addEntry(entry);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storeInVault 
              ? 'Entry saved to vault successfully!'
              : 'Entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.forceVault ? 'Create New Vault Entry' : 'Create New Entry'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts, feelings, or experiences...',
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
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Optional Time Lock Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: theme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Time Lock (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lock this entry until a specific date. It will be hidden and only viewable after the date passes.',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _lockUntilDate != null 
                            ? theme.primaryColor.withOpacity(0.1)
                            : theme.cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _lockUntilDate != null 
                              ? theme.primaryColor.withOpacity(0.3)
                              : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lockUntilDate != null ? Icons.security : Icons.book,
                            color: _lockUntilDate != null ? theme.primaryColor : theme.iconTheme.color,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lockUntilDate != null 
                                  ? '📁 This entry will be saved in the VAULT (time-locked)'
                                  : '📝 This entry will be saved in the JOURNAL (immediately accessible)',
                              style: TextStyle(
                                color: _lockUntilDate != null 
                                    ? theme.primaryColor
                                    : theme.textTheme.bodySmall?.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_lockUntilDate == null)
                      ElevatedButton.icon(
                        onPressed: () => _selectLockDate(context),
                        icon: Icon(Icons.lock_clock, size: 18),
                        label: Text('Set Lock Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_clock, color: Colors.orange, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Locked until: ${_lockUntilDate!.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearLockDate,
                            icon: Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Remove lock date',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Photo Attachment Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_camera, color: theme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Photo Attachment (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_selectedImage == null)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.add_photo_alternate, size: 18),
                        label: Text('Add Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Photo selected: ${_selectedImage!.path.split('/').last}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Remove photo',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveEntry,
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
                            Text('Saving...'),
                          ],
                        )
                      : Text(
                          'Create Entry',
                          style: TextStyle(
                            fontSize: 16,
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

class _SaveOptionsDialog extends StatefulWidget {
  final bool hasLockDate;
  final DateTime? lockDate;
  final bool initialStoreInVault;

  _SaveOptionsDialog({
    required this.hasLockDate,
    required this.lockDate,
    required this.initialStoreInVault,
  });

  @override
  _SaveOptionsDialogState createState() => _SaveOptionsDialogState();
}

class _SaveOptionsDialogState extends State<_SaveOptionsDialog> {
  bool _storeInVault = false;

  @override
  void initState() {
    super.initState();
    _storeInVault = widget.initialStoreInVault;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Save Entry Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose where to save your entry:',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          
          // Time lock info
          if (widget.hasLockDate) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_clock, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This entry will be locked until ${widget.lockDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // Storage options
          CheckboxListTile(
            title: Text('Store in Vault'),
            subtitle: Text(
              'Requires PIN to access. More secure.',
              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
            ),
            value: _storeInVault,
            onChanged: (value) => setState(() => _storeInVault = value ?? false),
            activeColor: theme.primaryColor,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'storeInVault': _storeInVault,
              'lockUntilDate': widget.lockDate,
            });
          },
          child: Text('Save Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
