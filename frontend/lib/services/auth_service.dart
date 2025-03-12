import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constant/api_constants.dart' show ApiConstants;

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
          User user = User.fromJson(userData);
          debugPrint('User: $user');
          await _saveUserData(user);
          return user;
        }
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unknown error occurred');
    } catch (e, stackTrace) {
      debugPrint("Login Error: $e\nStackTrace: $stackTrace");
      throw Exception("Failed to login. Please try again.");
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
        User user = User.fromJson(userData);
        await _saveUserData(user);
        return user;
      } else {
        throw Exception('Unexpected response structure.');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unknown error occurred');
    }
  }

  Future<void> _saveUserData(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(
      'User: ${user.token} ++++++++++++++++++++++++++++++++++++++++++++++++++',
    );
    await prefs.setString('userId', user.userId);
    await prefs.setString('fullname', user.fullname);
    await _secureStorage.write(key: 'token', value: user.token);
  }

  Future<User?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? fullname = prefs.getString('fullname');
    String? token = await _secureStorage.read(key: 'token');

    if (token != null &&
        !JwtDecoder.isExpired(token) &&
        userId != null &&
        fullname != null) {
      return User(userId: userId, fullname: fullname, token: token);
    }

    await _secureStorage.delete(key: 'token');
    await prefs.remove('userId');
    await prefs.remove('fullname');

    return null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('fullname');
  }
}
