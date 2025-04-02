import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientNavigationProvider = StateNotifierProvider<NavigationNotifier, int>(
  (ref) => NavigationNotifier(),
);

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) => state = index;
  void reset() => state = 0;
}
