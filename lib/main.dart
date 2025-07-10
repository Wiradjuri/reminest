import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/top_nav_bar.dart';

void main() {
  runApp(ReminestApp());
}

class ReminestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminest',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF9B59B6),
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
      ),
      debugShowCheckedModeBanner: false,
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AboutUsScreen(),
    SettingsScreen(),
    LoginScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: TopNavBar(
          selectedIndex: _selectedIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
