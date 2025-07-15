---
# Codacy Rules
Configuration for AI behavior when interacting with Codacy's MCP Server

## After ANY successful `edit_file` or `reapply` operation
- YOU MUST IMMEDIATELY run the `codacy_cli_analyze` tool from Codacy's MCP Server for each file that was edited, with:
  - `rootPath`: set to the workspace path
  - `file`: set to the path of the edited file
  - `tool`: leave empty or unset
- If any issues are found in the new edits, propose and apply fixes for them.

## CRITICAL: Dependencies and Security Checks
- IMMEDIATELY after ANY of these actions:
  - Installing or updating dependencies
  - Modifying any known package manager files
- Run `codacy_cli_analyze` with:
  - `tool`: "trivy"
  - `rootPath`: workspace path
- Stop other operations if vulnerabilities are found, and fix them first.

## Code Completion and Best Practice Assistance (Flutter / Dart)
- When editing Dart/Flutter code:
  - Recommend best practices for widget design, async handling, null safety, and state management
  - Recommend common architecture patterns (e.g., BLoC, Provider, MVVM, Clean Architecture)
  - Warn if:
    - Widget classes grow too large (over 200 LOC)
    - Logic is embedded directly in UI (break it out into services or controllers)
    - Direct use of `setState` is overused (consider refactoring to Provider/BLoC)

- Always prefer idiomatic Dart:
  - Recommend `late`, `required`, `final`, `const` usage where applicable
  - Use `List<T>.generate`, `.where()`, `.map()` idioms over manual for-loops when cleaner
  - Avoid null-safety suppression (`!`) unless there's a clear reason

- When editing a file with incomplete functions or methods:
  - Offer to generate the correct method signature and structure based on surrounding code
  - Suggest DartDoc-style comments where missing
  - When a missing class, method, or property is referenced: generate a stub version

## Test Assistance
- If test files are missing for any service or screen:
  - Propose and create `*_test.dart` files with basic `group()` and `test()` blocks
- If public methods have no corresponding test:
  - Suggest creating matching unit tests

## Whenever a call to a Codacy tool returns a 404
- Offer to run `codacy_setup_repository` to register the repo
- If accepted, run the tool and retry the original action

## General
- Always prefer best-practice Dart and Flutter patterns
- Recommend cleanup and refactoring for long methods (>30 lines)
- Automatically fix obvious style issues (unused imports, incorrect naming, etc.)
- Never ignore lint warnings; treat them as actionable unless explicitly suppressed
---

# .github/copilot-instructions.md

# Reminest - Mental Health Journal App

## Project Overview
Reminest is a cross-platform Flutter application for secure mental health journaling with vault functionality for time-locked entries. The app prioritizes privacy, security, and user mental wellness.

## Architecture & Structure

### Core Services
- **PlatformDatabaseService**: Cross-platform database handling (SQLite for desktop/mobile, SharedPreferences for web)
- **EncryptionService**: AES-256 encryption for journal entries using PointyCastle
- **PasswordService**: Secure password management with PBKDF2 hashing and recovery passkeys
- **KeyService**: Cryptographic key generation and vault PIN management

### Key Models
- **JournalEntry**: Main data model with encryption support, vault flags, and time-locking
- Contains: id, title, body, imagePath, createdAt, reviewDate, isReviewed, isInVault

### Platform Support
- **Mobile**: Android, iOS (using sqflite)
- **Desktop**: Windows, Linux, macOS (using sqflite_common_ffi)
- **Web**: Browser-based (using SharedPreferences for storage)

## Security Requirements

### Encryption Standards
- Use AES-256-CBC encryption for all sensitive data
- PBKDF2 with 100,000+ iterations for password hashing
- Secure random IV generation for each encryption operation
- No plaintext storage of user content

### Authentication Flow
1. Check if password is set via PasswordService.isPasswordSet()
2. If not set: redirect to SetPasswordScreen with passkey generation
3. If set: authenticate via LoginScreen with password verification
4. Initialize EncryptionService with derived key after successful auth

### Vault Security
- Vault entries are encrypted journal entries with time-locks
- PIN-based access separate from main password
- Unrecoverable PINs (user must be warned)
- Automatic unlock based on reviewDate

## Coding Conventions

### File Structure
```
lib/
├── models/           # Data models (JournalEntry, etc.)
├── services/         # Business logic and platform services
├── screens/          # UI screens and pages
├── assets/           # Images, icons, fonts
└── main.dart         # App entry point
```

### Error Handling
- Always wrap database operations in try-catch blocks
- Use ScaffoldMessenger for user-facing error messages
- Log errors with context: `print("[ServiceName] Error description: $e")`
- Graceful degradation for platform-specific features

### State Management
- Use StatefulWidget for local state
- Call setState() for UI updates
- Dispose controllers and listeners properly
- Handle mounted checks before setState() in async operations

### Platform-Specific Code
```dart
if (kIsWeb) {
  // Web-specific implementation using SharedPreferences
} else if (Platform.isAndroid || Platform.isIOS) {
  // Mobile implementation using sqflite
} else {
  // Desktop implementation using sqflite_common_ffi
}
```

### Database Patterns
- Always call PlatformDatabaseService.initDB() before operations
- Use encrypted storage for title and body content
- Maintain backward compatibility with existing data schemas
- Handle database initialization failures gracefully

## UI/UX Guidelines

### Theme Support
- Support both light and dark themes
- Use Theme.of(context) for colors and styling
- Consistent color scheme: primary blue (#2196F3), whites/grays for backgrounds
- Material Design 3 principles

### Navigation Patterns
- Use Navigator.push/pop for screen transitions
- Return results from screens that modify data (bool for success/failure)
- Maintain proper navigation stack for user experience

### Form Validation
- Real-time validation feedback with colored containers
- Clear error messages with icons (warning, error, success)
- Disable buttons during loading states
- Show progress indicators for async operations

### Mental Health Considerations
- Include crisis support resources prominently
- Emergency contact information (000, Lifeline, Beyond Blue)
- Non-judgmental language and supportive UI
- Privacy-first design with no external data sharing

## Testing Guidelines

### Unit Test Patterns
- Mock external dependencies (file system, database)
- Test encryption/decryption roundtrips
- Verify password hashing and verification
- Test platform-specific service implementations

### Widget Test Patterns
- Test form validation and user interactions
- Verify navigation flows and state changes
- Mock platform services using dependency injection
- Test error handling and edge cases

## Dependencies

### Core Dependencies
```yaml
flutter: sdk
sqflite: ^2.3.0           # Mobile database
sqflite_common_ffi: ^2.3.0 # Desktop database
pointycastle: ^3.7.3      # Encryption
crypto: ^3.0.3            # Hashing utilities
shared_preferences: ^2.2.2 # Cross-platform preferences
path_provider: ^2.1.1     # File system paths
file_picker: ^6.1.1       # File selection
url_launcher: ^6.2.1      # External URLs
```

### Platform Channels
- Avoid platform channels unless absolutely necessary
- Use existing packages for platform-specific functionality
- Fallback gracefully when platform features unavailable

## Development Notes

### Building & Testing
- Test on all target platforms before release
- Verify encryption/decryption across platform boundaries
- Test vault functionality with various time scenarios
- Validate password recovery flows thoroughly

### Performance Considerations
- Lazy load journal entries for large datasets
- Optimize image handling and storage
- Minimize encryption operations in UI thread
- Cache decrypted content appropriately (with security considerations)

### Privacy & Legal
- No analytics or crash reporting by default
- All data stored locally (no cloud sync)
- User controls all data export/import
- Clear data deletion capabilities

## Common Patterns

### Service Initialization
```dart
// Always check initialization status
if (!_isInitialized) await initDB();

// Handle initialization failures
try {
  await ServiceName.initialize();
} catch (e) {
  // Fallback or error handling
}
```

### Secure Data Handling
```dart
// Encrypt before storage
final encryptedTitle = EncryptionService.encryptText(entry.title);

// Decrypt after retrieval
final plainTitle = EncryptionService.decryptText(storedTitle);
```

### Cross-Platform File Handling
```dart
// Use platform-appropriate paths
final directory = await getApplicationDocumentsDirectory();
final dbPath = path.join(directory.path, 'database.db');
```

Remember: This app handles sensitive mental health data. Always prioritize security, privacy, and user safety in all implementations.
