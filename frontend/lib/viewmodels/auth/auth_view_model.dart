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
  final bool isAdminError;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error = '',
    this.isAdmin = false,
    this.isAdminError = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAdmin,
    bool? isAdminError,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? this.isAdmin,
      isAdminError: isAdminError ?? this.isAdminError,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  AuthViewModel(this._authService, this._secureStorage)
    : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      // Clear any existing user data first to ensure we're starting fresh
      await _clearUserData();

      // Now attempt to login with the provided credentials
      final user = await _authService.login(email, password);

      // If we get here, login was successful, so store the user data
      await _storeUserData(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    await _handleAuth(() => _authService.register(email, password, fullName));
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _clearUserData();
      // Reset the state completely but don't trigger additional rebuilds
      // until we're completely done with the logout process
      state = const AuthState(); // Use const for immutable state
      print('User logged out successfully');
    } catch (e) {
      _handleError(e);
    } finally {
      // Set loading to false as the final state update
      state = state.copyWith(isLoading: false);
    }
    // Note: Navigation should be handled by the UI component, not here
  }

  Future<void> deleteAccount() async {
    final currentUser = state.user;
    if (currentUser == null) {
      _handleError(Exception('User not authenticated'));
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      await _authService.deleteAccount(
        currentUser.id,
        currentUser.token,
        currentUser.role,
      );
      await logout();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete account: $e');
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final userJson = await _secureStorage.read(key: 'user');
      if (userJson == null) {
        state = state.copyWith(user: null, isAdmin: false);
        return;
      }

      final user = User.fromJson(jsonDecode(userJson));
      final token = user.token;

      if (JwtDecoder.isExpired(token)) {
        await logout();
      } else {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to check authentication status');
    }
  }

  Future<void> _handleAuth(Future<User> Function() authMethod) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      // Clear any existing user data first
      await _clearUserData();

      final user = await authMethod();
      await _storeUserData(user);
      state = state.copyWith(user: user);
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _storeUserData(User user) async {
    await _secureStorage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<void> _clearUserData() async {
    await _secureStorage.delete(key: 'user');
  }

  void _handleError(dynamic error) {
    String errorMessage;
    bool isAdminError = false;

    if (error is AdminNotAllowedException) {
      errorMessage = error.toString();
      isAdminError = true;
    } else if (error is Exception) {
      errorMessage = error.toString();
    } else {
      errorMessage = 'An unexpected error occurred';
    }

    state = state.copyWith(
      error: errorMessage,
      isLoading: false,
      isAdminError: isAdminError,
    );
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user);
    await _storeUserData(user);
  }
}
