import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import '../services/password_service.dart';
import 'journal_screen.dart';
import 'vault_screen.dart';
import 'set_password_screen.dart';
import 'set_vault_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  LoginScreen({this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String _error = '';
  bool _isLoading = false;
  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  /// Check if password exists
  Future<void> _checkPasswordStatus() async {
    final hasPassword = await PasswordService.isPasswordSet();
    setState(() {
      _hasPassword = hasPassword;
    });
  }

  /// Handle begin setup
  void _beginSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SetPasswordScreen(
          onPasswordSet: () {
            // Automatically log in after password setup
            if (widget.onLoginSuccess != null) {
              widget.onLoginSuccess!();
            }
          },
        ),
      ),
    );
  }

  void _handleForgotPassword() async {
    showDialog(
      context: context,
      builder: (context) => _PasswordRecoveryDialog(
        onSuccessfulRecovery: () {
          print("[LoginScreen] Recovery dialog callback triggered");
          // Navigate to the main app using the callback
          if (widget.onLoginSuccess != null) {
            print("[LoginScreen] Calling widget.onLoginSuccess");
            widget.onLoginSuccess!();
            print("[LoginScreen] widget.onLoginSuccess completed");
          } else {
            print("[LoginScreen] ERROR: widget.onLoginSuccess is null!");
          }
        },
      ),
    );
  }

  /// Verify password using PasswordService
  Future<bool> _checkPassword(String input) async {
    return await PasswordService.verifyPassword(input);
  }

  /// Submit login form
  void _submit() async {
    // If no password is set, redirect to setup
    if (!_hasPassword) {
      _beginSetup();
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    final input = _passwordController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _error = "Please enter your password.";
        _isLoading = false;
      });
      return;
    }

    try {
      final correct = await _checkPassword(input);
      print("[LoginScreen] Password verification result: $correct");
      if (correct) {
        print("[LoginScreen] Password correct, calling _navigateToJournal()");

        // Initialize encryption service with the password
        try {
          final encryptionKey = KeyService.generateKeyFromPassword(input);
          EncryptionService.initializeKey(encryptionKey);
          print("[LoginScreen] Encryption service initialized successfully");
        } catch (e) {
          print("[LoginScreen] Error initializing encryption service: $e");
          setState(
            () => _error = "Failed to initialize encryption. Please try again.",
          );
          return;
        }

        // For maximum security, no "remember me" functionality
        // Users must enter password every time

        // Navigate to journal
        _navigateToJournal();
      } else {
        setState(() => _error = "Incorrect password. Please try again.");
      }
    } catch (e) {
      print("[LoginScreen] Login error: $e");
      setState(() => _error = "Login failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Navigate to journal screen after successful login
  void _navigateToJournal() {
    print("[LoginScreen] _navigateToJournal called");
    if (widget.onLoginSuccess != null) {
      print("[LoginScreen] Calling onLoginSuccess callback");
      widget.onLoginSuccess!();
      print("[LoginScreen] onLoginSuccess callback completed");
      // Pop the login screen so the authenticated MainScaffold can be shown
      print(
        "[LoginScreen] Popping login screen to reveal authenticated interface",
      );
      Navigator.pop(context);
    } else {
      print("[LoginScreen] WARNING: No onLoginSuccess callback provided");
    }
  }

  /// Handle vault access
  void _openVault() async {
    final hasPin = await KeyService.hasVaultPin();
    if (!hasPin) {
      // Navigate to Set Vault PIN screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SetVaultPinScreen()),
      );
      return;
    }

    // Show PIN dialog
    _showVaultPinDialog();
  }

  /// Show vault PIN entry dialog
  void _showVaultPinDialog() {
    final pinController = TextEditingController();
    String pinError = '';

    void verifyVaultPin(String pin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        return;
      }

      final isValid = await KeyService.verifyVaultPin(pin);
      if (isValid) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VaultScreen()),
        );
      } else {
        setDialogState(() => pinError = "Incorrect PIN. Try again.");
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Enter Vault PIN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "4-6 digit PIN",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) =>
                    verifyVaultPin(pinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  pinError,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  verifyVaultPin(pinController.text, setDialogState),
              child: Text("Open Vault"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Login to Reminest"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.lock),
            tooltip: "Access Vault",
            onPressed: _openVault,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Icon
                Icon(Icons.lock_outline, size: 64, color: theme.primaryColor),
                SizedBox(height: 16),

                // Title
                Text(
                  _hasPassword ? "Unlock Your Journal" : "Welcome to Reminest",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),

                // Subtitle
                Text(
                  _hasPassword
                      ? "Enter your password to access your journal entries"
                      : "Let's get you set up to start journaling securely",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Password field (only show if password is set)
                if (_hasPassword) ...[
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your journal password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _isLoading ? null : _submit(),
                  ),
                  SizedBox(height: 16),

                  // Forgot password link (only show if password is set)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],

                // Error message
                if (_error.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 24),

                // Login button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Verifying..."),
                            ],
                          )
                        : Text(
                            _hasPassword ? "Unlock Journal" : "Begin Setup",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),

                // Help text
                Text(
                  _hasPassword
                      ? "Your journal is encrypted and secure. Only you can access it with your password."
                      : "Set up your secure password to start journaling. Your entries will be encrypted and private.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordRecoveryDialog extends StatefulWidget {
  final VoidCallback onSuccessfulRecovery;

  _PasswordRecoveryDialog({required this.onSuccessfulRecovery});

  @override
  _PasswordRecoveryDialogState createState() => _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<_PasswordRecoveryDialog> {
  final _passkeyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPasskeyOption = true;
  bool _isRecovering = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Text(
        _showPasskeyOption ? "Password Recovery" : "Reset Password",
        style: TextStyle(color: theme.textTheme.titleLarge?.color),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showPasskeyOption) ...[
              Text(
                "Enter your recovery passkey to reset your password:",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passkeyController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onSubmitted: (_) => _recoverWithPasskey(),
                decoration: InputDecoration(
                  hintText: 'Enter 16-character passkey',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: OutlineInputBorder(),
                  errorText: _error.isNotEmpty ? _error : null,
                ),
                maxLength: 16,
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPasskeyOption = false;
                    _error = '';
                  });
                },
                child: Text(
                  "Don't have your passkey? Reset all data",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ] else ...[
              Text(
                "Enter new password:",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                obscureText: true,
                onSubmitted: (_) => _resetAllData(),
                decoration: InputDecoration(
                  hintText: 'New password',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                obscureText: true,
                onSubmitted: (_) => _resetAllData(),
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: OutlineInputBorder(),
                  errorText: _error.isNotEmpty ? _error : null,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Warning",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This will permanently delete all your journal entries and vault data. This action cannot be undone.",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        if (_showPasskeyOption)
          ElevatedButton(
            onPressed: _isRecovering ? null : _recoverWithPasskey,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isRecovering
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Recover'),
          )
        else
          ElevatedButton(
            onPressed: _isRecovering ? null : _resetAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: _isRecovering
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Reset All Data'),
          ),
      ],
    );
  }

  void _recoverWithPasskey() async {
    final passkey = _passkeyController.text.trim().toUpperCase();

    if (passkey.length != 16) {
      setState(() => _error = 'Passkey must be 16 characters');
      return;
    }

    setState(() {
      _isRecovering = true;
      _error = '';
    });

    // Show password reset form
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _NewPasswordDialog(passkey: passkey),
    );

    if (result != null && result.isNotEmpty) {
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset successfully! Logging you in...'),
          backgroundColor: Colors.green,
        ),
      );

      // Automatically log the user in with the new password
      try {
        final encryptionKey = KeyService.generateKeyFromPassword(result);
        EncryptionService.initializeKey(encryptionKey);

        // Navigate to the main app using the callback
        widget.onSuccessfulRecovery();
      } catch (e) {
        print("[LoginScreen] Error during auto-login after password reset: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset successful, but auto-login failed. Please login manually.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() => _isRecovering = false);
  }

  void _resetAllData() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isRecovering = true;
      _error = '';
    });

    try {
      // Clear all password and security data with secure deletion
      await PasswordService.clearPasswordData();
      await KeyService.clearAllPasswordData();
      await KeyService.clearVaultPin();

      // Also clear any remaining old format files
      await _clearLegacyFiles();

      // Set the new password and get the passkey
      final passkey = await PasswordService.setPassword(newPassword);

      // Also save with KeyService for backward compatibility
      await KeyService.savePassword(newPassword);
      await KeyService.setPasswordSetFlag();

      Navigator.pop(context);

      // Show the passkey to the user before auto-login
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.key, color: Colors.amber),
              SizedBox(width: 8),
              Text('Your New Recovery Passkey'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'IMPORTANT: Save this passkey!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This passkey can be used to recover your APPLICATION PASSWORD if you forget it.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Passkey:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      passkey,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: passkey));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Passkey copied to clipboard!'),
                          ),
                        );
                      },
                      icon: Icon(Icons.copy, size: 16),
                      label: Text('Copy Passkey'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close passkey dialog

                // Small delay to let the dialog close completely
                await Future.delayed(Duration(milliseconds: 100));

                // Show success message and auto-login
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All data reset successfully! Logging you in...',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Small delay to show the message
                await Future.delayed(Duration(milliseconds: 500));

                // Automatically log the user in with the new password
                try {
                  final encryptionKey = KeyService.generateKeyFromPassword(
                    newPassword,
                  );
                  EncryptionService.initializeKey(encryptionKey);

                  print(
                    "[LoginScreen] About to call onSuccessfulRecovery callback",
                  );
                  // Navigate to the main app using the callback
                  widget.onSuccessfulRecovery();
                  print(
                    "[LoginScreen] onSuccessfulRecovery callback completed",
                  );
                } catch (e) {
                  print(
                    "[LoginScreen] Error during auto-login after reset: $e",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reset successful, but auto-login failed. Please login manually.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('I have saved my passkey'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = 'Failed to reset data: $e');
    }

    setState(() => _isRecovering = false);
  }

  /// Clear any legacy password files that might exist
  Future<void> _clearLegacyFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final legacyFiles = [
        'app_password.hash',
        'recovery_passkey.key',
        'app_password.txt', // Any other old formats
        'vault_pin.txt',
      ];

      for (final fileName in legacyFiles) {
        final file = File('${directory.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore errors during legacy cleanup
    }
  }
}

class _NewPasswordDialog extends StatefulWidget {
  final String passkey;

  _NewPasswordDialog({required this.passkey});

  @override
  _NewPasswordDialogState createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isResetting = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Text(
        "Set New Password",
        style: TextStyle(color: theme.textTheme.titleLarge?.color),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newPasswordController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'New password',
              hintStyle: TextStyle(color: theme.hintColor),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: TextStyle(color: theme.hintColor),
              border: OutlineInputBorder(),
              errorText: _error.isNotEmpty ? _error : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isResetting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Reset Password'),
        ),
      ],
    );
  }

  void _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isResetting = true;
      _error = '';
    });

    try {
      final success = await PasswordService.resetPasswordWithPasskey(
        widget.passkey,
        newPassword,
      );

      if (success) {
        Navigator.pop(context, newPassword);
      } else {
        setState(() => _error = 'Invalid passkey or reset failed');
      }
    } catch (e) {
      setState(() => _error = 'Failed to reset password: $e');
    }

    setState(() => _isResetting = false);
  }
}
