import 'package:get/get.dart';

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    // Use GetUtils to check for a valid email
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name cannot be empty';
    }
    if (value.length < 3) {
      return 'Full name must be at least 3 characters long';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    // Check for exactly 9 digits and starting with 61 or 62.
    if (value.length != 9 ||
        (!value.startsWith('61') && !value.startsWith('62'))) {
      return 'Enter a valid Somalia phone number starting with 61 or 62';
    }
    // Use GetUtils for an additional phone number validation (if needed)
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
