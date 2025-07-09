import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_entry_screen.dart';
import 'screens/vault_screen.dart';

void main() {
  runApp(MentalHealthVaultApp());
}

class MentalHealthVaultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Vault',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/add': (context) => AddEntryScreen(),
        '/vault': (context) => VaultScreen(),
      },
    );
  }
}
