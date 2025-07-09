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
    if (_pinController.text.length != 4 || !_pinController.text.contains(RegExp(r'^\d{4}$'))) {
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
      appBar: AppBar(title: Text('Set Vault PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter 4-digit PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(labelText: 'Confirm PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setPin,
              child: Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
