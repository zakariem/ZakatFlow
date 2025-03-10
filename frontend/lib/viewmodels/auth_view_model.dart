import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService);
});

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  // Added variables for UI state management:
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isObscure = true;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthViewModel(this._authService) : super(const AsyncValue.data(null));

  // Toggles the obscure state of the password field and forces a rebuild.
  void toggleObscure() {
    isObscure = !isObscure;
    // If the current state is AsyncData, reassigning forces UI update.
    if (state is AsyncData) {
      state = AsyncData(state.value);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register(String email, String password, String fullname) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.register(email, password, fullname);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.getUserData();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
