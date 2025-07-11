import 'package:flutter/material.dart';
import '../services/key_service.dart';
import '../screens/journal_screen.dart';
import '../screens/vault_screen.dart';
import '../screens/set_password_screen.dart';

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
    final hasPassword = await KeyService.hasPassword();
    setState(() {
      _hasPassword = hasPassword;
    });
  }

  /// Handle begin setup
  void _beginSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SetPasswordScreen()),
    );
  }
  void _handleForgotPassword() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "To reset your password, you'll need to clear all app data. This will permanently delete all your journal entries and vault data.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              "Are you sure you want to continue?",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Clear all app data
              await KeyService.clearAllPasswordData();
              await KeyService.clearVaultPin();
              
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SetPasswordScreen()),
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("App data cleared. Please set up a new password."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Reset App Data"),
          ),
        ],
      ),
    );
  }

  /// Verify password using KeyService
  Future<bool> _checkPassword(String input) async {
    return await KeyService.verifyPassword(input);
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
      // Pop the LoginScreen so the AuthenticationWrapper can show the MainScaffold
      Navigator.pop(context);
    } else {
      print("[LoginScreen] WARNING: No onLoginSuccess callback provided");
    }
    // Note: No fallback navigation - always use the callback system
  }

  /// Handle vault access
  void _openVault() async {
    final hasPin = await KeyService.hasVaultPin();
    if (!hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please set up a vault PIN first in Settings."),
          backgroundColor: Colors.orange,
        ),
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
      if (pin.length != 4) {
        setDialogState(() => pinError = "PIN must be 4 digits");
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
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "4-digit PIN",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) => verifyVaultPin(pinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(pinError, style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => verifyVaultPin(pinController.text, setDialogState),
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
          )
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
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Icon
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.primaryColor,
                ),
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
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
                      )
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Verifying..."),
                            ],
                          )
                        : Text(
                            _hasPassword ? "Unlock Journal" : "Begin Setup",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
