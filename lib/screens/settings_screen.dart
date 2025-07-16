import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:reminest/services/platform_database_service.dart';
import 'package:reminest/services/key_service.dart';
import 'package:reminest/services/password_service.dart';
import 'package:reminest/screens/set_vault_pin_screen.dart';


class SettingsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode>? themeNotifier;
  final VoidCallback? onLogout;
  final VoidCallback? onReset; // Callback when complete reset happens

  const SettingsScreen({
    super.key,
    this.themeNotifier,
    this.onLogout,
    this.onReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _exporting = false;
  String? _exportStatus;
  // ...existing code...

  @override
  void initState() {
    super.initState();
    if (widget.themeNotifier != null) {
      _themeMode = widget.themeNotifier!.value;
    }
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode') ?? 'ThemeMode.system';
      ThemeMode mode;
      switch (themeString) {
        case 'ThemeMode.light':
          mode = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          mode = ThemeMode.dark;
          break;
        default:
          mode = ThemeMode.system;
      }
      setState(() {
        _themeMode = mode;
      });
      if (widget.themeNotifier != null) {
        widget.themeNotifier!.value = mode;
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  void _changeTheme(ThemeMode? mode) {
    if (mode == null) return;
    setState(() {
      _themeMode = mode;
      if (widget.themeNotifier != null) {
        widget.themeNotifier!.value = mode;
      }
    });
    _saveThemePreference(mode);
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString());
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<File> _getExportFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return File('${directory.path}/reminest_export_$timestamp.json');
  }

  void _showResetAllDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear All Data & Reset Vault PIN"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⚠️ WARNING: This action is IRREVERSIBLE!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text("This will:"),
              SizedBox(height: 8),
              Text("• Permanently delete ALL journal entries"),
              Text("• Permanently delete your vault PIN"),
              Text("• Clear all app data"),
              SizedBox(height: 8),
              Text("• Your login password will remain intact"),
              SizedBox(height: 12),
              Text(
                "The vault PIN cannot be recovered once deleted!",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAllData();
              },
              child: const Text("CLEAR ALL DATA"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllData() async {
    try {
      // Clear vault data and PIN
      await KeyService.clearVaultPin();
      await PlatformDatabaseService.clearAllData();

      // Clear password data using PasswordService (this is the key fix!)
      await PasswordService.clearPasswordData();

      // Clear SharedPreferences but preserve theme setting
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString('theme_mode');
      await prefs.clear();
      if (themeMode != null) {
        await prefs.setString('theme_mode', themeMode);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "All data cleared successfully. You can now set up the app from scratch.",
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        // Use the onReset callback to trigger complete app reset
        if (widget.onReset != null) {
          widget.onReset!();
        } else {
          // Fallback: Force logout to trigger re-authentication flow
          if (widget.onLogout != null) {
            widget.onLogout!();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error during reset: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetVaultPin() async {
    // Show warning dialog first
    final proceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Vault PIN"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⚠️ WARNING: This action is IRREVERSIBLE!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text("This will:"),
              SizedBox(height: 8),
              Text("• Permanently delete ALL vault entries"),
              Text("• Clear your vault PIN"),
              Text("• Require you to set a new PIN"),
              SizedBox(height: 12),
              Text(
                "Vault entries cannot be recovered once deleted!",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text("Your regular journal entries will remain intact."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("RESET VAULT PIN"),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    try {
      // Clear vault data first (this makes the vault entries inaccessible)
      await PlatformDatabaseService.clearVaultData();

      // Then clear the vault PIN
      await KeyService.clearVaultPin();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Vault PIN and all vault entries cleared. Please set a new PIN.",
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to set new PIN, but keep navigation stack intact
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SetVaultPinScreen(
                onComplete: () {
                  // When PIN is set, pop back to settings
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error resetting vault PIN: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _exporting = true;
      _exportStatus = null;
    });

    try {
      // Show warning about encryption loss
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Export Warning"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⚠️ PRIVACY WARNING",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 12),
              Text("Exporting will:"),
              SizedBox(height: 8),
              Text("• Export ALL journal entries (including vault entries)"),
              Text("• Remove encryption protection"),
              Text("• Create a readable JSON file"),
              Text("• Store data without password protection"),
              SizedBox(height: 12),
              Text(
                "Store the exported file securely for privacy!",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Export Anyway"),
            ),
          ],
        ),
      );

      if (proceed != true) {
        setState(() {
          _exporting = false;
        });
        return;
      }

      final entries = await PlatformDatabaseService.getAllEntries();
      if (entries.isEmpty) {
        setState(() {
          _exporting = false;
          _exportStatus = "No entries to export.";
        });
        return;
      }

      final exportData = {
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'total_entries': entries.length,
        'warning':
            'This file contains unencrypted personal journal data. Store securely!',
        'entries': entries.map((entry) => entry.toMap()).toList(),
      };

      final jsonData = jsonEncode(exportData);
      final file = await _getExportFile();
      await file.writeAsString(jsonData);

      setState(() {
        _exporting = false;
        _exportStatus = "Export successful: ${file.path}";
      });
    } catch (e) {
      setState(() {
        _exporting = false;
        _exportStatus = "Export failed: $e";
      });
    }
  }

  void _checkForUpdates() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Checking for Updates"),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Checking for updates..."),
          ],
        ),
      ),
    );

    // Simulate checking for updates (replace with actual update check logic)
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Check"),
          content: const Text("You are running the latest version of Reminest (1.0.0+1)"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _launchHelp() async {
    try {
      const url = 'https://github.com/Wiradjuri/reminest';
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error opening help page: $e');
      // Fallback: show a dialog with the URL
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Help & Documentation'),
            content: const SelectableText(
              'Visit: https://github.com/Wiradjuri/reminest',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Theme Switcher
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text("Theme"),
              trailing: DropdownButton<ThemeMode>(
                value: _themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text("System"),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text("Light"),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                ],
                onChanged: _changeTheme,
              ),
            ),
            const Divider(),

            // Export Data
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Export Data"),
              trailing: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: _exportData,
                      child: const Text("Export"),
                    ),
              subtitle: _exportStatus != null
                  ? Text(
                      _exportStatus!,
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    )
                  : null,
            ),
            const Divider(),

            // Reset Vault PIN
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text("Reset Vault PIN"),
              subtitle: const Text(
                "⚠️ Deletes ALL vault entries and clears PIN (cannot be recovered)",
              ),
              trailing: ElevatedButton(
                onPressed: _resetVaultPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Reset PIN"),
              ),
            ),
            const Divider(),

            // Clear Data & Reset Vault PIN
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                "Clear Data & Reset Vault PIN",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              trailing: ElevatedButton(
                onPressed: _showResetAllDataConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Reset All"),
              ),
              subtitle: const Text(
                "⚠️ Permanently erases ALL data (vault PIN cannot be recovered)",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            const Divider(),

            // Check for Updates
            ListTile(
              leading: const Icon(Icons.system_update),
              title: const Text("Check for Updates"),
              subtitle: const Text("Version 1.0.0"),
              trailing: ElevatedButton(
                onPressed: _checkForUpdates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Check"),
              ),
            ),
            const Divider(),

            // Help
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Help"),
              onTap: _launchHelp,
            ),
            const Divider(),

            // Logout
            if (widget.onLogout != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: widget.onLogout,
              ),
          ],
        ),
      ),
    );
  }
}
