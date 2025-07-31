import 'constants.dart';

class Validators {
  // PIN Validation
  static bool isValidPin(String pin) {
    return pin.length >= AppConstants.minPinLength &&
           pin.length <= AppConstants.maxPinLength &&
           RegExp(r'^\d+$').hasMatch(pin);
  }
  
  static String? validatePin(String pin) {
    if (pin.isEmpty) return 'PIN cannot be empty';
    if (!isValidPin(pin)) {
      return 'PIN must be ${AppConstants.minPinLength}-${AppConstants.maxPinLength} digits';
    }
    return null;
  }
  
  // Password Validation
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }
  
  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password cannot be empty';
    if (!isValidPassword(password)) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }
  
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
  
  // Entry Validation
  static String? validateEntryTitle(String title) {
    if (title.trim().isEmpty) return 'Title cannot be empty';
    return null;
  }
  
  static String? validateEntryBody(String body) {
    if (body.trim().isEmpty) return 'Content cannot be empty';
    return null;
  }
  
  // Passkey Validation
  static bool isValidPasskey(String passkey) {
    return passkey.length == AppConstants.passkeyLength &&
           RegExp(r'^[A-Z0-9]+$').hasMatch(passkey);
  }
  
  static String? validatePasskey(String passkey) {
    if (passkey.isEmpty) return 'Passkey cannot be empty';
    if (!isValidPasskey(passkey)) {
      return 'Passkey must be ${AppConstants.passkeyLength} characters';
    }
    return null;
  }
  
  // Password Strength Calculation
  static int calculatePasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }
  
  static String getPasswordStrengthLabel(int strength) {
    const labels = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];
    return labels[strength.clamp(0, 4)];
  }
}