import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../utils/constant/api_constants.dart';
import 'base_http_service.dart';

class PaymentService {
  Future<http.Response> createPayment(
    PaymentModel payment,
    String token,
  ) async {
    // First, process the payment with the actual amount
    final response = await BaseHttpService.post(
      Uri.parse(ApiConstants.payments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payment.toJson()),
    );

    return response;
  }

  Future<http.Response> getAllPayments(String token) {
    return BaseHttpService.get(
      Uri.parse(ApiConstants.payments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> getUserPayments(String token) {
    return BaseHttpService.get(
      Uri.parse('${ApiConstants.payments}/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> getAgentPayments(String token) {
    return BaseHttpService.get(
      Uri.parse('${ApiConstants.payments}/agent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
