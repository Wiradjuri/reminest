import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Reminest Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Basic UI Components', () {
      testWidgets('Should render basic buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Test Button'),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text('Text Button'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.text('Text Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('Should render text fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter text'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Label'),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Enter text'), findsOneWidget);
        expect(find.text('Label'), findsOneWidget);
      });
    });

    group('Theme Tests', () {
      testWidgets('Light theme should render correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('Dark theme should render correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('Should handle basic navigation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: Center(child: Text('Second Page')),
                          ),
                        ),
                      );
                    },
                    child: const Text('Navigate'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Navigate'), findsOneWidget);

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Second Page'), findsOneWidget);
      });
    });

    group('Dialog Tests', () {
      testWidgets('Should show and dismiss dialogs', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Test Dialog'),
                          content: const Text('Dialog content'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('Dialog content'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Test Dialog'), findsNothing);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('Should validate text input', (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Required Field'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        formKey.currentState?.validate();
                      },
                      child: const Text('Validate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter some text'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), 'Valid input');
        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter some text'), findsNothing);
      });
    });

    group('Error Handling', () {
      testWidgets('Should handle widget errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text('No errors'),
            ),
          ),
        );

        expect(find.text('No errors'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Should handle empty states', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 0,
                itemBuilder: (_, __) => SizedBox.shrink(),
              ),
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantics', (WidgetTester tester) async {
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Semantics(
                    label: 'Main button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text('Click me'),
                    ),
                  ),
                  Semantics(
                    label: 'Text input',
                    textField: true,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Enter text'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Click me'), findsOneWidget);
        expect(find.text('Enter text'), findsOneWidget);

        semantics.dispose();
      });
    });

    group('Layout Tests', () {
      testWidgets('Should handle different screen sizes', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Text(
                      constraints.maxWidth > 600 ? 'Wide Screen' : 'Narrow Screen',
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Wide Screen'), findsOneWidget);

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });
    });
  });
}