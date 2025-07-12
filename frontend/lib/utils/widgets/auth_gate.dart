import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_providers.dart';
import '../../view/auth/login_screen.dart';
import '../../view/client_main_screen.dart';
import '../../view/agent_main_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  Future<void> _showAdminAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Access'),
          content: const Text(
            'You have admin privileges. Please use our web dashboard for admin functions.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Dashboard'),
              onPressed: () async {
                final url = Uri.parse('https://zakatflow.com/dashboard');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
    
    if (role == 'admin') {
      // Show admin alert and redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAdminAlert(context);
      });
      return const LoginScreen();
    } else if (role == 'agent') {
      return const AgentMainScreen();
    } else {
      return const ClientMainScreen();
    }
  }
}
