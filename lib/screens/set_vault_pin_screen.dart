import 'package:flutter/material.dart';
import '../services/key_service.dart';
import 'vault_screen.dart';

class SetVaultPinScreen extends StatefulWidget {
  @override
  State<SetVaultPinScreen> createState() => _SetVaultPinScreenState();
}

class _SetVaultPinScreenState extends State<SetVaultPinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  void _setPin() async {
    if (_pinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match.')),
      );
      return;
    }
    if (_pinController.text.length != 4 ||
        !_pinController.text.contains(RegExp(r'^\d{4}$'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must be exactly 4 digits.')),
      );
      return;
    }

    await KeyService.saveVaultPin(_pinController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VaultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA), // Lavender background
      appBar: AppBar(
        title: Text('Set Vault PIN'),
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
              onSubmitted: (_) => _setPin(), // Enable Enter key submission
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                hintText: 'Re-enter your PIN',
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
              onSubmitted: (_) => _setPin(), // Enable Enter key submission
            ),
            SizedBox(height: 24),
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
                onPressed: _setPin,
                child: Text('Set PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
