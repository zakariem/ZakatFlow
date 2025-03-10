import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGold = Color(
    0xFFC1914D,
  ); // Gold for highlights and branding
  static const Color primaryBlack = Color(
    0xFF000000,
  ); // Deep black for backgrounds

  // Secondary Colors
  static const Color secondaryWhite = Color(
    0xFFFFFFFF,
  ); // White for text and clean spaces
  static const Color secondaryGray = Color(
    0xFFF2F2F2,
  ); // Light gray for subtle contrasts
  static const Color secondaryBeige = Color(
    0xFFF9F5F0,
  ); // Soft beige for a warm feel

  // Accent Colors
  static const Color accentDarkGold = Color(
    0xFF8D6E3C,
  ); // Darker shade for depth
  static const Color accentLightGold = Color(
    0xFFFFD700,
  ); // Lighter gold for highlights

  // Text Colors
  static const Color textPrimary = primaryBlack;
  static const Color textSecondary = primaryGold;
  static const Color textWhite = secondaryWhite;
  static const Color textGray = Color(0xFFB0B0B0); // Muted text color
  static const Color textError = Color(0xFFD32F2F); // Error text color (Red)

  // Button Colors
  static const Color buttonGold = primaryGold;
  static const Color buttonBlack = primaryBlack;
  static const Color buttonSuccess = Color(
    0xFF4CAF50,
  ); // Green button for success
  static const Color buttonError = Color(0xFFD32F2F); // Red button for error
  static const Color buttonWarning = Color(
    0xFFFFC107,
  ); // Yellow button for warning

  // Background Colors
  static const Color backgroundDark = primaryBlack;
  static const Color backgroundLight = secondaryWhite;
  static const Color backgroundGray = secondaryGray;
  static const Color backgroundSuccess = Color(
    0x00e1e8f6,
  ); // Light background for success
  static const Color backgroundError = Color(
    0xFFFEF1F1,
  ); // Light background for error
  static const Color backgroundWarning = Color(
    0xFFFFF8E1,
  ); // Light background for warning
  static const Color backgroundInfo = Color(
    0xFFE3F2FD,
  ); // Light background for info

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Success color (Green)
  static const Color error = Color(0xFFD32F2F); // Error color (Red)
  static const Color warning = Color(0xFFFFC107); // Warning color (Yellow)
  static const Color info = Color(0xFF2196F3); // Info color (Blue)

  // Border Colors
  static const Color borderPrimary = Color(
    0xFFBDBDBD,
  ); // Border for primary elements
  static const Color borderError = Color(0xFFD32F2F); // Border color for error
  static const Color borderSuccess = Color(
    0xFF4CAF50,
  ); // Border color for success

  // Shadow Colors
  static const Color shadowLight = Color(
    0x80BDBDBD,
  ); // Light shadow for UI depth
  static const Color shadowDark = Color(0x80000000); // Dark shadow for UI depth
}
