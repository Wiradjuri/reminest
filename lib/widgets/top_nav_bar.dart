import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  TopNavBar({required this.selectedIndex, required this.onTabSelected});

  final List<String> titles = [
    'Homepage',
    'About Us',
    'Settings',
    'Login',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF222222),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(titles.length, (index) {
          return TextButton(
            onPressed: () => onTabSelected(index),
            style: TextButton.styleFrom(
              foregroundColor: selectedIndex == index
                  ? Color(0xFF9B59B6)
                  : Colors.white,
              textStyle: TextStyle(
                fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
              ),
            ),
            child: Text(titles[index]),
          );
        }),
      ),
    );
  }
}
// This is the coding for the TopNavBar widget. It holds The Hompage, About Us, Settings, and Login tabs.
