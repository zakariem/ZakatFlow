import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_navigation_provider.dart';

import '../utils/theme/app_color.dart';
import 'admin/dashboard_screen.dart';
import 'admin/payments_screen.dart';
import 'admin/recipients_screen.dart';
import 'admin/reports_screen.dart';
import 'admin/settings_screen.dart';

class AdminMainScreen extends ConsumerWidget {
  const AdminMainScreen({super.key});

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const PaymentsScreen(),
    const RecipientsScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  static final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard, color: AppColors.primaryGold),
      label: 'Dashboard 📊',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.payment, color: AppColors.success),
      label: 'Payments 💰',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.group, color: AppColors.accentDarkGold),
      label: 'Recipients 👥',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment, color: AppColors.warning),
      label: 'Reports 📜',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings, color: AppColors.textGray),
      label: 'Settings ⚙️',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavigationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: _navItems,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.backgroundDark,
        onTap: (index) {
          ref.read(adminNavigationProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
