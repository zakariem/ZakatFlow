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

    request.fields['userId'] = userId;
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseData);
      return User.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
