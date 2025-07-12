import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:reminest/models/journal_entry.dart';
import 'package:reminest/services/platform_database_service.dart';

class AddEntryScreen extends StatefulWidget {
  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _bodyFocusNode = FocusNode();
  DateTime? _lockUntilDate; // Optional lock date unless specified with ticked store in vault box
  File? _selectedImage; // optional image attachment
  bool _storeInVault = false; // Whether to store in vault or journal
  bool _isSaving = false; // Whether currently saving entry

  @override
  void dispose() {
    // Release the resources used by the title TextEditingController
    _titleController.dispose();
    // Release the resources used by the body TextEditingController
    _bodyController.dispose();
    // Dispose focus nodes
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    // Call the dispose method of the parent class to ensure proper disposal of all resources
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

  Future<DateTime?> _selectLockDate(BuildContext context) async {
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
    return picked;
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

    // If lock date is set, automatically store in vault
    // If user wants vault but no date is set, show date picker
    if (_storeInVault && _lockUntilDate == null) {
      // User wants vault but hasn't set a date - prompt for date
      await _selectLockDate(context);
      if (_lockUntilDate == null) {
        // User cancelled date selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vault entries require a lock date. Please select a date or uncheck "Store in Vault".')),
        );
        return;
      }
    }

    // Determine storage location based on lock date
    final bool shouldStoreInVault = _lockUntilDate != null;
    
    // Perform save directly without dialog
    await _performSave(
      storeInVault: shouldStoreInVault,
      lockUntilDate: _lockUntilDate,
    );
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
      reviewDate: storeInVault 
          ? (lockUntilDate ?? DateTime.now().add(Duration(minutes: 1))) // Default vault unlock in 1 minute for testing
          : DateTime.now(), // Journal entries are immediately available
      imagePath: imagePath,
      isInVault: storeInVault,
      createdAt: DateTime.now(),
    );

    try {
      await PlatformDatabaseService.addEntry(entry);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storeInVault 
              ? 'Entry saved to vault successfully!'
              : 'Entry saved to journal successfully!'),
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
        title: Text('Create New Entry'),
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
                focusNode: _titleFocusNode,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onSubmitted: (_) => _bodyFocusNode.requestFocus(),
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
                focusNode: _bodyFocusNode,
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
                          'Vault Time Lock',
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
                      'Set a lock date to automatically store this entry in the vault. It will be hidden until the date arrives.',
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
              
              // Vault Storage Option
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _storeInVault ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _storeInVault ? theme.primaryColor.withOpacity(0.3) : theme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vault Storage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text('Store in Vault'),
                      subtitle: Text(
                        'Check to store this entry in the vault (requires a lock date for automatic time-based access)',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                      value: _storeInVault,
                      onChanged: (value) async {
                        if (value == true && _lockUntilDate == null) {
                          // If vault is checked but no date is set, prompt for date
                          final selectedDate = await _selectLockDate(context);
                          if (selectedDate != null) {
                            setState(() {
                              _storeInVault = true;
                              _lockUntilDate = selectedDate;
                            });
                          }
                        } else {
                          setState(() => _storeInVault = value ?? false);
                        }
                      },
                      activeColor: theme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_storeInVault && _lockUntilDate != null) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_clock, color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Will be stored in vault and locked until ${_lockUntilDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                                      'Photo selected: ${p.basename(_selectedImage!.path)}',
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


