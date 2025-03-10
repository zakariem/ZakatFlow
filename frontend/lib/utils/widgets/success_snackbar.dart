import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_color.dart' show AppColors;

class SuccessSnackbar {
  /// Displays a reusable success snackbar at the top of the screen.
  static void show(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryGold, // Success color
      colorText: AppColors.secondaryWhite,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline, color: AppColors.secondaryWhite),
    );
  }
}
