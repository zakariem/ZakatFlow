import 'package:flutter_riverpod/flutter_riverpod.dart';


final adminNavigationProvider = StateNotifierProvider<AdminNavigationNotifier, int>(
  (ref) => AdminNavigationNotifier(),
);


class AdminNavigationNotifier extends StateNotifier<int> {
  AdminNavigationNotifier() : super(0);

  
  void setIndex(int index) => state = index;

  
  void reset() => state = 0;
}
