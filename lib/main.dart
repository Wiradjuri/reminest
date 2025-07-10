import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/set_password_screen.dart';
import 'screens/enter_password_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/add_entry_screen.dart';
import 'screens/settings_screen.dart'; // future screen
import 'services/key_service.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initDB();

  bool hasPassword = await KeyService.hasPassword();
  bool hasSetPassword = await KeyService.hasSetPassword();
  List<int>? rememberedKey = await KeyService.getRememberedKey();

  Widget homeWidget;

  if (rememberedKey != null) {
    EncryptionService.initializeKey(rememberedKey);
    homeWidget = HomeScreen();
  } else if (hasPassword && hasSetPassword) {
    homeWidget = EnterPasswordScreen();
  } else {
    homeWidget = SetPasswordScreen();
  }

  ThemeMode themeMode = await loadThemeMode();

  runApp(ReminesetApp(home: homeWidget, themeMode: themeMode));
}

Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('themeMode') ?? 'system';
  switch (theme) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class ReminesetApp extends StatelessWidget {
  final Widget home;
  final ThemeMode themeMode;
  const ReminesetApp({required this.home, required this.themeMode, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminest',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        primaryColor: Color(0xFF5B2C6F),
        scaffoldBackgroundColor: Color(0xFFE6E6FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5B2C6F),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5B2C6F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),
      home: home,
      routes: {
        '/home': (context) => HomeScreen(),
        '/vault': (context) => VaultScreen(),
        '/add': (context) => AddEntryScreen(),
        '/settings': (context) => SettingsScreen(), // Future settings screen
      },
    );
  }
}
