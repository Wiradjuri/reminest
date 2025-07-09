import 'package:flutter/material.dart';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import 'set_password_screen.dart';

class EnterPasswordScreen extends StatefulWidget {
  @override
  _EnterPasswordScreenState createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends State<EnterPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _verifyPassword() async {
    final password = _passwordController.text.trim();

    // Master PIN reset
    if (password == "SuperSecretAdminPin") {
      await KeyService.clearPassword();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vault reset. Restart to set a new password.")),
      );
      return;
    }

    bool isCorrect = await KeyService.verifyPassword(password);
    if (isCorrect) {
      final keyBytes = KeyService.generateKeyFromPassword(password);
      EncryptionService.initializeKey(keyBytes);

      if (_rememberMe) {
        await KeyService.saveRememberedKey(keyBytes);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Incorrect password. Please try again.")),
      );
    }
  }

  void _forgotPassword() async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reset Vault?"),
        content: Text(
          "Resetting will permanently erase all data in your vault. Proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Reset"),
          ),
        ],
      ),
    );

    if (confirm) {
      await KeyService.clearPassword();
      await DatabaseService.clearDatabase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SetPasswordScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unlock Vault")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Enter Password"),
              obscureText: true,
            ),
            CheckboxListTile(
              title: Text("Remember Me"),
              value: _rememberMe,
              onChanged: (val) {
                setState(() {
                  _rememberMe = val ?? false;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPassword,
              child: Text("Unlock"),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
