class AppConstants {
  // App Information
  static const String appName = 'Reminest';
  static const String appVersion = '1.0.0+1';
  static const String appDescription = 'Your Mental Health Journal';
  
  // PIN Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  
  // Password Validation
  static const int minPasswordLength = 6;
  
  // Recovery Passkey
  static const int passkeyLength = 16;
  
  // Date Ranges
  static const int maxFutureDays = 365 * 5; // 5 years
  static const int minFutureDays = 1;
  
  // Mental Health Support Resources
  static const List<List<String>> mentalHealthSupport = [
    ["Service", "Phone", "Availability", "Description"],
    ["Lifeline Australia", "13 11 14", "24/7", "Crisis support & suicide prevention"],
    ["Beyond Blue", "1300 22 4636", "24/7", "Depression, anxiety & mental wellbeing"],
    ["Kids Helpline", "1800 55 1800", "24/7", "Counselling for ages 5–25"],
    ["headspace", "1800 650 890", "Business hours", "Mental health for ages 12–25"],
    ["13YARN", "13 92 76", "24/7", "Safe support for Aboriginal & Torres Strait Islander peoples"],
    ["MensLine Australia", "1300 78 99 78", "24/7", "Support for men's emotional wellbeing"],
  ];
  
  // Emergency Information
  static const String emergencyNumber = '000 (Australia)';
  static const String emergencyMessage = 'In the case of an emergency, call 000 (Australia) or your local emergency number';
  
  // Help URL
  static const String helpUrl = 'https://github.com/Wiradjuri/reminest';
  
  // Navigation Indices
  static const int homeIndex = 0;
  static const int journalIndex = 1;
  static const int settingsIndex = 2;
  static const int aboutIndex = 3;
  
  // Asset Paths
  static const String appIconPath = 'lib/assets/icons/Reminest.png';
  static const String developerIconPath = 'lib/assets/icons/Developer.png';
}