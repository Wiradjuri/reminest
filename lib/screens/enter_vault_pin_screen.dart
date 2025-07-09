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
      appBar: AppBar(title: Text('Enter Vault PIN')),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              child: Text('Unlock Vault'),
            ),
            TextButton(
              onPressed: _forgotPin,
              child: Text('Forgot PIN?'),
            ),
          ],
        ),
      ),
    );
  }
}
