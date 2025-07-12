import 'dart:convert';
import 'lib/services/key_service.dart';
import 'package:crypto/crypto.dart';

void main() async {
  // Test 1: Password Security
  const testPassword = "MySecurePassword123!";
  await KeyService.savePasswordHash(testPassword);
  final isValidPassword = await KeyService.verifyPassword(testPassword);
  assert(isValidPassword == true);
  final isInvalidPassword = await KeyService.verifyPassword("WrongPassword");
  assert(isInvalidPassword == false);

  // Test 2: Unique Salt Usage
  await KeyService.clearAllPasswordData();
  await KeyService.savePasswordHash(testPassword);
  final firstHash = await KeyService.getPasswordHash();
  
  await KeyService.clearAllPasswordData();
  await KeyService.savePasswordHash(testPassword);
  final secondHash = await KeyService.getPasswordHash();
  
  assert(firstHash != secondHash);
  // Test 3: Complete Data Erasure
  await KeyService.savePasswordHash(testPassword);
  await KeyService.saveVaultPin("1234");
  await KeyService.clearAllPasswordData();
  await KeyService.clearVaultPin();
  
  final hasPasswordAfterClear = await KeyService.hasPassword();
  final hasPinAfterClear = await KeyService.hasVaultPin();
  
  assert(hasPasswordAfterClear == false);
  assert(hasPinAfterClear == false);

  // Additional Tests: PIN Verification
  await KeyService.saveVaultPin("1234");
  final isPinCorrect = await KeyService.verifyVaultPin("1234");
  assert(isPinCorrect == true);

  final isPinIncorrect = await KeyService.verifyVaultPin("4321");
  assert(isPinIncorrect == false);

  // Additional Tests: Test Password with Special Characters
  const specialCharPassword = "P@$$w0rd!";
  await KeyService.clearAllPasswordData();
  await KeyService.savePasswordHash(specialCharPassword);
  final isSpecialCharPasswordValid = await KeyService.verifyPassword(specialCharPassword);
  assert(isSpecialCharPasswordValid == true);

  // Complete
  print("All tests passed successfully.");
}
