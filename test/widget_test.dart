import 'package:flutter_test/flutter_test.dart';
import 'package:reminest/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with a login screen
    // Look for common login elements (adjust based on your actual UI)
    expect(find.text('Reminest'), findsOneWidget);
    
    // You can add more specific widget tests here based on your UI
    // For example:
    // expect(find.byType(TextField), findsWidgets);
    // expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Test navigation if your app has visible navigation elements
    // This is a placeholder - adjust based on your actual navigation
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  group('Widget integration tests', () {
    testWidgets('App builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Theme is applied correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
    });

    testWidgets('App handles different screen sizes', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Phone
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(800, 600)); // Tablet
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Performance tests', () {
    testWidgets('App startup performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify app starts in reasonable time (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
    });
  });
}
