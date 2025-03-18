import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Branding)
  static const Color primaryGold = Color(0xFFC1914D); // Rich Gold
  static const Color primaryBlack = Color(
    0xFF121212,
  ); // Soft Black (Better on OLED)

  // Secondary Colors (Supporting)
  static const Color secondaryWhite = Color(0xFFFFFFFF); // White
  static const Color secondaryGray = Color(
    0xFFE0E0E0,
  ); // Lighter gray for UI elements
  static const Color secondaryBeige = Color(0xFFF7F1E3); // Soft beige

  // Accent Colors (Enhancements)
  static const Color accentDarkGold = Color(0xFF8D6E3C);
  static const Color accentLightGold = Color(
    0xFFFFD700,
  ); // Bright gold for highlights

  // Text Colors
  static const Color textPrimary = Color(
    0xFF1E1E1E,
  ); // Almost black for better readability
  static const Color textSecondary = Color(
    0xFF8D6E3C,
  ); // Gold tone for emphasis
  static const Color textWhite = secondaryWhite;
  static const Color textGray = Color(
    0xFF757575,
  ); // Muted gray for secondary text
  static const Color textError = Color(0xFFD32F2F); // Error messages (Red)

  // Button Colors
  static const Color buttonPrimary = primaryGold;
  static const Color buttonSecondary = primaryBlack;
  static const Color buttonSuccess = Color(0xFF2E7D32); // Rich green
  static const Color buttonError = Color(0xFFD32F2F);
  static const Color buttonWarning = Color(0xFFFFC107); // Goldish yellow

  // Background Colors
  static const Color backgroundDark = Color(
    0xFF1C1C1C,
  ); // Deep black for dark mode
  static const Color backgroundLight = Color(0xFFF9F9F9); // Softer white
  static const Color backgroundGray = secondaryGray;
  static const Color backgroundSuccess = Color(0xFFE8F5E9);
  static const Color backgroundError = Color(0xFFFFEBEE);
  static const Color backgroundWarning = Color(0xFFFFF8E1);
  static const Color backgroundInfo = Color(0xFFE3F2FD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Border Colors
  static const Color borderPrimary = Color(0xFFBDBDBD);
  static const Color borderError = Color(0xFFD32F2F);
  static const Color borderSuccess = Color(0xFF4CAF50);

  // Shadow Colors
  static const Color shadowLight = Color(0x80BDBDBD);
  static const Color shadowDark = Color(0x80000000);
}
