import 'package:flutter/material.dart';

import '../../theme/app_color.dart';

class ErrorScanckbar extends StatelessWidget {
  const ErrorScanckbar({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(error, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16.0),
    );
  }
}
