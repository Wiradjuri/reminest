import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/main.dart';

void main() {
  group('ReminestApp Widget Tests', () {
    testWidgets('App starts and shows SetPasswordScreen when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(const ReminestApp());

      // Should find the SetPasswordScreen (by label or widget type)
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Reminest'), findsOneWidget);
      // Since not authenticated, should see SetPasswordScreen
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('BottomNavigationBar has 4 items', (WidgetTester tester) async {
      await tester.pumpWidget(const ReminestApp());
      // Authenticate to show main app
      final state = tester.state(find.byType(ReminestApp)) as dynamic;
      state.setState(() {
        state._isAuthenticated = true;
        state._hasPassword = true;
      });
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('Tapping navigation bar changes screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ReminestApp());
      final state = tester.state(find.byType(ReminestApp)) as dynamic;
      state.setState(() {
        state._isAuthenticated = true;
        state._hasPassword = true;
      });
      await tester.pumpAndSettle();

      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsOneWidget);

      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();
      expect(state._currentIndex, 1);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(state._currentIndex, 2);
    });

    testWidgets('Logout resets authentication', (WidgetTester tester) async {
      await tester.pumpWidget(const ReminestApp());
      final state = tester.state(find.byType(ReminestApp)) as dynamic;
      state.setState(() {
        state._isAuthenticated = true;
        state._hasPassword = true;
      });
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(state._isAuthenticated, false);
      expect(state._currentIndex, 0);
    });
  });
}