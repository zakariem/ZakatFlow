import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../view/home/home_view.dart';

final authServiceProvider = Provider((ref) => AuthService());

final loginProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, AsyncValue<User?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return LoginViewModel(authService);
    });

class LoginViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  bool isObscure = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginViewModel(this._authService) : super(const AsyncValue.data(null));

  void toggleObscure() {
    isObscure = !isObscure;

    state = AsyncValue.data(state.value);
  }

  Future<void> login(BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.login(
        emailController.text,
        passwordController.text,
      );
      state = AsyncValue.data(user);
      debugPrint('User: $user nigaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      if (!context.mounted) return;
      debugPrint('User: $user');
      Navigator.pushReplacement(context, HomeView.route());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearError() {
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
