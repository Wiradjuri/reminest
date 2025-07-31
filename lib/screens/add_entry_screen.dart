import 'dart:io'; // Import Dart IO library for file handling.
import 'package:flutter/material.dart'; // Import Flutter Material library for UI.
import 'package:file_picker/file_picker.dart'; // Import file_picker package for picking files/images.
import 'package:path/path.dart' as p; // Import path package for file path operations, aliased as p.
import 'package:reminest/models/journal_entry.dart'; // Import JournalEntry model.
import 'package:reminest/services/platform_database_service.dart'; // Import platform database service for saving entries.

// Stateful widget for adding a new journal entry.
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key}); // Constructor for AddEntryScreen.

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState(); // Create state for AddEntryScreen.
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController(); // Controller for the title input.
  final _bodyController = TextEditingController(); // Controller for the body/content input.
  final _titleFocusNode = FocusNode(); // Focus node for title field.
  final _bodyFocusNode = FocusNode(); // Focus node for body field.
  DateTime? _lockUntilDate; // Date to lock entry until (for vault).
  File? _selectedImage; // Selected image file.
  bool _storeInVault = false; // Indicates whether to store entry in vault.
  bool _isSaving = false; // Indicates if entry is being saved.

  @override
  void dispose() {
    _titleController.dispose(); // Dispose title controller.
    _bodyController.dispose(); // Dispose body controller.
    _titleFocusNode.dispose(); // Dispose title focus node.
    _bodyFocusNode.dispose(); // Dispose body focus node.
    super.dispose();
  }

  // Picks an image from the device using FilePicker.
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image); // Opens file picker for images.
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!); // Sets selected image.
      });
    }
  }

  // Shows date picker for selecting lock/review date.
  Future<DateTime?> _selectLockDate(BuildContext context) async {
    final theme = Theme.of(context); // Get current theme.
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Default to tomorrow.
      firstDate: DateTime.now().add(const Duration(days: 1)), // Minimum selectable date.
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Maximum selectable date.
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
        _lockUntilDate = picked; // Set lock date if picked.
      });
    }
    return picked;
  }

  // Clears the lock/review date.
  void _clearLockDate() {
    setState(() {
      _lockUntilDate = null;
    });
  }

  // Validates input and handles save logic.
  Future<void> _saveEntry() async {
    if (_isSaving) return; // Prevent duplicate saves.
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty.')),
      ); // Show error if title or body is empty.
      return;
    }

    // If storing in vault, ensure lock date is set.
    if (_storeInVault && _lockUntilDate == null) {
      await _selectLockDate(context);
      if (_lockUntilDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vault entries require a lock date. Please select a date or uncheck "Store in Vault".',
            ),
          ),
        ); // Show error if vault is selected but no date.
        return;
      }
    }

    // Determine if entry should be stored in vault.
    final bool shouldStoreInVault = _storeInVault;

    // Call the perform save function with vault and lock date info.
    await _performSave(
      storeInVault: shouldStoreInVault,
      lockUntilDate: _lockUntilDate,
    );
  }

  // Actually saves the entry to the database.
  Future<void> _performSave({
    required bool storeInVault,
    DateTime? lockUntilDate,
  }) async {
    setState(() => _isSaving = true); // Set saving flag.

    String? imagePath;
    if (_selectedImage != null && await _selectedImage!.exists()) {
      imagePath = _selectedImage!.path; // Get image path if image is selected.
    }

    // Create new JournalEntry object.
    final entry = JournalEntry(
      title: _titleController.text, // Entry title.
      body: _bodyController.text, // Entry body.
      reviewDate: storeInVault && lockUntilDate != null
          ? lockUntilDate // Use lock date if in vault.
          : _lockUntilDate ?? DateTime.now(), // Use review date or current date.
      imagePath: imagePath, // Path to attached image.
      isInVault: storeInVault, // Set vault status.
      createdAt: DateTime.now(), // Entry creation timestamp.
    );

    try {
      await PlatformDatabaseService.addEntry(entry); // Save entry to database.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              storeInVault
                  ? 'Entry saved to vault successfully! It will unlock on ${lockUntilDate?.toLocal().toString().split(' ')[0]}'
                  : _lockUntilDate != null
                      ? 'Entry saved to journal with future review date: ${_lockUntilDate!.toLocal().toString().split(' ')[0]}'
                      : 'Entry saved to journal successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        ); // Show success message based on storage type.
        await Future.delayed(const Duration(milliseconds: 500)); // Delay to allow SnackBar to show.
        Navigator.pop(context, true); // Return to previous screen.
      }
    } catch (e, stack) {
      debugPrint('Failed to save entry: $e\n$stack'); // Log error.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        ); // Show error message.
      }
    } finally {
      if (mounted) setState(() => _isSaving = false); // Reset saving flag.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Set background color.
      appBar: AppBar(
        title: const Text('Create New Entry'), // App bar title.
        backgroundColor: theme.primaryColor, // App bar background color.
        foregroundColor: Colors.white, // App bar text/icon color.
        elevation: 0, // Remove app bar elevation.
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding around body.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to start.
            children: [
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ), // Title label.
              const SizedBox(height: 8), // Space below label.
              TextField(
                controller: _titleController, // Controller for title field.
                focusNode: _titleFocusNode, // Focus node for title.
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onSubmitted: (_) => _bodyFocusNode.requestFocus(), // Move focus to body on submit.
                decoration: InputDecoration(
                  hintText: 'Enter a title for your entry', // Placeholder text.
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
              const SizedBox(height: 20), // Space below field.
              Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ), // Content label.
              const SizedBox(height: 8), // Space below label.
              TextField(
                controller: _bodyController, // Controller for body field.
                focusNode: _bodyFocusNode, // Focus node for body field.
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                maxLines: 12, // Max lines for content.
                decoration: InputDecoration(
                  hintText: 'Write your thoughts, feelings, or experiences...', // Placeholder text.
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
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20), // Space below content field.
              Container(
                padding: const EdgeInsets.all(16), // Inner padding.
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
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      'Set a lock date to automatically store this entry in the vault. It will be hidden until the date arrives.',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                            _lockUntilDate != null
                                ? Icons.security
                                : Icons.book,
                            color: _lockUntilDate != null
                                ? theme.primaryColor
                                : theme.iconTheme.color,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
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
                    const SizedBox(height: 12),
                    if (_lockUntilDate == null)
                      ElevatedButton.icon(
                        onPressed: () => _selectLockDate(context),
                        icon: const Icon(Icons.lock_clock, size: 18),
                        label: const Text('Set Lock Date'),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_clock,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearLockDate,
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Remove lock date',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _storeInVault
                      ? theme.primaryColor.withOpacity(0.1)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _storeInVault
                        ? theme.primaryColor.withOpacity(0.3)
                        : theme.dividerColor,
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
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Store in Vault'),
                      subtitle: Text(
                        'Check to store this entry in the vault (requires vault PIN + scheduled unlock date). Unchecked entries go to journal and can be accessed with your main password.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      value: _storeInVault, // Whether vault is selected.
                      onChanged: (value) async {
                        setState(() => _storeInVault = value ?? false);
                        // Do not automatically select a lock date here.
                      },
                      activeColor: theme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    // Section for selecting review or lock date.
                    Text(
                      'Review/Lock Date (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _storeInVault
                          ? 'This date will determine when the vault entry unlocks automatically'
                          : 'This date can be used for future review reminders in your journal',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_lockUntilDate == null)
                      ElevatedButton.icon(
                        onPressed: () => _selectLockDate(context),
                        icon: Icon(_storeInVault ? Icons.lock_clock : Icons.schedule, size: 18),
                        label: Text(_storeInVault ? 'Set Unlock Date' : 'Set Review Date'),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _storeInVault
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _storeInVault
                                      ? Colors.orange.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _storeInVault ? Icons.lock_clock : Icons.schedule,
                                    color: _storeInVault ? Colors.orange : Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _storeInVault
                                        ? 'Vault unlock: ${_lockUntilDate!.toLocal().toString().split(' ')[0]}'
                                        : 'Review date: ${_lockUntilDate!.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color: _storeInVault
                                          ? Colors.orange.shade700
                                          : Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearLockDate,
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Remove date',
                          ),
                        ],
                      ),
                    if (_storeInVault && _lockUntilDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_clock,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
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
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
                    if (_selectedImage == null)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: const Text('Add Photo'),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () =>
                                setState(() => _selectedImage = null),
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Remove photo',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
                  onPressed: _isSaving ? null : _saveEntry, // Disable if saving.
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : const Text(
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
