import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// Conditional imports
import '../models/user_model.dart';
import '../utils/constant/api_constants.dart';
import 'base_http_service.dart';

// Import dart:io only for non-web platforms
import 'dart:io'
    if (dart.library.html) 'package:frontend/services/web_file.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final String uploadUrl = ApiConstants.upload;

  Future<User> uploadProfileImage(
    dynamic imageFile,
    String userId,
    String token,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Set the correct headers
    request.headers['userId'] = userId;
    request.headers['Authorization'] = 'Bearer $token';
    // Don't remove Content-Type, let MultipartRequest handle it

    // Handle file upload differently based on platform
    if (kIsWeb) {
      // For web platform
      if (imageFile is XFile) {
        final bytes = await imageFile.readAsBytes();
        final filename = path.basename(imageFile.name);

        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: filename),
        );
      } else {
        throw Exception('Unsupported file type for web upload');
      }
    } else {
      // For mobile platforms
      if (imageFile is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: path.basename(imageFile.path),
          ),
        );
      } else {
        throw Exception('Unsupported file type for mobile upload');
      }
    }

    try {
      final response = await BaseHttpService.sendMultipartRequest(request);
      final responseData = await response.stream.bytesToString();

      print('Upload response: $responseData'); // Debug the response

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(responseData);
          if (jsonData['data'] != null) {
            return User.fromJson(jsonData['data']);
          } else {
            throw Exception('Missing data in response: $responseData');
          }
        } catch (e) {
          throw Exception('Invalid response format: $responseData');
        }
      } else {
        throw Exception(
          'Failed to upload image: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      print('Exception during upload: $e');
      rethrow;
    }
  }
}
