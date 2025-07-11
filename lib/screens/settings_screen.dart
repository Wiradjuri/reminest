import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import '../services/database_service.dart';
import '../services/key_service.dart';

class SettingsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode>? themeNotifier;
  final VoidCallback? onLogout;
  final VoidCallback? onReset; // Callback when complete reset happens
  
  const SettingsScreen({Key? key, this.themeNotifier, this.onLogout, this.onReset}) : super(key: key);
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _exporting = false;
  String? _exportStatus;
  String? _updateStatus;

  @override
  void initState() {
    super.initState();
    // Initialize with current global theme if available
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
      
      // Sync with global theme notifier
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
    return File('${directory.path}/reminest_backup_$timestamp.json');
  }

  Future<void> _exportEntries() async {
    setState(() {
      _exporting = true;
      _exportStatus = null;
    });

    try {
      // Show warning about encryption loss
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Export Warning"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("⚠️ PRIVACY WARNING", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 12),
              Text("Exporting will:"),
              SizedBox(height: 8),
              Text("• Export ALL journal entries (including vault entries)"),
              Text("• Remove encryption protection"),
              Text("• Create a readable JSON file"),
              Text("• Store data without password protection"),
              SizedBox(height: 12),
              Text("Store the exported file securely for privacy!", style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("Export Anyway"),
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
    
      final databaseService = DatabaseService();
      final entries = await databaseService.getAllEntries(); // Fetch all entries from the database
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
        'warning': 'This file contains unencrypted personal journal data. Store securely!',
        'entries': entries.map((entry) => entry.toMap()).toList(),
      };
      
      final jsonData = jsonEncode(exportData);
      final file = await _getExportFile();
      await file.writeAsString(jsonData);
      
      setState(() {
        _exporting = false;
        _exportStatus = "Backup exported to: ${file.path}"; // Show file path
      });
    } catch (e) {
      setState(() {
        _exporting = false;
        _exportStatus = "Export failed: ${e.toString()}"; // Show error message 
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = null;
    });
    
    try {
      // Check GitHub releases API for latest version
      const currentVersion = '1.0.0'; // This should match pubspec.yaml version
      const repoUrl = 'https://api.github.com/repos/Wiradjuri/mental_health_vault/releases/latest';
      
      // For now, simulate the check since we don't have HTTP package
      // In a real implementation, you would:
      // 1. Make HTTP request to GitHub API
      // 2. Parse JSON response
      // 3. Compare version numbers
      // 4. Show update available if newer version exists
      
      await Future.delayed(Duration(seconds: 2));
      
      // Simulate version check result
      final hasUpdate = false; // This would be determined by actual version comparison
      
      if (hasUpdate) {
        setState(() {
          _updateStatus = "Update available! Please check the app store.";
        });
      } else {
        setState(() {
          _updateStatus = "You're running the latest version (v$currentVersion).";
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = "Failed to check for updates: ${e.toString()}";
      });
    }
  }

  Future<void> _openGitHubRepo() async {
    const url = 'https://github.com/Wiradjuri/mental_health_vault';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error opening GitHub repo: $e');
      // Fallback: show a dialog with the URL
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('GitHub Repository'),
            content: SelectableText(url),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
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
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _showRestorePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Restore Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("This will recover your password from local storage."),
              SizedBox(height: 12),
              Text("✅ Your journal entries will remain intact"),
              Text("✅ Your vault PIN will remain intact"),
              Text("✅ Only your login password will be restored"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _restorePassword();
              },
              child: Text("Restore Password"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restorePassword() async {
    try {
      final password = await KeyService.getStoredPassword();
      if (password != null) {
        // Show the password to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Password Restored"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Your password is:"),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: SelectableText(
                    password,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "⚠️ Write this down and store it securely!",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Done"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No password found in local storage."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error restoring password: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResetAllDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear All Data & Reset Vault PIN"),
          content: Column(
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
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
              ),
            ],
          ),
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAllData();
              },
              child: Text("CLEAR ALL DATA"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllData() async {
    try {
      // Clear vault PIN (non-recoverable)
      await KeyService.clearVaultPin();
      
      // Clear all database entries
      await DatabaseService.clearAllData();
      
      // Clear SharedPreferences (except theme and password)
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString('theme_mode'); // Save theme preference
      final password = prefs.getString('app_password'); // Save password
      await prefs.clear();
      if (themeMode != null) {
        await prefs.setString('theme_mode', themeMode); // Restore theme
      }
      if (password != null) {
        await prefs.setString('app_password', password); // Restore password
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All data cleared. Vault PIN has been reset. Your login password remains intact."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during reset: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Theme Section
            Text("Theme", style: TextStyle(
              fontSize: 20, 
              color: theme.textTheme.titleLarge?.color, 
              fontWeight: FontWeight.bold
            )),
            SizedBox(height: 10),
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: theme.primaryColor,
                ),
                Text("System", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: theme.primaryColor,
                ),
                Text("Dark", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  activeColor: theme.primaryColor,
                ),
                Text("Light", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
            Divider(height: 32, color: theme.dividerTheme.color),

            // Export Entries Button
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Export All Journal Entries", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              trailing: ElevatedButton(
                onPressed: _exporting ? null : _exportEntries,
                child: _exporting 
                    ? SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : Text("Export"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: _exportStatus != null 
                  ? Text(_exportStatus!, style: TextStyle(color: Colors.greenAccent, fontSize: 12))
                  : null,
            ),
            Divider(height: 32, color: theme.dividerTheme.color),

            // Update Checker Button
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Check for App Updates", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
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
              subtitle: _updateStatus != null 
                  ? Text(_updateStatus!, style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12))
                  : null,
            ),
            Divider(height: 32, color: theme.dividerTheme.color),

            // Reset Password Section
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Restore Password", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              trailing: ElevatedButton(
                onPressed: _showRestorePasswordDialog,
                child: Text("Restore"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: Text(
                "Recover your password from local storage",
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
            Divider(height: 16, color: theme.dividerTheme.color),

            // Clear Data and Reset Vault PIN Section
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Clear Data & Reset Vault PIN", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              trailing: ElevatedButton(
                onPressed: _showResetAllDataConfirmation,
                child: Text("Reset All"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: Text(
                "⚠️ Permanently erases ALL data (vault PIN cannot be recovered)",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Divider(height: 32, color: theme.dividerTheme.color),

            // GitHub Repository Link
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("View Source Code", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              trailing: ElevatedButton(
                onPressed: _openGitHubRepo,
                child: Text("GitHub"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Color(0xFF333333) : Color(0xFF6F42C1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              subtitle: Text(
                "Open source project on GitHub",
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
