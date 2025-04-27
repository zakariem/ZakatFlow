import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/calculator_tab_service.dart';
import 'package:frontend/viewmodels/zakat/calculator_tab_viewmodel.dart';

final tabServiceProvider = Provider<CalculatorTabService>((ref) {
  return CalculatorTabService();
});

final tabViewModelProvider = Provider<CalculatorTabViewmodel>((ref) {
  final service = ref.read(tabServiceProvider);
  return CalculatorTabViewmodel(service);
});

final tabIndexProvider = StateProvider<int>((ref) => 0);
