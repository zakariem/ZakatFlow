import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constant/api_constants.dart' show ApiConstants;

class AuthService {
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          final Map<String, dynamic> userData = responseData["data"];
          return User.fromJson(userData);
        }
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User> register(String email, String password, String fullname) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullname,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey("data")) {
        final Map<String, dynamic> userData = responseData["data"];
        return User.fromJson(userData);
      } else {
        throw Exception('Unexpected response structure.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unknown error occurred');
    }
  }
}
