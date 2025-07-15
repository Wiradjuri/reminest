// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:reminest/services/encryption_service.dart';
import 'package:reminest/services/key_service.dart';
import 'package:reminest/services/platform_database_service.dart';
import 'package:reminest/screens/home_screen.dart';
import 'package:reminest/screens/journal_screen.dart';
import 'package:reminest/screens/settings_screen.dart';
import 'package:reminest/screens/about_us_screen.dart';
import 'package:reminest/screens/vault_screen.dart';
import 'package:reminest/screens/set_vault_pin_screen.dart';

void main() {
  runApp(const ReminestApp());
}

class ReminestApp extends StatefulWidget {
  const ReminestApp({Key? key}) : super(key: key);

  @override
  State<ReminestApp> createState() => _ReminestAppState();
}

class _ReminestAppState extends State<ReminestApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.system);
  bool _isAuthenticated = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await PlatformDatabaseService.initDB();
    } catch (e) {
      // Handle initialization errors (log or show a message if needed)
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
      _currentIndex = 1; // Journal
    });
  }

  void _handlePasswordSetupSuccess() {
    setState(() {
      _isAuthenticated = true;
      _currentIndex = 1; // Journal
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _currentIndex = 0; // Home
    });
    EncryptionService.reset();
  }

  void _handleCompleteReset() {
    setState(() {
      _isAuthenticated = false;
      _currentIndex = 0;
    });
    EncryptionService.reset();
  }

  void _navigateToJournal() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _openVault() async {
    final hasPin = await KeyService.hasVaultPin();
    if (!mounted) return;

    if (!hasPin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetVaultPinScreen(
            onComplete: () {
              Navigator.pop(context); // Close SetVaultPinScreen
              Future.microtask(() => _showVaultPinDialog());
            },
          ),
        ),
      );
      return;
    }
    _showVaultPinDialog();
  }

  void _showVaultPinDialog() {
    final pinController = TextEditingController();
    String pinError = '';

    void verifyVaultPin(String pin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        return;
      }

      final isValid = await KeyService.verifyVaultPin(pin);
      if (!mounted) return;
      if (isValid) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VaultScreen()),
        );
      } else {
        setDialogState(() => pinError = "Incorrect PIN. Try again.");
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Enter Vault PIN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "4-6 digit PIN",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) =>
                    verifyVaultPin(pinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  pinError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  verifyVaultPin(pinController.text, setDialogState),
              child: const Text("Open Vault"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Reminest',
          themeMode: themeMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: _isAuthenticated ? _buildMainApp() : _buildHomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    return HomeScreen(
      onLoginSuccess: _handleLoginSuccess,
      onPasswordSetupSuccess: _handlePasswordSetupSuccess,
      isAuthenticated: _isAuthenticated,
      onNavigateToJournal: _navigateToJournal,
    );
  }

  Widget _buildMainApp() {
    final screens = [
      HomeScreen(
        onLoginSuccess: _handleLoginSuccess,
        onPasswordSetupSuccess: _handlePasswordSetupSuccess,
        isAuthenticated: _isAuthenticated,
        onNavigateToJournal: _navigateToJournal,
      ),
      JournalScreen(),
      SettingsScreen(
        themeNotifier: _themeNotifier,
        onLogout: _handleLogout,
        onReset: _handleCompleteReset,
      ),
      const AboutUsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Home'
              : _currentIndex == 1
                  ? 'Journal'
                  : _currentIndex == 2
                      ? 'Settings'
                      : 'About Us',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.white),
            tooltip: "Open Vault",
            onPressed: _openVault,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: _openVault,
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: 'Open Vault',
              child: const Icon(Icons.security, color: Colors.white),
            ),
    );
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }
}
