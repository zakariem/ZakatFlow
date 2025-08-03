import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/agent_model.dart';
import '../utils/constant/api_constants.dart';
import 'base_http_service.dart';

class AgentsService {
  Future<List<Agent>> getAgents(String token) async {
    try {
      debugPrint('AgentsService: Fetching agents from ${ApiConstants.agents}');
      debugPrint('AgentsService: Platform - ${kIsWeb ? "Web" : "Mobile"}');

      final response = await BaseHttpService.get(
        Uri.parse(ApiConstants.agents),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        timeout: const Duration(seconds: 15),
      );

      debugPrint('AgentsService: Response status: ${response.statusCode}');
      debugPrint('AgentsService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final agents =
            (data['data'] as List).map((e) => Agent.fromJson(e)).toList();
        debugPrint(
          'AgentsService: Successfully fetched ${agents.length} agents',
        );
        return agents;
      } else {
        debugPrint(
          'AgentsService: Error response: ${response.statusCode} - ${response.body}',
        );
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('AgentsService: Exception occurred: $e');
      rethrow;
    }
  }

  Future<Agent> getAgentById(String id, String token) async {
    try {
      debugPrint('AgentsService: Fetching agent by ID: $id');
      debugPrint('AgentsService: Platform - ${kIsWeb ? "Web" : "Mobile"}');

      final response = await BaseHttpService.get(
        Uri.parse('${ApiConstants.agents}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        timeout: const Duration(seconds: 15),
      );

      debugPrint('AgentsService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'AgentsService: Successfully fetched agent: ${data['data']['fullName']}',
        );
        return Agent.fromJson(data['data']);
      } else {
        debugPrint(
          'AgentsService: Error response: ${response.statusCode} - ${response.body}',
        );
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('AgentsService: Exception occurred: $e');
      rethrow;
    }
  }

  Future<Agent> createAgent(
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.agents),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Add all form fields
    agentData.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image if exists
    if (imageFile != null) {
      await _addImageToRequest(request, imageFile);
    }

    return _sendAgentRequest(request);
  }

  Future<Agent> updateAgent(
    String id,
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConstants.agents}/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Add all form fields
    agentData.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image if exists
    if (imageFile != null) {
      await _addImageToRequest(request, imageFile);
    }

    return _sendAgentRequest(request);
  }

  Future<void> deleteAgent(String id, String token) async {
    final response = await BaseHttpService.delete(
      Uri.parse('${ApiConstants.agents}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> _addImageToRequest(
    http.MultipartRequest request,
    XFile imageFile,
  ) async {
    final bytes = await imageFile.readAsBytes();
    final mimeType = lookupMimeType(imageFile.name) ?? 'image/jpeg';
    final extension = mimeType.split('/')[1];

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
        contentType: MediaType('image', extension),
      ),
    );
  }

  Future<Agent> _sendAgentRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Agent.fromJson(data['data']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Failed to process request: $e');
    }
  }

  Exception _handleError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;
    final platform = kIsWeb ? "Web" : "Mobile";

    debugPrint(
      'AgentsService: Error handling - Platform: $platform, Status: $statusCode',
    );
    debugPrint('AgentsService: Error body: $body');

    if (statusCode == 403) {
      return Exception(
        'You are not authorized to perform this action. Platform: $platform',
      );
    } else if (statusCode == 400) {
      try {
        final error = jsonDecode(body)['message'];
        return Exception('${error ?? "Invalid request"} (Platform: $platform)');
      } catch (e) {
        return Exception(
          'Invalid request - Unable to parse error response (Platform: $platform)',
        );
      }
    } else if (statusCode == 401) {
      return Exception(
        'Authentication failed. Please login again. (Platform: $platform)',
      );
    } else if (statusCode >= 500) {
      return Exception(
        'Server error occurred. Please try again later. (Platform: $platform)',
      );
    } else {
      return Exception(
        'Request failed with status: $statusCode (Platform: $platform)',
      );
    }
  }
}
