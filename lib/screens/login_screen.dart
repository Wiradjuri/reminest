import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import '../services/password_service.dart';
import 'vault_screen.dart';
import 'set_password_screen.dart';
import 'set_vault_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginScreen({super.key, this.onLoginSuccess});

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

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkPasswordStatus() async {
    final hasPassword = await PasswordService.isPasswordSet();
    if (mounted) {
      setState(() {
        _hasPassword = hasPassword;
      });
    }
  }

  void _beginSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SetPasswordScreen(
          onPasswordSet: () {
            if (widget.onLoginSuccess != null) {
              widget.onLoginSuccess!();
            }
          },
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => _PasswordRecoveryDialog(
        onSuccessfulRecovery: () {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          }
        },
      ),
    );
  }

  Future<bool> _checkPassword(String input) async {
    return await PasswordService.verifyPassword(input);
  }

  void _submit() async {
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
      if (correct) {
        // Initialize encryption service
        try {
          final encryptionKey = KeyService.generateKeyFromPassword(input);
          EncryptionService.initializeKey(encryptionKey);
        } catch (e) {
          if (mounted) {
            setState(() {
              _error = "Failed to initialize encryption. Please try again.";
              _isLoading = false;
            });
          }
          return;
        }

        // Navigate to main app
        if (mounted && widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() => _error = "Incorrect password. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Login failed. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openVault() async {
    final hasPin = await KeyService.hasVaultPin();
    if (!mounted) return;
    
    if (!hasPin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetVaultPinScreen()),
      );
      return;
    }
    _showVaultPinDialog();
  }

  void _showVaultPinDialog() {
    final pinController = TextEditingController();
    String pinError = '';

    void verifyVaultPin(String pin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        return;
      }

      final isValid = await KeyService.verifyVaultPin(pin);
      if (isValid && mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VaultScreen()),
        );
      } else {
        setDialogState(() => pinError = "Incorrect PIN. Try again.");
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Enter Vault PIN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "4-6 digit PIN",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) => verifyVaultPin(pinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  pinError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => verifyVaultPin(pinController.text, setDialogState),
              child: const Text("Open Vault"),
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
        title: const Text("Login to Reminest"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: "Access Vault",
            onPressed: _openVault,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_outline, size: 64, color: theme.primaryColor),
                const SizedBox(height: 16),

                // Title
                Text(
                  _hasPassword ? "Unlock Your Journal" : "Welcome to Reminest",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

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
                const SizedBox(height: 32),

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
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _isLoading ? null : _submit(),
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

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
                        ? const Row(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

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

  const _PasswordRecoveryDialog({required this.onSuccessfulRecovery});

  @override
  _PasswordRecoveryDialogState createState() => _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<_PasswordRecoveryDialog> {
  final _passkeyController = TextEditingController();
  bool _isRecovering = false;
  String _error = '';

  @override
  void dispose() {
    _passkeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      title: Text(
        "Password Recovery",
        style: TextStyle(color: theme.textTheme.titleLarge?.color),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your recovery passkey to reset your password:",
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passkeyController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              onSubmitted: (_) => _recoverWithPasskey(),
              decoration: InputDecoration(
                hintText: 'Enter 16-character passkey',
                hintStyle: TextStyle(color: theme.hintColor),
                border: const OutlineInputBorder(),
                errorText: _error.isNotEmpty ? _error : null,
              ),
              maxLength: 16,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showResetDataDialog(),
              child: const Text(
                "Don't have your passkey? Reset all data",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isRecovering ? null : _recoverWithPasskey,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isRecovering
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Recover'),
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

    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _NewPasswordDialog(passkey: passkey),
      );

      if (result != null && result.isNotEmpty && mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully! Logging you in...'),
            backgroundColor: Colors.green,
          ),
        );

        try {
          final encryptionKey = KeyService.generateKeyFromPassword(result);
          EncryptionService.initializeKey(encryptionKey);
          widget.onSuccessfulRecovery();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successful, but auto-login failed. Please login manually.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _error = 'Recovery failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isRecovering = false);
      }
    }
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => _ResetDataDialog(
        onSuccessfulReset: widget.onSuccessfulRecovery,
      ),
    );
  }
}

class _NewPasswordDialog extends StatefulWidget {
  final String passkey;

  const _NewPasswordDialog({required this.passkey});

  @override
  _NewPasswordDialogState createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isResetting = false;
  String _error = '';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
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
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: TextStyle(color: theme.hintColor),
              border: const OutlineInputBorder(),
              errorText: _error.isNotEmpty ? _error : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isResetting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Reset Password'),
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

      if (success && mounted) {
        Navigator.pop(context, newPassword);
      } else {
        setState(() => _error = 'Invalid passkey or reset failed');
      }
    } catch (e) {
      setState(() => _error = 'Failed to reset password: $e');
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }
}

class _ResetDataDialog extends StatefulWidget {
  final VoidCallback onSuccessfulReset;

  const _ResetDataDialog({required this.onSuccessfulReset});

  @override
  _ResetDataDialogState createState() => _ResetDataDialogState();
}

class _ResetDataDialogState extends State<_ResetDataDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isResetting = false;
  String _error = '';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      title: Text(
        "Reset All Data",
        style: TextStyle(color: theme.textTheme.titleLarge?.color),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Column(
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
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: TextStyle(color: theme.hintColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                hintStyle: TextStyle(color: theme.hintColor),
                border: const OutlineInputBorder(),
                errorText: _error.isNotEmpty ? _error : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetAllData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isResetting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Reset All Data'),
        ),
      ],
    );
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
      _isResetting = true;
      _error = '';
    });

    try {
      await PasswordService.clearPasswordData();
      await KeyService.clearAllPasswordData();
      await KeyService.clearVaultPin();

      final passkey = await PasswordService.setPassword(newPassword);
      await KeyService.savePassword(newPassword);
      await KeyService.setPasswordSetFlag();

      if (!mounted) return;

      // Close the reset dialog first
      Navigator.pop(context);

      // Close the password recovery dialog
      Navigator.pop(context);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
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
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 8),
                    const Text(
                      'This passkey can be used to recover your password if you forget it.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Passkey:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      passkey,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: passkey));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passkey copied to clipboard!'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Passkey'),
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
                if (!mounted) return;
                
                // Close the passkey dialog
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data reset successfully! Please login with your new password.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );

                // Navigate back to the root and reset authentication state
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
                
                // Trigger the authentication callback
                widget.onSuccessfulReset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('I have saved my passkey'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = 'Failed to reset data: $e');
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }
}