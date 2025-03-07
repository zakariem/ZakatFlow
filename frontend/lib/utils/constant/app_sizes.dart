import 'package:flutter/material.dart';

class AppSizes {
  // These values will be initialized once at the start of the app.
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;

  /// Call this method in your main widget's build method to initialize screen dimensions.
  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }

  // Font Sizes based on screen height for consistency across devices
  static double get fontSmall => screenHeight * 0.02; // 2% of screen height
  static double get fontMedium => screenHeight * 0.025; // 2.5% of screen height
  static double get fontLarge => screenHeight * 0.03; // 3% of screen height

  // Padding and Margin Values
  static double get horizontalPadding =>
      screenWidth * 0.05; // 5% of screen width
  static double get verticalPadding =>
      screenHeight * 0.02; // 2% of screen height

  // Button Dimensions
  static double get buttonHeight => screenHeight * 0.07; // 7% of screen height
  static double get buttonWidth => screenWidth * 0.8; // 80% of screen width

  // Icon Sizes
  static double get iconSmall => screenHeight * 0.03;
  static double get iconMedium => screenHeight * 0.04;
  static double get iconLarge => screenHeight * 0.05;
}
