import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_color.dart' show AppColors;

class ErrorSnackbar {
  /// Displays a reusable error snackbar at the top of the screen.
  static void show(String errorMessage) {
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.TOP,
      // You can adjust these colors to match your design
      backgroundColor: AppColors.accentDarkGold,
      colorText: AppColors.secondaryWhite,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: AppColors.secondaryWhite),
    );
  }
}
