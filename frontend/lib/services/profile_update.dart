import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../utils/constant/api_constants.dart';
import 'dart:convert';
import 'base_http_service.dart';

class ProfileUpdateService {
  final String uploadUrl = ApiConstants.profile;

  Future<User?> updateProfile(
    String fullname,
    String userId,
    String token,
    String email,
  ) async {
    try {
      final response = await BaseHttpService.put(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'_id': userId, 'fullName': fullname, 'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData["data"]);
      } else {
        debugPrint('Failed to update profile: ${response.body}');
        return null;
      }
    } catch (error) {
      debugPrint('Error updating profile: $error');
      return null;
    }
  }
}
