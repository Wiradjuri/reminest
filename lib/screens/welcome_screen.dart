import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'enter_password_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  Future<void> _proceedToApp(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EnterPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text("Welcome to Reminest"),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Text(
              "Welcome to Reminest\n\nYour Private Sanctuary for Reflection and Growth.\n",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B2C6F),
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                    "I created this app for the purpose of helping people with their mental health. i hope this can help you in some way."
                    "please support me by sharing this app with your friends and family and paying the $5 to unlock the full.
                                    "Reminest is your encrypted, personal journal designed to support your mental health and personal growth. "
                                    "Capture your thoughts, feelings, and reflections as they happen, add a photo if it helps, "
                                    "and lock your entries in your personal time capsule to revisit when you’re ready.\n\n"
                                    "Whether you are working through challenges, celebrating wins, or simply need a private space to reflect, "
                                    "Reminest offers a safe place to check in with yourself and grow on your terms.\n\n"
                                    "Your thoughts are encrypted, secure, and yours alone.\n\n"
                                    "Take a moment for yourself. Let Reminest support you in your mental health journey—one entry, one reflection, one step at a time.",
                                    style: TextStyle(fontSize: 16, color: Color(0xFF333333)),
                                    textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B2C6F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => _proceedToApp(context),
              child: Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}
