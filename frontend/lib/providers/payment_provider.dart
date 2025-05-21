import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import '../services/payment_service.dart';
import '../viewmodels/payment_viewmodel.dart';

// Configure base URL
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// Assume you have an authProvider that gives userId
final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
      final service = ref.read(paymentServiceProvider);
      final token = ref.read(authViewModelProvider).user!.token;
      return PaymentNotifier(service, token);
    });
