import 'package:flutter/material.dart';
import '../../services/base_http_service.dart';

/// Widget to handle and display different types of errors
class ErrorHandler {
  /// Show appropriate error message based on error type
  static void showError(BuildContext context, dynamic error) {
    String message;
    
    if (error is UnauthorizedException) {
      // For 401 errors, show a brief message since user is being logged out
      message = 'Session expired. Redirecting to login...';
    } else if (error is NetworkException) {
      message = error.toString();
    } else {
      message = 'An unexpected error occurred';
    }
    
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error is UnauthorizedException 
              ? Colors.orange 
              : Colors.red,
          duration: Duration(
            seconds: error is UnauthorizedException ? 2 : 4,
          ),
        ),
      );
    }
  }
}