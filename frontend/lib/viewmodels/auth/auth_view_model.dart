import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String error;
  final bool isAdmin;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error = '',
    this.isAdmin = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAdmin,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? user?.isAdmin ?? this.isAdmin,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  AuthViewModel(this._authService, this._secureStorage)
    : super(const AuthState());

  Future<void> login(String email, String password) async {
    await _handleAuth(() => _authService.login(email, password));
  }

  Future<void> register(String email, String password, String fullName) async {
    await _handleAuth(() => _authService.register(email, password, fullName));
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _clearUserData();
      state = state.copyWith(user: null, isLoading: false, isAdmin: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final userJson = await _secureStorage.read(key: 'user');

      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        final token = user.token; // Extract token from user object

        if (JwtDecoder.isExpired(token)) {
          await logout(); // Token expired, log out user
        } else {
          state = state.copyWith(user: user, isAdmin: user.isAdmin);
        }
      }
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _handleAuth(Future<User> Function() authMethod) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final user = await authMethod();
      await _storeUserData(user);
      state = state.copyWith(user: user, isAdmin: user.isAdmin);
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _storeUserData(User user) async {
    final updatedUser = User(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      token: user.token,
      profileImageUrl: user.profileImageUrl,
    );

    await _secureStorage.write(
      key: 'user',
      value: jsonEncode(updatedUser.toJson()),
    );
    debugPrint(
      "User data stored successfully ${jsonEncode(updatedUser.toJson())}",
    );
  }

  Future<void> _clearUserData() async {
    await _secureStorage.delete(key: 'user');
  }

  void _handleError(dynamic error) {
    state = state.copyWith(error: error.toString(), isLoading: false);
  }
}
