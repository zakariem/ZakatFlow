import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

// State
class PaymentState {
  final bool isLoading;
  final String? error;
  final dynamic data;

  PaymentState({this.isLoading = false, this.error, this.data});

  PaymentState copyWith({bool? isLoading, String? error, dynamic data}) =>
      PaymentState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        data: data ?? this.data,
      );
}

// ViewModel as StateNotifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _service;
  final String token;

  PaymentNotifier(this._service, this.token) : super(PaymentState());

  Future<void> pay({
    required String userFullName,
    required String userAccountNo,
    required String agentId,
    required String agentName,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payment = PaymentModel(
        userFullName: userFullName,
        userAccountNo: userAccountNo,
        agentId: agentId,
        agentName: agentName,
        amount: amount,
      );
      final response = await _service.createPayment(payment, token);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: response.body);
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              responseBody['message'] == 'RCS_USER_REJECTED'
                  ? 'Waad joojisay lacag bixin mar labad is ku day'
                  : '${responseBody['message']}',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
