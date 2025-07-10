import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _rememberPasswords = false;
  bool _exporting = false;
  String? _exportStatus;
  String? _updateStatus;

  void _changeTheme(ThemeMode? value) {
    if (value == null) return;
    setState(() {
      _themeMode = value;
      // TODO: Save theme to preferences.
    });
    // You’ll need to implement a global theme change (consult if needed!)
  }

  void _toggleRememberPasswords(bool? value) {
    setState(() {
      _rememberPasswords = value ?? false;
      // TODO: Save setting securely.
    });
  }

  Future<void> _exportEntries() async {
    setState(() {
      _exporting = true;
      _exportStatus = null;
    });
    // TODO: Replace with your database export logic!
    await Future.delayed(Duration(seconds: 2)); // Simulate export
    setState(() {
      _exporting = false;
      _exportStatus = "Backup exported successfully! (Simulated)";
    });
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = null;
    });
    // TODO: Implement real update checker
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _updateStatus = "You’re running the latest version. (Simulated)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818),
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Theme Section
            Text("Theme", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: Color(0xFF9B59B6),
                ),
                Text("System", style: TextStyle(color: Colors.white)),
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: Color(0xFF9B59B6),
                ),
                Text("Dark", style: TextStyle(color: Colors.white)),
                Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: Color(0xFF9B59B6),
                ),
                Text("Light", style: TextStyle(color: Colors.white)),
              ],
            ),
            Divider(height: 32, color: Colors.white24),

            // Remember Passwords Section
            Row(
              children: [
                Checkbox(
                  value: _rememberPasswords,
                  activeColor: Color(0xFF9B59B6),
                  onChanged: _toggleRememberPasswords,
                ),
                Expanded(
                  child: Text(
                    "Remember passwords on this device",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "Warning: Saving passwords decreases your privacy & encryption security. Only enable on trusted devices.",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
              ),
            ),
            Divider(height: 32, color: Colors.white24),

            // Export Entries Button
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Export All Journal Entries", style: TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: _exporting ? null : _exportEntries,
                child: _exporting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text("Export"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: _exportStatus != null ? Text(_exportStatus!, style: TextStyle(color: Colors.greenAccent)) : null,
            ),
            Divider(height: 32, color: Colors.white24),

            // Update Checker Button
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Check for App Updates", style: TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: _checkForUpdates,
                child: Text("Check"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: _updateStatus != null ? Text(_updateStatus!, style: TextStyle(color: Colors.lightBlueAccent)) : null,
            ),
          ],
        ),
      ),
    );
  }
}
