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
      state = UploadState(isUploading: true, message: 'Uploading...');

      final updatedUser = await _uploadService.uploadProfileImage(
        imageFile,
        userId,
        token,
      );

      // Remove old user data from secure storage
      await _secureStorage.delete(key: 'user');
      await _secureStorage.delete(key: 'token');

      // Save the new user data
      await _secureStorage.write(key: 'token', value: updatedUser.token);
      await _secureStorage.write(
        key: 'user',
        value: jsonEncode(updatedUser.toJson()), // Fix: Convert map to string
      );

      state = UploadState(
        isUploading: false,
        message: 'Upload successful',
        updatedUser: updatedUser,
      );
    } catch (e) {
      state = UploadState(isUploading: false, message: 'Upload error: $e');
    }
  }
}
