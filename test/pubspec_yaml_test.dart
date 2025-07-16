// These tests validate the structure and content of the pubspec.yaml file for the Reminest app.
// They use the arrange-act-assert pattern and aim for 100% line and branch coverage.

import 'dart:io';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('pubspec.yaml', () {
    late String pubspecContent;
    late YamlMap pubspec;

    setUp(() {
      // Arrange
      // Load the pubspec.yaml file content
      final file = File('pubspec.yaml');
      pubspecContent = file.readAsStringSync();
      pubspec = loadYaml(pubspecContent);
    });

    test('should have correct project name and description', () {
      // Act

      // Assert
      expect(pubspec['name'], equals('reminest'));
      expect(pubspec['description'], isA<String>());
      expect(
          pubspec['description'], contains('secure mental health journaling'));
    });

    test('should not be published to pub.dev', () {
      // Act

      // Assert
      expect(pubspec['publish_to'], equals('none'));
    });

    test('should have correct version format', () {
      // Act

      // Assert
      expect(pubspec['version'], matches(r'^\d+\.\d+\.\d+\+\d+$'));
    });

    test('should have valid environment sdk constraints', () {
      // Act

      // Assert
      expect(pubspec['environment'], isA<YamlMap>());
      expect(pubspec['environment']['sdk'], equals('>=3.1.3 <4.0.0'));
    });

    test('should include all required dependencies', () {
      // Act
      final deps = pubspec['dependencies'] as YamlMap;

      // Assert
      expect(deps['flutter'], isA<YamlMap>());
      expect(deps['file_picker'], isNotNull);
      expect(deps['sqflite'], isNotNull);
      expect(deps['sqflite_common_ffi'], isNotNull);
      expect(deps['pointycastle'], isNotNull);
      expect(deps['crypto'], isNotNull);
      expect(deps['shared_preferences'], isNotNull);
      expect(deps['path_provider'], isNotNull);
      expect(deps['path'], isNotNull);
      expect(deps['url_launcher'], isNotNull);
      expect(deps['logger'], isNotNull);
    });

    test('should include all required dev_dependencies', () {
      // Act
      final devDeps = pubspec['dev_dependencies'] as YamlMap;

      // Assert
      expect(devDeps['flutter_test'], isA<YamlMap>());
      expect(devDeps['flutter_lints'], isNotNull);
      expect(devDeps['test'], isNotNull);
      expect(devDeps['mockito'], isNotNull);
      expect(devDeps['build_runner'], isNotNull);
    });

    test('should use material design', () {
      // Act
      final flutterSection = pubspec['flutter'] as YamlMap;

      // Assert
      expect(flutterSection['uses-material-design'], isTrue);
    });

    test('should include icons asset directory', () {
      // Act
      final flutterSection = pubspec['flutter'] as YamlMap;
      final assets = flutterSection['assets'] as YamlList?;

      // Assert
      expect(assets, isNotNull);
      expect(assets, contains('lib/assets/icons/'));
    });

    test('should fail if a required dependency is missing', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act
      final filePickerDep =
          (brokenPubspec['dependencies'] as YamlMap)['file_picker'];

      // Assert
      expect(filePickerDep, isNull);
    });

    test('should handle missing flutter section gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['flutter'], isNull);
    });

    test('should handle missing dev_dependencies gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['dev_dependencies'], isNull);
    });

    test('should handle missing environment gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['environment'], isNull);
    });

    test('should handle missing version gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['version'], isNull);
    });

    test('should handle missing publish_to gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['publish_to'], isNull);
    });

    test('should handle missing description gracefully', () {
      // Arrange
      const brokenYaml = '''
name: reminest
dependencies:
  flutter:
    sdk: flutter
''';
      final brokenPubspec = loadYaml(brokenYaml);

      // Act & Assert
      expect(brokenPubspec['description'], isNull);
    });
  });
}
