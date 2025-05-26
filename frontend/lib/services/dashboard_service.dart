import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import '../models/agent_model.dart';
import '../utils/constant/api_constants.dart';

class DashboardService {
  Future<List<HistoryModel>> getAllPayments(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.payments),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load payments: ${response.body}');
    }
  }

  Future<List<Agent>> getAllAgents(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.agents),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => Agent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load agents: ${response.body}');
    }
  }

  // Analytics methods
  Map<String, dynamic> calculatePaymentAnalytics(List<HistoryModel> payments) {
    if (payments.isEmpty) {
      return {
        'totalPayments': 0,
        'totalAmount': 0.0,
        'todayPayments': 0,
        'todayAmount': 0.0,
        'weeklyPayments': 0,
        'weeklyAmount': 0.0,
        'monthlyPayments': 0,
        'monthlyAmount': 0.0,
        'paymentsByMethod': <String, int>{},
        'dailyPayments': <String, double>{},
        'topAgents': <Map<String, dynamic>>[],
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    double totalAmount = 0;
    int todayPayments = 0;
    double todayAmount = 0;
    int weeklyPayments = 0;
    double weeklyAmount = 0;
    int monthlyPayments = 0;
    double monthlyAmount = 0;

    Map<String, int> paymentsByMethod = {};
    Map<String, double> dailyPayments = {};
    Map<String, double> agentTotals = {};
    Map<String, int> agentCounts = {};

    for (var payment in payments) {
      totalAmount += payment.amount;

      // Today's payments
      if (payment.paidAt.isAfter(today)) {
        todayPayments++;
        todayAmount += payment.amount;
      }

      // Weekly payments
      if (payment.paidAt.isAfter(weekAgo)) {
        weeklyPayments++;
        weeklyAmount += payment.amount;
      }

      // Monthly payments
      if (payment.paidAt.isAfter(monthAgo)) {
        monthlyPayments++;
        monthlyAmount += payment.amount;
      }

      // Payment methods
      paymentsByMethod[payment.paymentMethod] =
          (paymentsByMethod[payment.paymentMethod] ?? 0) + 1;

      // Daily payments for chart
      final dayKey = '${payment.paidAt.day}/${payment.paidAt.month}';
      dailyPayments[dayKey] = (dailyPayments[dayKey] ?? 0) + payment.amount;

      // Agent analytics
      agentTotals[payment.agentName] =
          (agentTotals[payment.agentName] ?? 0) + payment.amount;
      agentCounts[payment.agentName] =
          (agentCounts[payment.agentName] ?? 0) + 1;
    }

    // Top agents
    final topAgents =
        agentTotals.entries
            .map(
              (e) => {
                'name': e.key,
                'amount': e.value,
                'count': agentCounts[e.key] ?? 0,
              },
            )
            .toList()
          ..sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
          )
          ..take(5).toList();

    return {
      'totalPayments': payments.length,
      'totalAmount': totalAmount,
      'todayPayments': todayPayments,
      'todayAmount': todayAmount,
      'weeklyPayments': weeklyPayments,
      'weeklyAmount': weeklyAmount,
      'monthlyPayments': monthlyPayments,
      'monthlyAmount': monthlyAmount,
      'paymentsByMethod': paymentsByMethod,
      'dailyPayments': dailyPayments,
      'topAgents': topAgents,
    };
  }
}
