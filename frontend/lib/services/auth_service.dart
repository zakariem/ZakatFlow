import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constant/api_constants.dart' show ApiConstants;

class AdminNotAllowedException implements Exception {
  final String message;
  AdminNotAllowedException(this.message);
  
  @override
  String toString() => message;
}

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
          final user = User.fromJson(responseData["data"]);
          
          // Check if user is admin and prevent login
          if (user.role.toLowerCase() == 'admin') {
            throw AdminNotAllowedException('Admin users must use the web dashboard at zakatflow.com/dashboard');
          }
          
          return user;
        }
        throw Exception('Invalid response structure from server.');
      }

      throw _handleErrorResponse(response);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          final user = User.fromJson(responseData["data"]);
          
          // Check if user is admin and prevent registration
          if (user.role.toLowerCase() == 'admin') {
            throw AdminNotAllowedException('Admin users must use the web dashboard at zakatflow.com/dashboard');
          }
          
          return user;
        }
        throw Exception('Unexpected response structure.');
      }

      throw _handleErrorResponse(response);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(String? userId, String token, String role) async {
    print(token);
    if (userId == null || userId.isEmpty || token.isEmpty) {
      throw Exception('User data is incomplete for account deletion.');
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'_id': userId, 'role': role}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  Exception _handleErrorResponse(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? response.reasonPhrase;
        return Exception(errorMessage ?? 'Unknown error occurred.');
      }
      return Exception(response.reasonPhrase ?? 'Unknown error occurred.');
    } catch (e) {
      return Exception('Error processing server response: ${e.toString()}');
    }
  }
}
