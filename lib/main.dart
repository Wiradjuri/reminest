// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:reminest/services/encryption_service.dart';
import 'package:reminest/services/key_service.dart';
import 'package:reminest/services/platform_database_service.dart';
import 'screens/set_password_screen.dart';
import 'screens/home_screen.dart';
import 'package:reminest/screens/journal_screen.dart';
import 'package:reminest/screens/settings_screen.dart';
import 'package:reminest/screens/about_us_screen.dart';
import 'package:reminest/screens/vault_screen.dart';
import 'package:reminest/screens/set_vault_pin_screen.dart';

void main() {
  runApp(ReminestApp());
}

class ReminestApp extends StatefulWidget {
  const ReminestApp({super.key});

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
      print("[Main] App initialized successfully");
    } catch (e) {
      print("[Main] Error initializing app: $e");
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
      _currentIndex = 1;
    });
  }

  void _handlePasswordSetupSuccess() {
    setState(() {
      _isAuthenticated = true;
      _currentIndex = 1;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _currentIndex = 0;
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

  void _openVault(BuildContext context) async {
    final hasPin = await KeyService.hasVaultPin();
    if (!mounted) return;

    if (!hasPin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetVaultPinScreen(
            onComplete: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _showVaultPinDialog(context);
                }
              });
            },
          ),
        ),
      );
      return;
    }
    _showVaultPinDialog(context);
  }

  void _showVaultPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    String pinError = '';

    void verifyVaultPin(String pin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        print("PIN entered: $pin");
        return;
      }

      final isValid = await KeyService.verifyVaultPin(pin);
      print("Vault PIN valid? $isValid");
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
                onSubmitted: (_) => verifyVaultPin(pinController.text, setDialogState),
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
              onPressed: () => verifyVaultPin(pinController.text, setDialogState),
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
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Reminest',
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
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => _isAuthenticated
                ? _buildMainApp()
                : SetPasswordScreen(
                    onPasswordSet: () {
                      setState(() {
                        _isAuthenticated = true;
                      });
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                  ),
            '/home': (context) => _buildMainApp(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
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
        title: const Text('Reminest'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (innerContext) => IconButton(
              tooltip: 'Open Vault',
              icon: const Icon(Icons.lock),
              onPressed: () => _openVault(innerContext),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
            label: 'About',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }
}