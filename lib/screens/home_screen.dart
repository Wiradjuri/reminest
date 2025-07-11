import 'package:flutter/material.dart';
import '../services/key_service.dart';
import '../screens/set_password_screen.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final bool isAuthenticated; // Add flag to indicate if already authenticated
  
  HomeScreen({this.onLoginSuccess, this.isAuthenticated = false});

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

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh password status when widget updates
    _checkPasswordStatus();
  }

  Future<void> _checkPasswordStatus() async {
    final hasPassword = await KeyService.hasPassword();
    setState(() {
      _hasPassword = hasPassword;
    });
  }

  void _beginSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SetPasswordScreen()),
    );
    // If setup was successful, call the login success callback
    if (result == true && widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    }
  }

  void _login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(onLoginSuccess: widget.onLoginSuccess)),
    );
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
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side - Mental Health Support Table
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(right: 24),
                      child: _buildSupportTable(theme),
                    ),
                  ),
                  // Right side - Main content
                  Expanded(
                    flex: 2,
                    child: _buildMainContent(theme),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildEmergencyNotice(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildMainContent(theme),
            SizedBox(height: 32),
            _buildSupportTable(theme),
            SizedBox(height: 24),
            _buildEmergencyNotice(theme),
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
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: theme.primaryColor),
          SizedBox(height: 20),
          Text(
            "Welcome to Reminest",
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: theme.textTheme.titleLarge?.color
            ),
          ),
          SizedBox(height: 20),
          // App logo - moved between title and subtitle, made bigger
          Image.asset(
            'lib/assets/icons/Reminest.png',
            height: 150,
            width: 150,
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Your private, secure mental health journal.\nReflect, grow, and heal in your own safe space.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)
              ),
            ),
          ),
          SizedBox(height: 30),
          // Add some additional content to balance the height
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, color: theme.primaryColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Secure & Private",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: theme.primaryColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Mental Wellness",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, color: theme.primaryColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Track Progress",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                
                // Begin Setup Button (only show if no password is set AND not authenticated)
                if (!_hasPassword && !widget.isAuthenticated) ...[
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _beginSetup,
                      icon: Icon(Icons.play_arrow, size: 20),
                      label: Text(
                        "Begin Setup",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Get started with your secure mental health journal",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                // Login Button (only show if password is already set AND not authenticated)
                if (_hasPassword && !widget.isAuthenticated) ...[
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _login,
                      icon: Icon(Icons.login, size: 20),
                      label: Text(
                        "Login",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
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
      ["Lifeline Australia", "13 11 14", "24/7", "Crisis support & suicide prevention"],
      ["Beyond Blue", "1300 22 4636", "24/7", "Depression, anxiety & mental wellbeing"],
      ["Kids Helpline", "1800 55 1800", "24/7", "Counselling for ages 5–25"],
      ["headspace", "1800 650 890", "Business hours", "Mental health for ages 12–25"],
      ["13YARN", "13 92 76", "24/7", "Safe support for Aboriginal & Torres Strait Islander peoples"],
      ["MensLine Australia", "1300 78 99 78", "24/7", "Support for men's emotional wellbeing"],
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: theme.primaryColor, size: 28),
              SizedBox(width: 12),
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
          SizedBox(height: 20),
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
                      ? [BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )]
                      : null,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      theme.primaryColor.withOpacity(0.1),
                    ),
                    dataRowMaxHeight: 56,
                    columns: mentalHealthSupportNumbers[0].map((header) => DataColumn(
                      label: Text(
                        header,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    )).toList(),
                    rows: mentalHealthSupportNumbers.skip(1).map((row) => DataRow(
                      cells: row.asMap().entries.map((entry) {
                        int index = entry.key;
                        String value = entry.value;
                        return DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: index == 3 ? 200 : 150),
                            child: Text(
                              value,
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: index == 1 ? 14 : 12,
                                fontWeight: index == 1 ? FontWeight.w600 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        );
                      }).toList(),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmergencyNotice(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency, color: Colors.red.shade600, size: 24),
          SizedBox(width: 12),
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
}
// This is the HomeScreen widget. It serves as the landing page for the Reminest app, providing a welcoming message and mental health support resources in an integrated table format.
