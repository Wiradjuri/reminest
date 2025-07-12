# Reminest - Your Private Mental Health Vault

Reminest is a secure, privacy-first mental health journaling application designed to help users safely document their thoughts, feelings, and mental health journey. Built with Flutter for cross-platform compatibility, Reminest prioritizes user privacy by storing all data locally with military-grade encryption, ensuring your most personal thoughts remain completely private and secure.

## Why Reminest?

Mental health journaling is a powerful tool for self-reflection, emotional processing, and tracking personal growth. However, traditional journaling apps often store your data in the cloud, where it can be accessed by third parties, sold to advertisers, or compromised in data breaches. Reminest takes a different approach - your mental health data belongs to you, and only you.

## Privacy & Security Features

- **100% Local Storage:** All journal entries are stored exclusively on your device - never uploaded to any cloud service
- **Military-Grade Encryption:** Every entry is encrypted using AES-256 encryption before being saved to your device
- **Multi-Layer Security:**
  - Password-protected app access with secure key derivation
  - Optional vault PIN for additional security layer
  - Biometric authentication support (where available)
- **Zero Data Collection:** We don't collect, track, or store any personal information or usage analytics
- **Open Source Transparency:** Full source code available for security auditing and community review
- **No Internet Required:** Works completely offline - your data never leaves your device

## Key Features

- **Secure Journaling:** Write and store encrypted journal entries with timestamps
- **Emotional Tracking:** Document your feelings and mental state over time
- **Privacy by Design:** Every aspect built with privacy as the primary concern
- **Cross-Platform:** Available on Windows, macOS, Linux, Android, iOS, and Web
- **Responsive Design:** Beautiful, accessible interface that adapts to any screen size
- **Backup & Restore:** Export encrypted backups that only you can decrypt
- **Search & Filter:** Find past entries while maintaining full encryption
- **Mental Health Resources:** Built-in access to crisis support and mental health resources

## Getting Started

### Prerequisites

- Flutter 3.32.5 or later
- Dart SDK 3.0 or later
- Platform-specific requirements:
  - **Windows:** Visual Studio 2022 with C++ support
  - **macOS:** Xcode 14 or later
  - **Linux:** CMake and ninja-build
  - **Android:** Android Studio and SDK
  - **iOS:** Xcode and iOS SDK

### Installation

1. **Clone the Repository**
    ```bash
    git clone https://github.com/Wiradjuri/mental_health_vault.git
    cd mental_health_vault
    ```

2. **Install Dependencies**
    ```bash
    flutter pub get
    ```

3. **Run the Application**
    ```bash
    # For desktop (Windows/macOS/Linux)
    flutter run -d windows
    flutter run -d macos
    flutter run -d linux
    
    # For mobile
    flutter run -d android
    flutter run -d ios
    
    # For web
    flutter run -d chrome
    ```

## Security Architecture

Reminest implements multiple layers of security to protect your mental health data:

1. **Application Layer:** Password-based authentication with secure key derivation (PBKDF2)
2. **Encryption Layer:** AES-256-GCM encryption for all journal entries and metadata
3. **Storage Layer:** Platform-specific secure storage using Flutter Secure Storage
4. **Database Layer:** Local SQLite database with encrypted data at rest
5. **Memory Protection:** Sensitive data cleared from memory after use

## Building from Source

### For Windows
```bash
flutter build windows --release
```

### For Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### For Web
```bash
flutter build web --release
```

## Mental Health Resources

Reminest includes built-in access to mental health support resources:

- **Crisis Support:** Quick access to suicide prevention hotlines and crisis text lines
- **Professional Help:** Information about finding mental health professionals
- **Self-Care Tips:** Evidence-based mental health and wellness strategies
- **Emergency Contacts:** Quick access to emergency services

### Important Note
Reminest is a journaling tool designed to support your mental health journey, but it is not a substitute for professional mental health care. If you're experiencing a mental health crisis, please contact emergency services or a mental health professional immediately.

## Development

### Project Structure
```
lib/
├── main.dart              # App entry point
├── models/               # Data models
├── screens/              # UI screens
├── services/             # Core services (encryption, database, etc.)
├── theme/                # App theming
└── widgets/              # Reusable UI components
```

### Key Services
- **PlatformDatabaseService:** Cross-platform SQLite database management
- **EncryptionService:** AES-256 encryption/decryption
- **KeyService:** Secure key generation and management
- **PasswordService:** Password hashing and verification

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/encryption_service_test.dart
```

## Roadmap

- [ ] Import/Export encrypted backup files
- [ ] Advanced search with date ranges and mood filters
- [ ] Mood tracking with visual charts
- [ ] Customizable themes and fonts
- [ ] Accessibility improvements
- [ ] Additional language support

## Contributing

We welcome contributions that improve privacy, security, or user experience! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

Before contributing, please read our security guidelines and ensure any changes maintain the privacy-first design principles.

## Privacy Policy

Reminest follows these privacy principles:

- **No Data Collection:** We don't collect any personal information
- **No Analytics:** No usage tracking or analytics
- **No Telemetry:** No crash reports or diagnostic data sent
- **Local Only:** All data stays on your device
- **Open Source:** Full transparency through open source code

## Security Disclosure

If you discover a security vulnerability, please email bmuzza1992@gmail.com with details. We take security seriously and will respond promptly to legitimate security concerns.

## Support

For support or questions:
- Open an issue on GitHub
- Email: bmuzza1992@gmail.com

## Acknowledgments

- Built with Flutter and Dart
- Uses SQLite for local database storage
- Implements AES-256 encryption via PointyCastle
- Inspired by the need for truly private mental health tools

## License

Copyright (c) 2025 Bradley Murray

All Rights Reserved.

You are NOT permitted to access, use, copy, modify, distribute, or sublicense any part of this codebase without obtaining express written permission from the copyright holder.

Any unauthorized use of this code or its derivatives is strictly prohibited and may result in legal action.

For inquiries regarding permission to access or use this code, please contact: <bmuzza1992@gmail.com>