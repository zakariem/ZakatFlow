import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../models/agent_model.dart';
import '../services/dashboard_service.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final List<HistoryModel> payments;
  final List<Agent> agents;
  final Map<String, dynamic> analytics;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.payments = const [],
    this.agents = const [],
    this.analytics = const {},
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    List<HistoryModel>? payments,
    List<Agent>? agents,
    Map<String, dynamic>? analytics,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      payments: payments ?? this.payments,
      agents: agents ?? this.agents,
      analytics: analytics ?? this.analytics,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _service;
  final String token;

  DashboardNotifier(this._service, this.token) : super(DashboardState());

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load payments and agents concurrently
      final results = await Future.wait([
        _service.getAllPayments(token),
        _service.getAllAgents(token),
      ]);

      final payments = results[0] as List<HistoryModel>;
      final agents = results[1] as List<Agent>;

      // Calculate analytics
      final analytics = _service.calculatePaymentAnalytics(payments);

      state = state.copyWith(
        isLoading: false,
        payments: payments,
        agents: agents,
        analytics: analytics,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}

// Provider
final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardProvider =
    StateNotifierProvider.family<DashboardNotifier, DashboardState, String>(
      (ref, token) =>
          DashboardNotifier(ref.watch(dashboardServiceProvider), token),
    );
