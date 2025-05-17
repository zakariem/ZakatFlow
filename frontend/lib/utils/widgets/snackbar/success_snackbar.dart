import 'package:flutter/material.dart';

import '../../theme/app_color.dart';

class SuccessSnackbar extends StatelessWidget {
  const SuccessSnackbar({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16.0),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    if (messenger.mounted) {
      messenger.hideCurrentSnackBar();
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }
}
