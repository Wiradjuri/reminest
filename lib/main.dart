import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_entry_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/set_password_screen.dart';
import 'screens/enter_password_screen.dart';
import 'services/key_service.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initDB();

  bool hasPassword = await KeyService.hasPassword();
  List<int>? rememberedKey = await KeyService.getRememberedKey();

  if (rememberedKey != null) {
    EncryptionService.initializeKey(rememberedKey);
    runApp(MentalHealthVaultApp(home: HomeScreen()));
  } else {
    runApp(MentalHealthVaultApp(
      home: hasPassword ? EnterPasswordScreen() : SetPasswordScreen(),
    ));
  }
}

class MentalHealthVaultApp extends StatelessWidget {
  final Widget home;

  MentalHealthVaultApp({required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Vault',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: home,
      routes: {
        '/add': (context) => AddEntryScreen(),
        '/vault': (context) => VaultScreen(),
      },
    );
  }
}
