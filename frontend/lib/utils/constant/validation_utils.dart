class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
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

  static String? validateNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty';
    }
    if (num.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}
