import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../models/agent_model.dart';
import '../utils/constant/api_constants.dart';

// Conditional import for File
import 'dart:io'
    if (dart.library.html) 'package:frontend/services/web_file.dart';

import 'package:image_picker/image_picker.dart';

class AgentsService {
  Future<List<Agent>> getAgents(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.agents),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => Agent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load agents');
    }
  }

  Future<Agent> getAgentById(String id, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.agents}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Agent.fromJson(data['data']);
    } else {
      throw Exception('Failed to load agent');
    }
  }

  Future<Agent> createAgent(
    Map<String, String> agentData,
    dynamic imageFile, // File (mobile) or XFile (web)
    String token,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.agents));
    debugPrint("${token}_________________________");
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(agentData);

    if (imageFile != null) {
      _addImageToRequest(request, imageFile);
    }

    final response = await _sendMultipartRequest(request);
    return Agent.fromJson(response['data']);
  }

  Future<Agent> updateAgent(
    String id,
    Map<String, String> agentData,
    dynamic imageFile, // File (mobile) or XFile (web)
    String token,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConstants.agents}/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(agentData);

    if (imageFile != null) {
      _addImageToRequest(request, imageFile);
    }

    final response = await _sendMultipartRequest(request);
    return Agent.fromJson(response['data']);
  }

  Future<void> deleteAgent(String id, String token) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.agents}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete agent');
    }
  }

  /// Adds the image to the multipart request depending on the platform.
  void _addImageToRequest(
    http.MultipartRequest request,
    dynamic imageFile,
  ) async {
    if (kIsWeb) {
      if (imageFile is XFile) {
        final bytes = await imageFile.readAsBytes();
        final filename = path.basename(imageFile.name);
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: filename),
        );
      } else {
        throw Exception('Unsupported file type for web');
      }
    } else {
      if (imageFile is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: path.basename(imageFile.path),
          ),
        );
      } else {
        throw Exception('Unsupported file type for mobile');
      }
    }
  }

  /// Sends the request and parses the response.
  Future<Map<String, dynamic>> _sendMultipartRequest(
    http.MultipartRequest request,
  ) async {
    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['data'] != null) {
          return data;
        } else {
          throw Exception('Missing data in response: $responseBody');
        }
      } else {
        throw Exception(
          'Failed request: ${streamedResponse.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
}
