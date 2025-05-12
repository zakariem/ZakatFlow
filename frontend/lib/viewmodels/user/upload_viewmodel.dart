import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

// Conditional import for File
import 'dart:io'
    if (dart.library.html) 'package:frontend/services/web_file.dart';

import '../../models/user_model.dart';
import '../../services/upload_service.dart';

class UploadState {
  final bool isUploading;
  final String message;
  final User? updatedUser;

  UploadState({this.isUploading = false, this.message = '', this.updatedUser});
}

class UploadViewModel extends StateNotifier<UploadState> {
  UploadViewModel(this._uploadService, this._secureStorage)
    : super(UploadState());

  final UploadService _uploadService;
  final FlutterSecureStorage _secureStorage;
  final ImagePicker _picker = ImagePicker();

  Future<dynamic> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // For web, return XFile directly; for mobile, return File
        if (kIsWeb) {
          return pickedFile;
        } else {
          return File(pickedFile.path);
        }
      }
    } catch (e) {
      state = UploadState(message: 'Error picking image: $e');
    }
    return null;
  }

  Future<void> uploadImage(
    dynamic imageFile,
    String userId,
    String token,
  ) async {
    try {
      state = UploadState(isUploading: true, message: 'Uploading image...');
      // Handle debug print differently for web and mobile
      if (kIsWeb) {
        debugPrint('Uploading image for user: $userId (web platform)');
      } else {
        debugPrint(
          'Uploading image for user: $userId with file path: ${imageFile.path}',
        );
      } // Enhanced debugging

      final updatedUser = await _uploadService.uploadProfileImage(
        imageFile,
        userId,
        token,
      );

      debugPrint('Upload successful: ${updatedUser.toJson()}'); // Debugging

      // Remove old user data from secure storage
      await _secureStorage.delete(key: 'user');

      // Save new user data
      await _secureStorage.write(
        key: 'user',
        value: jsonEncode(updatedUser.toJson()),
      );

      state = UploadState(
        isUploading: false,
        message: 'Upload successful',
        updatedUser: updatedUser,
      );
    } catch (e) {
      debugPrint('Upload error: $e'); // Debugging
      debugPrint(
        'Stack trace: ${StackTrace.current}',
      ); // Add stack trace for better debugging

      // Provide a more user-friendly error message
      String errorMessage = 'Upload failed. Please try again.';
      if (e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('format')) {
        errorMessage = 'Server response error. Please try again later.';
      }

      state = UploadState(isUploading: false, message: errorMessage);
    }
  }

  void clearMessage() {
    state = UploadState(message: '');
  }
}
