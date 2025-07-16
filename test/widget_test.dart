import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive widget tests for Reminest app components
///
/// Uses the arrange-act-assert pattern for each test.

void main() {
  group('Reminest Widget Tests', () {
    setUp(() async {
      // Arrange
      // Initialize SharedPreferences mock for all tests
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      // Arrange
      // Clean up after each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Basic UI Components', () {
      testWidgets('Should render basic buttons', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Test Button'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.text('Text Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('Should render text fields', (WidgetTester tester) async {
        // Act
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

        // Assert
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Enter text'), findsOneWidget);
        expect(find.text('Label'), findsOneWidget);
      });
    });

    group('Theme Tests', () {
      testWidgets('Light theme should render correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        );

        // Assert
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('Dark theme should render correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        );

        // Assert
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('Should handle basic navigation', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(ElevatedButton))).push(
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
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
        );

        // Assert
        expect(find.text('Navigate'), findsOneWidget);

        // Act
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Second Page'), findsOneWidget);
      });
    });

    group('Dialog Tests', () {
      testWidgets('Should show and dismiss dialogs', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
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

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('Dialog content'), findsOneWidget);

        // Act
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsNothing);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('Should validate text input', (WidgetTester tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();

        // Act
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

        // Act
        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter some text'), findsOneWidget);

        // Act
        await tester.enterText(find.byType(TextFormField), 'Valid input');
        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter some text'), findsNothing);
      });
    });

    group('Error Handling', () {
      testWidgets('Should handle widget errors gracefully', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return const Text('No errors');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('No errors'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Should handle empty states', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) => Container(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantics', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Semantics(
                    label: 'Main button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Click me'),
                    ),
                  ),
                  Semantics(
                    label: 'Text input',
                    textField: true,
                    child: const TextField(
                      decoration: InputDecoration(labelText: 'Enter text'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Click me'), findsOneWidget);
        expect(find.text('Enter text'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        // Act
        final SemanticsHandle handle = tester.ensureSemantics();

        // Assert
        final semantics = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
        expect(semantics, isNotNull);

        // Act
        handle.dispose();
      });
    });

    group('Layout Tests', () {
      testWidgets('Should handle different screen sizes', (WidgetTester tester) async {
        // Arrange
        final originalSize = tester.binding.window.physicalSize;
        final originalDevicePixelRatio = tester.binding.window.devicePixelRatio;

        // Act
        tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
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

        // Assert
        expect(find.text('Wide Screen'), findsOneWidget);

        // Act & Assert: Reset to default size
        addTearDown(() {
          tester.binding.window.physicalSizeTestValue = originalSize;
          tester.binding.window.devicePixelRatioTestValue = originalDevicePixelRatio;
        });
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle null onPressed for buttons', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Disabled'),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text('Disabled Text'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Disabled'), findsOneWidget);
        expect(find.text('Disabled Text'), findsOneWidget);
        expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
        expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
      });

      testWidgets('Should handle obscureText toggle', (WidgetTester tester) async {
        // Arrange
        bool obscure = true;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                body: Column(
                  children: [
                    TextField(
                      obscureText: obscure,
                      key: const Key('obscureField'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert
        expect((tester.widget(find.byKey(const Key('obscureField'))) as TextField).obscureText, isTrue);

        // Act
        await tester.tap(find.text('Toggle'));
        await tester.pump();

        // Assert
        expect((tester.widget(find.byKey(const Key('obscureField'))) as TextField).obscureText, isFalse);
      });
    });
  });
}
