import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/set_password_screen.dart';
import 'screens/enter_password_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/add_entry_screen.dart';
import 'services/key_service.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
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

  runApp(MentalHealthVaultApp(home: homeWidget));
}

class MentalHealthVaultApp extends StatelessWidget {
  final Widget home;
  const MentalHealthVaultApp({required this.home, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Journal Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF5B2C6F),
        scaffoldBackgroundColor: Color(0xFFF5F5FA),
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
      home: home,
      routes: {
        '/home': (context) => HomeScreen(),
        '/vault': (context) => VaultScreen(),
        '/add': (context) => AddEntryScreen(),
      },
    );
  }
}
