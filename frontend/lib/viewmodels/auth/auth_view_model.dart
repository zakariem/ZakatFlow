import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  AuthViewModel(this._authService, this._secureStorage)
    : super(const AuthState());

  Future<void> login(String email, String password) async {
    await _handleAuth(() async => await _authService.login(email, password));
  }

  Future<void> register(String email, String password, String fullname) async {
    await _handleAuth(
      () async => await _authService.register(email, password, fullname),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _clearUserData();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      final userJson = await _secureStorage.read(key: 'user');

      if (token != null && token.isNotEmpty && userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleAuth(Future<User> Function() authMethod) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await authMethod();
      await _storeUserData(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _storeUserData(User user) async {
    await _secureStorage.write(key: 'token', value: user.token);
    await _secureStorage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<void> _clearUserData() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'user');
  }

  void _handleError(dynamic error) {
    state = state.copyWith(error: error.toString(), isLoading: false);
  }
}
