import 'package:flutter/material.dart';
import '../services/key_service.dart';
import 'vault_screen.dart';
import 'set_vault_pin_screen.dart';

class EnterVaultPinScreen extends StatefulWidget {
  @override
  State<EnterVaultPinScreen> createState() => _EnterVaultPinScreenState();
}

class _EnterVaultPinScreenState extends State<EnterVaultPinScreen> {
  final _pinController = TextEditingController();

  void _verifyPin() async {
    final pin = _pinController.text.trim();
    bool isCorrect = await KeyService.verifyVaultPin(pin);

    if (isCorrect) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VaultScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect PIN.')),
      );
    }
  }

  void _forgotPin() async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset PIN?'),
        content: Text('Resetting will require you to set a new PIN. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm) {
      await KeyService.clearVaultPin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SetVaultPinScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA), // Lavender background
      appBar: AppBar(
        title: Text('Enter Vault PIN'),
        backgroundColor: Color(0xFF5B2C6F), // Deep Purple
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'Enter 4-digit PIN',
                hintText: '****',
                hintStyle: TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _verifyPin(), // Enter key submits
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B2C6F), // Deep Purple
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _verifyPin,
                child: Text('Unlock Vault'),
              ),
            ),
            TextButton(
              onPressed: _forgotPin,
              child: Text(
                'Forgot PIN?',
                style: TextStyle(color: Color(0xFF5B2C6F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
