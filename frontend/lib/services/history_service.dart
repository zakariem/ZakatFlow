import 'dart:convert';
import '../models/history_model.dart';
import 'base_http_service.dart';

class HistoryService {
  final String baseUrl;
  HistoryService({required this.baseUrl});

  Future<List<HistoryModel>> fetchUserHistory(String token) async {
    final response = await BaseHttpService.get(
      Uri.parse('$baseUrl/api/payments/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      print('${response.statusCode} ${response.body}');
      throw Exception('Failed to load user payment history ${response.body}');
    }
  }

  Future<List<HistoryModel>> fetchAgentHistory(String token) async {
    final response = await BaseHttpService.get(
      Uri.parse('$baseUrl/api/payments/agent'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load agent payment history');
    }
  }

  Future<List<HistoryModel>> fetchAdminHistory(String token) async {
    final response = await BaseHttpService.get(
      Uri.parse('$baseUrl/api/payments'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load admin payment history ${response.body}');
    }
  }
}
