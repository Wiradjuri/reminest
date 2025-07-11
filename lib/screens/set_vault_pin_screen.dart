import 'package:flutter/material.dart';
import '../services/key_service.dart';

class SetVaultPinScreen extends StatefulWidget {
  @override
  State<SetVaultPinScreen> createState() => _SetVaultPinScreenState();
}

class _SetVaultPinScreenState extends State<SetVaultPinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setPin() async {
    if (_pinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match.')),
      );
      return;
    }
    if (_pinController.text.length < 4 || _pinController.text.length > 6 ||
        !RegExp(r'^\d+$').hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must be 4-6 digits.')),
      );
      return;
    }

    await KeyService.saveVaultPin(_pinController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vault PIN set successfully! Setup complete.'),
          backgroundColor: Colors.green,
        ),
      );
      // Return true to indicate successful setup
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Set Vault PIN'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button - force completion
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning about vault PIN importance
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'IMPORTANT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your vault PIN is NOT recoverable. If you forget it, all vault entries will be permanently lost. Make sure to remember this PIN.',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            Text(
              'Set Vault PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a secure PIN to protect your most sensitive entries in the vault.',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),
            
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Enter PIN (4-6 digits)',
                hintText: 'Enter your vault PIN',
                hintStyle: TextStyle(color: theme.hintColor),
                border: OutlineInputBorder(),
                counterText: "",
                prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                hintText: 'Confirm your vault PIN',
                hintStyle: TextStyle(color: theme.hintColor),
                border: OutlineInputBorder(),
                counterText: "",
                prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
              ),
              onSubmitted: (_) => _setPin(),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _setPin,
                child: Text(
                  'Complete Setup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This step is mandatory to complete your account setup.',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
