import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final registerProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, AsyncValue<User?>>((
      ref,
    ) {
      final authService = ref.watch(authServiceProvider);
      return RegisterViewModel(authService);
    });

class RegisterViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  bool isObscure = true;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RegisterViewModel(this._authService) : super(const AsyncValue.data(null));

  void toggleObscure() {
    isObscure = !isObscure;
    state = AsyncValue.data(state.value);
  }

  Future<String?> register(BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (password != confirmPasswordController.text.trim()) {
        throw Exception("Passwords do not match");
      }

      final user = await _authService.register(email, password, fullName);
      state = AsyncValue.data(user);

      return null;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);

      return error.toString();
    }
  }

  void clearError() {
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
