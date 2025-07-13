import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'providers/auth_providers.dart';
import 'providers/connectivity_provider.dart';
import 'utils/widgets/auth_gate.dart';
import 'utils/widgets/connectivity_banner.dart';

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
    // Initialize connectivity service and check authentication status on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize connectivity monitoring
      final connectivityService = ref.read(connectivityServiceProvider);
      await connectivityService.initialize();
      
      // Check authentication status
      await ref.read(authViewModelProvider.notifier).checkAuthStatus();
      setState(() => _isAuthChecked = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthChecked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoaderPage(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zakat App',
      home: _isAuthChecked 
          ? const ConnectivityWrapper(child: AuthGate()) 
          : const LoaderPage(),
    );
  }
}
