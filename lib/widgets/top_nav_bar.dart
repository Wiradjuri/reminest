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
    final theme = Theme.of(context);
    
    return Container(
      color: theme.primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(titles.length, (index) {
          return TextButton(
            onPressed: () => onTabSelected(index),
            style: TextButton.styleFrom(
              foregroundColor: selectedIndex == index
                  ? theme.primaryColor
                  : theme.textTheme.bodyMedium?.color,
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
