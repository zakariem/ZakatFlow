import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../utils/constant/api_constants.dart';

class PaymentService {
  
  Future<http.Response> createPayment(PaymentModel payment, String token) {
    return http.post(
      Uri.parse(ApiConstants.payments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(payment.toJson()),
    );
  }
}