import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      state = UploadState(message: 'Error picking image: $e');
    }
    return null;
  }

  Future<void> uploadImage(File imageFile, String userId, String token) async {
    try {
      state = UploadState(isUploading: true);
      debugPrint('Uploading image for user: $userId'); // Debugging

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

      state = UploadState(isUploading: false, message: 'Upload error: $e');
    }
  }

  void clearMessage() {
    state = UploadState(message: '');
  }
}
