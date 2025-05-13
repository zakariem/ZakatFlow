import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../services/upload_service.dart';

import 'dart:io'
    if (dart.library.html) 'package:frontend/services/web_file.dart';

class UploadState {
  final bool isUploading;
  final String message;
  final User? updatedUser;

  UploadState({this.isUploading = false, this.message = '', this.updatedUser});
}

class UploadViewModel extends StateNotifier<UploadState> {
  final UploadService _uploadService;
  final FlutterSecureStorage _secureStorage;
  final Ref _ref;
  final ImagePicker _picker = ImagePicker();

  UploadViewModel(this._uploadService, this._secureStorage, this._ref)
    : super(UploadState());

  Future<dynamic> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return kIsWeb ? pickedFile : File(pickedFile.path);
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
      state = UploadState(isUploading: true, message: '');

      final updatedUser = await _uploadService.uploadProfileImage(
        imageFile,
        userId,
        token,
      );

      // Update secure storage
      await _secureStorage.write(
        key: 'user',
        value: jsonEncode(updatedUser.toJson()),
      );

      // Update the global auth state
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      state = UploadState(
        isUploading: false,
        message: 'Upload successful',
        updatedUser: updatedUser,
      );
    } catch (e) {
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
