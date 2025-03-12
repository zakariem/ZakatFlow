import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/user_model.dart';
import '../utils/widgets/loader.dart';
import 'auth/login_view.dart';
import 'home/home_view.dart';
import '../services/auth_service.dart';

// Provider for AuthService
final authServiceProvider = Provider((ref) => AuthService());

// FutureProvider for authentication state
final authStateProvider = FutureProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserData();
});

class App extends ConsumerWidget {
  App({super.key});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zakat App',
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: authState.when(
        loading: () => const Loader(),
        error: (error, _) => LoginView(),
        data: (user) => user != null ? HomeView() : LoginView(),
      ),
    );
  }
}
