import 'package:flutter/material.dart';
import '../services/password_service.dart';
import 'set_password_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onPasswordSetupSuccess; // Add new callback
  final bool isAuthenticated;
  final VoidCallback? onNavigateToJournal;

  const HomeScreen({super.key, 
    this.onLoginSuccess,
    this.onPasswordSetupSuccess, // Add to constructor
    this.isAuthenticated = false,
    this.onNavigateToJournal,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  Future<void> _checkPasswordStatus() async {
    final hasPassword = await PasswordService.isPasswordSet();
    setState(() {
      _hasPassword = hasPassword;
    });
  }

  void _beginSetup() async {
    print("[HomeScreen] _beginSetup called");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetPasswordScreen(
          onPasswordSet: () {
            if (widget.onPasswordSetupSuccess != null) {
              print("[HomeScreen] Calling onPasswordSetupSuccess callback from setup");
              widget.onPasswordSetupSuccess!();
            }
          },
        ),
      ),
    );
    print("[HomeScreen] Setup result: $result");
  }

  void _login() async {
    print("[HomeScreen] _login called, passing onLoginSuccess callback");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onLoginSuccess: widget.onLoginSuccess),
      ),
    );
    print("[HomeScreen] Login navigation returned with result: $result");
    // If login was successful, the callback would have been called
    // and the AuthenticationWrapper should handle the navigation
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isWideScreen ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildEmergencyNotice(theme),
            const SizedBox(height: 24),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side - Mental Health Support Table
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      child: _buildSupportTable(theme),
                    ),
                  ),
                  // Right side - Main content
                  Expanded(flex: 2, child: _buildMainContent(theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildEmergencyNotice(theme),
            const SizedBox(height: 24),
            _buildMainContent(theme),
            const SizedBox(height: 32),
            _buildSupportTable(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white10
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: theme.brightness == Brightness.light
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome to Reminest",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 20),

          // Welcome back message (only show when authenticated)
          if (widget.isAuthenticated) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Welcome back! You're successfully logged in to your secure journal.",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Action buttons positioned between title and app icon
          _buildActionButtons(theme),
          const SizedBox(height: 20),

          // App logo - enlarged and centered
          Image.asset('lib/assets/icons/Reminest.png', height: 200, width: 200),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Your private, secure mental health journal.\nReflect, grow, and heal in your own safe space.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Add some additional content to balance the height
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, color: theme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Secure & Private",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: theme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Mental Wellness",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, color: theme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Track Progress",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Login Button (only show if password is already set AND not authenticated)
                if (_hasPassword && !widget.isAuthenticated) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Access your secure mental health journal",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTable(ThemeData theme) {
    final mentalHealthSupportNumbers = [
      ["Service", "Phone", "Availability", "Description"],
      [
        "Lifeline Australia",
        "13 11 14",
        "24/7",
        "Crisis support & suicide prevention",
      ],
      [
        "Beyond Blue",
        "1300 22 4636",
        "24/7",
        "Depression, anxiety & mental wellbeing",
      ],
      ["Kids Helpline", "1800 55 1800", "24/7", "Counselling for ages 5–25"],
      [
        "headspace",
        "1800 650 890",
        "Business hours",
        "Mental health for ages 12–25",
      ],
      [
        "13YARN",
        "13 92 76",
        "24/7",
        "Safe support for Aboriginal & Torres Strait Islander peoples",
      ],
      [
        "MensLine Australia",
        "1300 78 99 78",
        "24/7",
        "Support for men's emotional wellbeing",
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white10
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: theme.brightness == Brightness.light
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: theme.primaryColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Mental Health Support Resources",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: theme.brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                  boxShadow: theme.brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.primaryColor.withOpacity(0.1),
                    ),
                    dataRowMaxHeight: 56,
                    columns: mentalHealthSupportNumbers[0]
                        .map(
                          (header) => DataColumn(
                            label: Text(
                              header,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    rows: mentalHealthSupportNumbers
                        .skip(1)
                        .map(
                          (row) => DataRow(
                            cells: row.asMap().entries.map((entry) {
                              int index = entry.key;
                              String value = entry.value;
                              return DataCell(
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: index == 3 ? 200 : 150,
                                  ),
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color,
                                      fontSize: index == 1 ? 14 : 12,
                                      fontWeight: index == 1
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmergencyNotice(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency, color: Colors.red.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "In the case of an emergency, call 000 (Australia) or your local emergency number",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return SizedBox(
      height: 100, // Fixed height to prevent layout shifts
      child: Column(
        children: [
          // Begin Setup Button (only show if no password is set AND not authenticated)
          if (!_hasPassword && !widget.isAuthenticated) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _beginSetup,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text(
                  "Begin Setup",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Get started with your secure mental health journal",
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Login Button (only show if password is set AND not authenticated)
          if (_hasPassword && !widget.isAuthenticated) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login, size: 20),
                label: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Access your secure mental health journal",
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Open Journal Button (only show when authenticated)
          if (widget.isAuthenticated) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onNavigateToJournal,
                icon: const Icon(Icons.book, size: 20),
                label: const Text(
                  "Open Journal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start writing your mental health journey",
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// This is the HomeScreen widget. It serves as the landing page for the Reminest app, providing a welcoming message and mental health support resources in an integrated table format.
