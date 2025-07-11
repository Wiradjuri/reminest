import 'package:flutter/material.dart';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import 'set_vault_pin_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI when text changes
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setPassword() async {
    if (_isLoading) return;
    
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await KeyService.savePassword(_passwordController.text);
      await KeyService.setPasswordSetFlag();

      final keyBytes = KeyService.generateKeyFromPassword(_passwordController.text);
      EncryptionService.initializeKey(keyBytes);

      if (mounted) {
        // Navigate to vault PIN setup (mandatory)
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SetVaultPinScreen()),
        );
        // If vault PIN setup was successful, return success to HomeScreen
        if (result == true) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set password: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canSubmit = _passwordController.text.isNotEmpty && 
                          _confirmController.text.isNotEmpty && 
                          !_isLoading;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Set Application Password'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            Text(
              'Welcome to Reminest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a secure password to protect your journal entries.',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 32),
            
            // Password field
            Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Enter a secure password (min. 6 characters)',
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
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Confirm password field
            Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              enabled: !_isLoading,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
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
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            
            // Password requirements
            if (_passwordController.text.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _passwordController.text.length >= 6 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _passwordController.text.length >= 6 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _passwordController.text.length >= 6 
                          ? Icons.check_circle 
                          : Icons.warning,
                      color: _passwordController.text.length >= 6 
                          ? Colors.green 
                          : Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _passwordController.text.length >= 6 
                          ? 'Password meets requirements'
                          : 'Password must be at least 6 characters',
                      style: TextStyle(
                        color: _passwordController.text.length >= 6 
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Password match indicator
            if (_confirmController.text.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _passwordController.text == _confirmController.text 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
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
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _passwordController.text == _confirmController.text 
                          ? 'Passwords match'
                          : 'Passwords do not match',
                      style: TextStyle(
                        color: _passwordController.text == _confirmController.text 
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 40),
            
            // Set password button
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
                onPressed: canSubmit ? _setPassword : null,
                child: _isLoading
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
                          Text('Setting up...'),
                        ],
                      )
                    : Text(
                        'Create Password & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Security note
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your password encrypts your journal entries. Keep it safe and remember it.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
