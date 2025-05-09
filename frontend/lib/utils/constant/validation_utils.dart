class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email-ka lama dhaafi karo';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Fadlan geli email sax ah';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Furaha sirta lama dhaafi karo';
    }
    if (value.length < 6) {
      return 'Furaha sirta waa inuu ka koobnaadaa ugu yaraan 6 xaraf';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Magaca buuxa lama dhaafi karo';
    }
    if (value.length < 3) {
      return 'Magaca buuxa waa inuu ka koobnaadaa ugu yaraan 3 xaraf';
    }
    return null;
  }

  static String? validateNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Goobtan lama dhaafi karo';
    }
    if (num.tryParse(value) == null) {
      return 'Fadlan geli tiro sax ah';
    }
    return null;
  }
}
