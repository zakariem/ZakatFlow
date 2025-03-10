import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constant/api_constants.dart' show ApiConstants;

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      User user = User.fromJson(data);
      await _saveUserData(user);
      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<User> register(String email, String password, String fullname) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullname': fullname,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      User user = User.fromJson(data);
      await _saveUserData(user);
      return user;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> _saveUserData(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.userId);
    await prefs.setString('fullname', user.fullname);
    await _secureStorage.write(key: 'token', value: user.token);
  }

  Future<User?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? fullname = prefs.getString('fullname');
    String? token = await _secureStorage.read(key: 'token');

    if (userId != null && fullname != null && token != null) {
      return User(userId: userId, fullname: fullname, token: token);
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('fullname');
  }
}
