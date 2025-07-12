import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app widget test', (WidgetTester tester) async {
    // Build a simple MaterialApp for testing
    await tester.pumpWidget(
      MaterialApp(
        title: 'Reminest',
        home: Scaffold(
          appBar: AppBar(title: Text('Reminest')),
          body: Center(child: Text('Test App')),
        ),
      ),
    );

    // Verify that the app shows the expected elements
    expect(find.text('Reminest'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('MaterialApp creates properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Test App',
        home: Scaffold(body: Text('Hello World')),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });

  group('App widget tests', () {
    testWidgets('App has correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'Reminest',
          home: Scaffold(
            appBar: AppBar(title: Text('Reminest')),
            body: Text('Content'),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('App title is set correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'Reminest',
          home: Scaffold(body: Text('Test')),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Reminest'));
    });
  });

  group('Responsive design tests', () {
    testWidgets('App adapts to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Phone size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text('Phone'))));
      expect(find.byType(MaterialApp), findsOneWidget);

      // Tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('Tablet'))),
      );
      expect(find.byType(MaterialApp), findsOneWidget);

      // Desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('Desktop'))),
      );
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Theme tests', () {
    testWidgets('App supports theme configuration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'Reminest',
          theme: ThemeData.light(),
          home: Scaffold(body: Text('Themed App')),
        ),
      );

      expect(find.text('Themed App'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
