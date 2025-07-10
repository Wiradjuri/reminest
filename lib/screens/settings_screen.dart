import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/key_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rememberPassword = false;
  String _theme = 'system';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberPassword = prefs.getBool('rememberPassword') ?? false;
      _theme = prefs.getString('themeMode') ?? 'system';
    });
  }

  Future<void> updateRememberPassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberPassword', value);
    setState(() => _rememberPassword = value);
    if (!value) {
      await KeyService.clearRememberedKey();
    }
  }

  Future<void> updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', theme);
    setState(() => _theme = theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text("Remember Password"),
            subtitle: Text("Store your password locally for convenience."),
            value: _rememberPassword,
            onChanged: updateRememberPassword,
          ),
          Divider(),
          Text("Theme", style: Theme.of(context).textTheme.subtitle1),
          RadioListTile(
            title: Text("Light"),
            value: 'light',
            groupValue: _theme,
            onChanged: (val) => updateTheme(val as String),
          ),
          RadioListTile(
            title: Text("Dark"),
            value: 'dark',
            groupValue: _theme,
            onChanged: (val) => updateTheme(val as String),
          ),
          RadioListTile(
            title: Text("System Default"),
            value: 'system',
            groupValue: _theme,
            onChanged: (val) => updateTheme(val as String),
          ),
        ],
      ),
    );
  }
}
