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
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home 🏠'),
    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculate 🧮'),
    BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Donate 💳'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History 📜'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile 👤'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(clientNavigationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryBlack,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textGray,
        items: _navItems,
        onTap: (index) {
          ref.read(clientNavigationProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
