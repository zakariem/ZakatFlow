import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_navigation_provider.dart';
import '../utils/theme/app_color.dart';
import 'admin/dashboard_screen.dart';
import 'admin/payments_screen.dart';
import 'admin/agent/agents_screen.dart';
import 'admin/settings_screen.dart';

class AdminMainScreen extends ConsumerWidget {
  const AdminMainScreen({super.key, required this.token});
  
  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavigationProvider);

    // Screens list built dynamically due to the use of `token`
    final List<Widget> screens = [
      const DashboardScreen(),
      PaymentsScreen(token: token),
      const AgentsScreen(),
      const SettingsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard, size: 28),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.payment, size: 28),
        label: 'Payments',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group, size: 28),
        label: 'Hay\'adaha',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings, size: 28),
        label: 'Settings',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: navItems,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.backgroundLight,
        onTap: (index) {
          ref.read(adminNavigationProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
