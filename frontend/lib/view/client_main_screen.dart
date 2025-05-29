import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_navigation_provider.dart';
import '../utils/theme/app_color.dart';
import 'client/calculator/tab_screen.dart';
import 'client/history/history_screen.dart';
import 'client/home/home_screen.dart';
import 'client/profile/profile_screen.dart';

class ClientMainScreen extends ConsumerWidget {
  const ClientMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(clientNavigationProvider);
    final currentIndex = navigationState.index;

    // Create screens list with the history screen potentially having donation data
    final screens = [
      const HomeScreen(),
      const TabScreen(),
      HistoryScreen(donationData: navigationState.donationData),
      const ProfileScreen(),
    ];

    const navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.calculate, size: 28),
        label: 'Calculate',
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

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.buttonPrimary,
        unselectedItemColor: AppColors.textGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: navItems,
        onTap: (index) {
          ref.read(clientNavigationProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
