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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.secondaryBeige.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.primaryGold.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: currentIndex,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: AppColors.textGray.withOpacity(0.6),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: navItems.asMap().entries.map((entry) {
              int index = entry.key;
              BottomNavigationBarItem item = entry.value;
              bool isSelected = currentIndex == index;
              
              return BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryGold.withOpacity(0.2),
                              AppColors.accentLightGold.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGold.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: item.icon,
                  ),
                ),
                label: item.label,
              );
            }).toList(),
            onTap: (index) {
              ref.read(clientNavigationProvider.notifier).setIndex(index);
            },
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
