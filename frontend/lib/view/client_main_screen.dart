import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_navigation_provider.dart';
import '../utils/theme/app_color.dart';
import 'client/calculate_screen.dart';
import 'client/donate_screen.dart';
import 'client/history_screen.dart';
import 'client/home_screen.dart';
import 'client/profile_screen.dart';

class ClientMainScreen extends ConsumerWidget {
  const ClientMainScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const CalculateScreen(),
    const DonateScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  static final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.calculate, size: 28),
      label: 'Calculate',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.credit_card, size: 28),
      label: 'Donate',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history, size: 28),
      label: 'History',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person, size: 28),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(clientNavigationProvider);

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.buttonPrimary,
        unselectedItemColor: AppColors.textGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        items: _navItems,
        onTap: (index) {
          ref.read(clientNavigationProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
