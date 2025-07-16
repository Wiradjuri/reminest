import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import '../services/password_service.dart';

/// A screen that allows the user to set a new application password for the journal.
/// This widget guides the user through password creation, confirmation, and displays a recovery passkey for future password recovery.
class SetPasswordScreen extends StatefulWidget {
  final VoidCallback onPasswordSet; // Now REQUIRED

  /// Creates a SetPasswordScreen.
  /// 
  /// Args:
  ///   onPasswordSet: Callback invoked when the password has been successfully set.
  const SetPasswordScreen({super.key, required this.onPasswordSet});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  /// State for SetPasswordScreen, managing password input, validation, and passkey dialog.
  /// Handles user interactions for password creation and recovery passkey display.
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

    /// Attempts to set the user's password and display the recovery passkey dialog.
  ///
  /// Validates password and confirmation, enforces minimum length, and saves the password securely.
  ///
  /// Raises:
  ///   Shows a SnackBar if passwords do not match, are too short, or if an error occurs during saving.
  void _setPassword() async {
    if (_isLoading) return;

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final passkey = await PasswordService.setPassword(
        _passwordController.text,
      );
      await KeyService.savePassword(_passwordController.text);
      await KeyService.setPasswordSetFlag();
      final keyBytes = KeyService.generateKeyFromPassword(
        _passwordController.text,
      );
      EncryptionService.initializeKey(keyBytes);

      if (mounted) {
        _showPasskeyDialog(passkey);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set password: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Displays a dialog showing the user's recovery passkey after password setup.
  ///
  /// The dialog allows the user to copy the passkey and proceed to the home screen after confirming they have saved it.
  ///
  /// Args:
  ///   passkey: The generated recovery passkey to display to the user.
  void _showPasskeyDialog(String passkey) {
    final theme = Theme.of(context);

    showDialog(
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
              child: const Column(
                children: [
                  Text(
                    'IMPORTANT: Save this passkey!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This passkey can be used to recover your APPLICATION PASSWORD if you forget it. Note: This does NOT recover your vault PIN - the vault cannot be recovered if the PIN is lost.',
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
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Passkey:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    passkey,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: passkey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passkey copied to clipboard!')),
                      );
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
            onPressed: () {
              widget.onPasswordSet();
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Setup Your Password'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.1),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Secure Your Journal',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a strong password to protect your private thoughts and experiences.',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Password input section
                    Text(
                      'Create Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a strong password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                    const SizedBox(height: 16),

                    // Confirm password field
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      enabled: !_isLoading,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onSubmitted: (_) => _setPassword(),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
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

                    // Password strength indicator
                    const SizedBox(height: 16),
                    _buildPasswordStrengthIndicator(theme),

                    // Password requirements
                    const SizedBox(height: 20),
                    _buildPasswordRequirements(theme),

                    // Match indicator
                    if (_confirmController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _passwordController.text == _confirmController.text
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _passwordController.text == _confirmController.text
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _passwordController.text == _confirmController.text
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _passwordController.text == _confirmController.text
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _passwordController.text == _confirmController.text
                                  ? 'Passwords match!'
                                  : 'Passwords do not match',
                              style: TextStyle(
                                color: _passwordController.text == _confirmController.text
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Create password button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _setPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: theme.disabledColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
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
                          Text('Creating...'),
                        ],
                      )
                    : const Text(
                        'Create Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(ThemeData theme) {
    final password = _passwordController.text;
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    const colors = [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green];
    const labels = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Strength',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength / 5,
          backgroundColor: theme.dividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(colors[strength.clamp(0, 4)]),
        ),
        const SizedBox(height: 4),
        Text(
          labels[strength.clamp(0, 4)],
          style: TextStyle(
            fontSize: 12,
            color: colors[strength.clamp(0, 4)],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(ThemeData theme) {
    final password = _passwordController.text;
    
    final requirements = [
      {'text': 'At least 8 characters', 'met': password.length >= 8},
      {'text': 'Contains uppercase letter', 'met': password.contains(RegExp(r'[A-Z]'))},
      {'text': 'Contains lowercase letter', 'met': password.contains(RegExp(r'[a-z]'))},
      {'text': 'Contains number', 'met': password.contains(RegExp(r'[0-9]'))},
      {'text': 'Contains special character', 'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  req['met'] as bool ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: req['met'] as bool ? Colors.green : theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  req['text'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: req['met'] as bool 
                        ? Colors.green 
                        : theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  }