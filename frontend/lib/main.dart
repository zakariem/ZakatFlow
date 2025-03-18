import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:frontend/view/admin_main_screen.dart';
import 'package:frontend/view/client_main_screen.dart';
import 'providers/auth_providers.dart';
import 'view/auth/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isAuthChecked = false;

  @override
  void initState() {
    super.initState();
    // Check authentication status on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authViewModelProvider.notifier).checkAuthStatus();
      setState(() => _isAuthChecked = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    if (!_isAuthChecked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoaderPage(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zakat App',
      home:
          authState.user == null
              ? const LoginScreen()
              : authState.isAdmin
              ? const AdminMainScreen()
              : const ClientMainScreen(),
    );
  }
}
