import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';

import '../../providers/auth_providers.dart';
import '../../view/auth/login_screen.dart';
import '../../view/client_main_screen.dart';
import '../../view/agent_main_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // Show loading while user info is being fetched or processed
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: Loader()));
    }

    // Show login screen if user is not authenticated
    if (authState.user == null) {
      return const LoginScreen();
    }

    // Decide destination screen based on role
    final role = authState.user?.role.toLowerCase();
    debugPrint(role);
    
    // Admin users should not reach this point as they are blocked at the service level
    if (role == 'agent') {
      return const AgentMainScreen();
    } else {
      return const ClientMainScreen();
    }
  }
}
