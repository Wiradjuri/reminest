import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Image.asset(
            'lib/assets/icons/Reminest.png',
            height: 100,
            width: 100,
          ),
          SizedBox(height: 20),
          Icon(Icons.lock, size: 80, color: Color(0xFF9B59B6)),
          SizedBox(height: 20),
          Text(
            "Welcome to Reminest",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 14),
          Text(
            "Your private, secure mental health journal.\nReflect, grow, and heal in your own safe space.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}
// This is the HomeScreen widget. It serves as the landing page for the Reminest app, providing a welcoming message and a brief description of the app's purpose.
