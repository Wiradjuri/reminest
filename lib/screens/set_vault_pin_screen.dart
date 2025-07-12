import 'package:flutter/material.dart'; // Import Flutter material package for UI widgets
import '../services/key_service.dart'; // Import custom key service for PIN storage
import 'vault_screen.dart'; // Import the vault screen to navigate after setting PIN

// Stateful widget for setting the vault PIN
class SetVaultPinScreen extends StatefulWidget {
  final VoidCallback? onComplete; // Optional callback when PIN is set successfully
  
  SetVaultPinScreen({this.onComplete});
  
  @override
  State<SetVaultPinScreen> createState() => _SetVaultPinScreenState(); // Create state for the widget
}

// State class for SetVaultPinScreen
class _SetVaultPinScreenState extends State<SetVaultPinScreen> {
  final _pinController = TextEditingController(); // Controller for PIN input
  final _confirmController = TextEditingController(); // Controller for confirm PIN input
  bool _isButtonEnabled = false; // Tracks if the set PIN button should be enabled
  bool _isLoading = false; // Tracks if the PIN is being set (shows loading indicator)

  @override
  void initState() {
    super.initState(); // Call parent initState
    // Add listeners to update button state when text changes
    _pinController.addListener(_updateButtonState);
    _confirmController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _pinController.removeListener(_updateButtonState); // Remove listener from PIN controller
    _confirmController.removeListener(_updateButtonState); // Remove listener from confirm controller
    _pinController.dispose(); // Dispose PIN controller
    _confirmController.dispose(); // Dispose confirm controller
    super.dispose(); // Call parent dispose
  }

  // Updates the state of the set PIN button based on input fields
  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _pinController.text.isNotEmpty && 
                        _confirmController.text.isNotEmpty; // Enable if both fields are not empty
    });
  }

  // Handles setting the PIN
  void _setPin() async {
    if (_isLoading) return; // Prevent multiple submissions
    
    // Check if PIN and confirm PIN match
    if (_pinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match.')), // Show error if not matching
      );
      return;
    }
    // Validate PIN length and digits
    if (_pinController.text.length < 4 || _pinController.text.length > 6 ||
        !RegExp(r'^\d+$').hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must be 4-6 digits.')), // Show error if invalid
      );
      return;
    }

    setState(() => _isLoading = true); // Show loading indicator

    try {
      await KeyService.saveVaultPin(_pinController.text); // Save the PIN using KeyService
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vault PIN set successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Use callback if provided, otherwise navigate to vault screen
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          // Navigate to vault screen, replacing current screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VaultScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set PIN: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Set background color

      appBar: AppBar(
        title: Text('Set Vault PIN'), // App bar title
        backgroundColor: theme.primaryColor, // App bar background color
        foregroundColor: Colors.white, // App bar text/icon color
        elevation: 0, // No shadow
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around content
        child: Column(
          children: [
            // Information section
            Container(
              width: double.infinity, // Full width
              padding: EdgeInsets.all(16), // Inner padding
              margin: EdgeInsets.only(bottom: 24), // Margin below
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1), // Light orange background
                border: Border.all(color: Colors.orange.withOpacity(0.3)), // Orange border
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align left
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 24), // Warning icon
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        "Important: PIN Security", // Section title
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Space below row
                  Text(
                    "• Your vault PIN is unrecoverable\n• If forgotten, all vault data will be lost\n• Choose a PIN you'll remember (4-6 digits)", // Info text
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _pinController, // Controller for PIN input
              enabled: !_isLoading, // Disable if loading
              obscureText: true, // Hide input (password style)
              keyboardType: TextInputType.number, // Numeric keyboard
              maxLength: 6, // Max 6 digits
              onSubmitted: (_) => _isLoading ? null : _setPin(),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Text color
              decoration: InputDecoration(
                hintText: 'Enter 4-6 digit PIN', // Placeholder text
                hintStyle: TextStyle(color: theme.hintColor), // Hint color
                counterText: "", // Hide counter
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor), // Border color when enabled
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor), // Border color when focused
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)), // Border color when disabled
                ),
              ),
            ),
            SizedBox(height: 20), // Space between fields
            TextField(
              controller: _confirmController, // Controller for confirm PIN input
              enabled: !_isLoading, // Disable if loading
              obscureText: true, // Hide input
              keyboardType: TextInputType.number, // Numeric keyboard
              maxLength: 6, // Max 6 digits
              onSubmitted: (_) => _isLoading ? null : _setPin(),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Text color
              decoration: InputDecoration(
                hintText: 'Confirm PIN', // Placeholder text
                hintStyle: TextStyle(color: theme.hintColor), // Hint color
                counterText: "", // Hide counter
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor), // Border color when enabled
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor), // Border color when focused
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)), // Border color when disabled
                ),
              ),
            ),
            SizedBox(height: 40), // Space before button
            SizedBox(
              width: double.infinity, // Button takes full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  elevation: 6, // Button shadow
                  padding: EdgeInsets.symmetric(vertical: 14), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                onPressed: (_isButtonEnabled && !_isLoading) ? _setPin : null, // Enable if inputs valid and not loading
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center loading row
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White spinner
                            ),
                          ),
                          SizedBox(width: 12), // Space between spinner and text
                          Text(
                            'Setting PIN...', // Loading text
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        'Set PIN', // Button text
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
