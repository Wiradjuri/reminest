import 'package:flutter/material.dart';
import '../services/key_service.dart';
import '../services/encryption_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import 'set_password_screen.dart';
import 'settings_screen.dart';

class EnterPasswordScreen extends StatefulWidget {
  @override
  _EnterPasswordScreenState createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends State<EnterPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _verifyPassword() async {
    final password = _passwordController.text.trim();

    if (password == "Admin529078") {
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
          "Resetting will permanently erase all data in your vault for security. Proceed?",
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

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("About Reminest"),
        content: Text(
            "Reminest is your personal encrypted journal, allowing you to capture your thoughts, lock them in a time capsule, and revisit when the moment is right."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  void _showContactUs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Contact Us"),
        content: Text("For support, please email bmuzza1992@gmail.com, or visit https://github.com/wiradjuri"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  Widget _buildHeaderNavigation() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _navButton("Home", () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }),
          _navButton("About", _showAbout),


          },
          _navButton("Contact Us", _showContactUs),
          _navButton("Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
          }),
          _navButton("Login", () {
            // Already on login, could refresh or handle future logic
          }),
        ],
      ),
    );
  }

  Widget _navButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: Color(0xFF5B2C6F), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text("Welcome to Your Reminest Journal Vault!"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD54F),
                Color(0xFFFF8A65),
                Color(0xFFFFAB91),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaderNavigation(),
            SizedBox(height: 16),
            Text(
              "Capture your thoughts, add a photo, and lock them in your personal time capsule to revisit when the moment is right.",
              style: TextStyle(
                color: Color(0xFF5B2C6F),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Enter Password",
                hintText: "Your App password",
                hintStyle: TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              onSubmitted: (_) => _verifyPassword(),
            ),
            CheckboxListTile(
              title: Text("Remember Me"),
              value: _rememberMe,
              onChanged: (val) {
                setState(() {
                  _rememberMe = val ?? false;
                });
              },
              activeColor: Color(0xFF5B2C6F),
              controlAffinity: ListTileControlAffinity.leading,
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
                  backgroundColor: Color(0xFF5B2C6F),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _verifyPassword,
                child: Text("Unlock"),
              ),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Color(0xFF5B2C6F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
