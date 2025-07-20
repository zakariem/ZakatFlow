import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'providers/auth_providers.dart';
import 'providers/connectivity_provider.dart';
import 'utils/widgets/auth_gate.dart';
import 'utils/widgets/connectivity_banner.dart';
import 'utils/theme/app_color.dart';

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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGold,
            brightness: Brightness.light,
            primary: AppColors.primaryGold,
            secondary: AppColors.accentLightGold,
            surface: AppColors.backgroundLight,
            background: AppColors.backgroundLight,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.backgroundLight,
        ),
        home: const LoaderPage(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zakat App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGold,
          brightness: Brightness.light,
          primary: AppColors.primaryGold,
          secondary: AppColors.accentLightGold,
          surface: AppColors.backgroundLight,
          background: AppColors.backgroundLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.textWhite,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          titleLarge: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      home: _isAuthChecked 
          ? const ConnectivityWrapper(child: AuthGate()) 
          : const LoaderPage(),
    );
  }
}
