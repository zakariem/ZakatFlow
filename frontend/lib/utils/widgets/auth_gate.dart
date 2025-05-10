import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../view/admin_main_screen.dart';
import '../../view/auth/login_screen.dart';
import '../../view/client_main_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.user == null) {
      return const LoginScreen();
    } else if (authState.isAdmin) {
      return const AdminMainScreen();
    } else {
      return const ClientMainScreen();
    }
  }
}
