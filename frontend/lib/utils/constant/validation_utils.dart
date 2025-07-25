class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email-ka lama dhaafi karo';
    }
    // Email must start with a letter, not number or symbol
    final emailRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email-ku waa inuu ku bilaabmaa xaraf, kana koobnaadaa qaab sax ah';
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
    // Remove extra spaces and check for at least two words
    final trimmedValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final nameParts = trimmedValue.split(' ');
    
    if (nameParts.length < 2) {
      return 'Fadlan geli magaca buuxa (magaca koowaad iyo kan dambe)';
    }
    
    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Magaca waa inuu ka koobnaa xarfo kaliya, ma aqbali karo lambar ama calaamado';
    }
    
    // Check minimum length for each name part
    for (String part in nameParts) {
      if (part.length < 2) {
        return 'Magac kasta waa inuu ka koobnaadaa ugu yaraan 2 xaraf';
      }
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

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lambarka telefoonka lama dhaafi karo';
    }
    // Remove any spaces or special characters
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Check if it's exactly 9 digits and starts with 61
    final phoneRegex = RegExp(r'^61\d{7}$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Lambarka waa inuu ka bilaabmaa 61 oo ah 9 lambar oo dhan (tusaale: 61xxxxxxx)';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Goobtan lama dhaafi karo';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Fadlan geli tiro sax ah';
    }
    if (number <= 0) {
      return 'Tirada waa inay ka weyn tahay eber (0)';
    }
    return null;
  }

  static String? validateNonNegativeNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Goobtan lama dhaafi karo';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Fadlan geli tiro sax ah';
    }
    if (number < 0) {
      return 'Tirada ma noqon karto mid taban';
    }
    return null;
  }
}
