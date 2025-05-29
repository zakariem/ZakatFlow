import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int index;
  final Map<String, dynamic>? donationData;

  NavigationState({required this.index, this.donationData});
}

final clientNavigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
      (ref) => NavigationNotifier(),
    );

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(index: 0));

  void setIndex(int index, {Map<String, dynamic>? donationData}) =>
      state = NavigationState(index: index, donationData: donationData);

  void reset() => state = NavigationState(index: 0);
}
