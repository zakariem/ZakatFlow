import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/providers/auth_providers.dart';

import '../../models/user_model.dart';
import '../../services/profile_update.dart';

class UpdateState {
  final bool isUploading;
  final String message;
  final User? updatedUser;

  UpdateState({this.isUploading = false, this.message = '', this.updatedUser});
}

class ProfileUpdateViewmodel extends StateNotifier<UpdateState> {
  ProfileUpdateViewmodel(this._profileUpdateService, this._secureStorage)
    : super(UpdateState());

  final ProfileUpdateService _profileUpdateService;
  final FlutterSecureStorage _secureStorage;

  Future<void> updateProfile(
    String fullName,
    String email,
    String userId,
    String token,
    BuildContext context,
  ) async {
    state = UpdateState(isUploading: true);
    try {
      final updatedUser = await _profileUpdateService.updateProfile(
        fullName,
        userId,
        token,
        email,
      );

      if (updatedUser != null) {
        await _secureStorage.delete(key: 'user');
        await _secureStorage.write(
          key: 'user',
          value: jsonEncode(updatedUser.toJson()),
        );
        // Update the global auth state with the new user data
        if (!context.mounted) return;
        final container = ProviderScope.containerOf(context, listen: false);
        final authViewModel = container.read(authViewModelProvider.notifier);
        authViewModel.updateUser(updatedUser);
        state = UpdateState(updatedUser: updatedUser);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        state = UpdateState(message: 'Failed to update profile.');
      }
    } catch (e) {
      state = UpdateState(message: 'Error updating profile: $e');
    }
  }

  void clearMessage() {
    state = UpdateState(message: '');
  }
}
