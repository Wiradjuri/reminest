// File: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/journal_screen.dart';
import 'widgets/top_nav_bar.dart';
import 'screens/vault_screen.dart';
import 'services/key_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() {
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Reminest',
        theme: ThemeData.light().copyWith(
          primaryColor: Color(0xFF9B59B6),
          scaffoldBackgroundColor: Color(0xFFFAFAFA), // VS Code light background
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF9B59B6),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black12,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9B59B6),
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
            bodyMedium: TextStyle(color: Color(0xFF1E1E1E)),
            titleLarge: TextStyle(color: Color(0xFF1E1E1E)),
            titleMedium: TextStyle(color: Color(0xFF1E1E1E)),
          ),
          iconTheme: IconThemeData(color: Color(0xFF424242)),
          dividerTheme: DividerThemeData(color: Color(0xFFE0E0E0)),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Color(0xFF9B59B6);
              }
              return Colors.transparent;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Color(0xFF9B59B6);
              }
              return Color(0xFF424242);
            }),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF9B59B6),
          scaffoldBackgroundColor: Color(0xFF1E1E1E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF9B59B6),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Color(0xFF2D2D30),
            elevation: 1,
            shadowColor: Colors.black26,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9B59B6),
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white70),
          dividerTheme: DividerThemeData(color: Colors.white24),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Color(0xFF9B59B6);
              }
              return Colors.transparent;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Color(0xFF9B59B6);
              }
              return Colors.white70;
            }),
          ),
        ),
        themeMode: mode,
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    ),
  );
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    // Check if a password exists to determine if setup is needed
    final hasPassword = await KeyService.hasPassword();
    setState(() {
      _isAuthenticated = false; // Always start unauthenticated (user must login)
      _isLoading = false;
    });
    
    // If no password exists, we know the user needs to do setup
    // If password exists, user needs to login
    print("[AuthenticationWrapper] Password exists: $hasPassword");
  }

  void _onLoginSuccess() {
    print("[AuthenticationWrapper] _onLoginSuccess called");
    setState(() {
      _isAuthenticated = true;
    });
    print("[AuthenticationWrapper] Authentication state set to true");
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show different interfaces based on authentication status
    if (!_isAuthenticated) {
      // Before authentication: Show only Home page (no tabs, no other screens)
      return Scaffold(
        body: HomeScreen(onLoginSuccess: _onLoginSuccess),
      );
    } else {
      // After authentication: Show full app interface starting with Journal
      return MainScaffold(
        isAuthenticated: _isAuthenticated,
        onLoginSuccess: _onLoginSuccess,
        onLogout: _onLogout,
      );
    }
  }
}

class MainScaffold extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onLogout;
  
  MainScaffold({
    required this.isAuthenticated,
    this.onLoginSuccess,
    this.onLogout,
  });

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // Start with first tab (Home when not authenticated, Journal when authenticated)

  @override
  void initState() {
    super.initState();
    // Start with Journal tab (index 3) when authenticated
    _selectedIndex = 3; // Journal page after authentication
  }

  List<Widget> get _screens {
    // MainScaffold only shows when authenticated, so always show authenticated screens
    return [
      HomeScreen(onLoginSuccess: widget.onLoginSuccess),
      AboutUsScreen(),
      SettingsScreen(themeNotifier: themeNotifier, onReset: widget.onLogout),
      JournalScreen(),
    ];
  }

  List<String> get _navTitles {
    // MainScaffold only shows when authenticated, so always show authenticated tabs
    return ['Home', 'About Us', 'Settings', 'Journal'];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout? You'll need to enter your password again to access your journal."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onLogout != null) {
                  widget.onLogout!();
                }
                // Reset to Home tab when logging out (index 0 in unauthenticated state)
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _openVault() async {
    final hasPin = await KeyService.hasVaultPin();
    if (!hasPin) {
      // First time accessing vault - prompt for PIN setup
      _showVaultPinSetupDialog();
    } else {
      // PIN already exists - prompt for verification
      _showVaultPinDialog();
    }
  }

  void _showVaultPinSetupDialog() {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    String pinError = '';

    void setupVaultPin(String pin, String confirmPin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        return;
      }

      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        setDialogState(() => pinError = "PIN must contain only numbers");
        return;
      }

      if (pin != confirmPin) {
        setDialogState(() => pinError = "PINs do not match");
        return;
      }

      try {
        await KeyService.saveVaultPin(pin);
        Navigator.pop(context); // Close setup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vault PIN set up successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // Now open the vault
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VaultScreen()),
        );
      } catch (e) {
        setDialogState(() => pinError = "Error setting up PIN: $e");
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Set Up Vault PIN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create a 4-6 digit PIN to secure your vault entries.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Enter PIN (4-6 digits)",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm PIN",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) => setupVaultPin(pinController.text, confirmPinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(pinError, style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => setupVaultPin(pinController.text, confirmPinController.text, setDialogState),
              child: Text("Set PIN"),
            ),
          ],
        ),
      ),
    );
  }

  void _showVaultPinDialog() {
    final pinController = TextEditingController();
    String pinError = '';

    void verifyVaultPin(String pin, StateSetter setDialogState) async {
      if (pin.length < 4 || pin.length > 6) {
        setDialogState(() => pinError = "PIN must be 4-6 digits");
        return;
      }

      final isValid = await KeyService.verifyVaultPin(pin);
      if (isValid) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VaultScreen()),
        );
      } else {
        setDialogState(() => pinError = "Incorrect PIN. Try again.");
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Enter Vault PIN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Enter PIN (4-6 digits)",
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) => verifyVaultPin(pinController.text, setDialogState),
              ),
              if (pinError.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(pinError, style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => verifyVaultPin(pinController.text, setDialogState),
              child: Text("Open Vault"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        elevation: 0,
        title: Row(
          children: [
            ...List.generate(_navTitles.length, (index) {
              return TextButton(
                onPressed: () => _onTabSelected(index),
                style: TextButton.styleFrom(
                  foregroundColor: _selectedIndex == index
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                  textStyle: TextStyle(
                    fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
                child: Text(_navTitles[index]),
              );
            }),
          ],
        ),
        actions: [
          // Always show vault and logout buttons since MainScaffold only appears when authenticated
          IconButton(
            icon: Icon(Icons.lock, color: theme.primaryColor),
            tooltip: "Access Vault",
            onPressed: _openVault,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: _showLogoutConfirmation,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _screens[_selectedIndex],
    );
  }
}
