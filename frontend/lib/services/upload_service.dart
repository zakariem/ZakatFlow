import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../models/user_model.dart';
import '../utils/constant/api_constants.dart';

class UploadService {
  final String uploadUrl = ApiConstants.upload;

  Future<User> uploadProfileImage(
    File imageFile,
    String userId,
    String token,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    request.headers['userId'] = userId;
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageFile.readAsBytesSync(),
        filename: path.basename(imageFile.path),
      ),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(responseData);
        return User.fromJson(jsonData['data']);
      } catch (e) {
        throw Exception('Invalid response format: $responseData');
      }
    } else {
      throw Exception(
        'Failed to upload image: ${response.statusCode} - $responseData',
      );
    }
  }
}
