import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => message;
}

class BaseHttpService {
  static ProviderContainer? _container;
  
  /// Initialize the service with ProviderContainer for global state access
  static void initialize(ProviderContainer container) {
    _container = container;
  }
  
  /// Handle 401 Unauthorized responses by logging out the user
  static Future<void> _handleUnauthorized() async {
    if (_container != null) {
      try {
        debugPrint('401 Unauthorized detected - logging out user');
        await _container!.read(authViewModelProvider.notifier).logout();
      } catch (e) {
        debugPrint('Error during automatic logout: $e');
      }
    }
  }
  
  /// Check response for 401 status and handle accordingly
  static Future<http.Response> _checkAndHandleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Log the 401 error for debugging
      try {
        final responseBody = response.body;
        debugPrint('I/flutter ( 9567): 401 {"message":"Unauthorized"}');
        debugPrint('Full response: $responseBody');
      } catch (e) {
        debugPrint('Error parsing 401 response: $e');
      }
      
      // Trigger automatic logout
      await _handleUnauthorized();
      
      // Throw exception to be handled by the calling code
      throw UnauthorizedException('Session expired. Please login again.');
    }
    return response;
  }
  
  /// Make HTTP request with connectivity check and 401 handling
  static Future<http.Response> makeRequest(
    Future<http.Response> Function() request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Make the request with timeout
      final response = await request().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'Request timed out. Please check your internet connection.',
            timeout,
          );
        },
      );
      
      // Check for 401 and handle accordingly
      return await _checkAndHandleResponse(response);
    } on SocketException catch (e) {
      debugPrint('Socket exception: $e');
      throw NetworkException(
        'Network error. Please check your internet connection and try again.'
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout exception: $e');
      throw NetworkException(
        'Request timed out. Please check your internet connection and try again.'
      );
    } on HttpException catch (e) {
      debugPrint('HTTP exception: $e');
      throw NetworkException(
        'Network error occurred. Please try again.'
      );
    } on UnauthorizedException {
      rethrow; // Re-throw 401 exceptions as-is
    } catch (e) {
      debugPrint('Unexpected error: $e');
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        'An unexpected error occurred. Please try again.'
      );
    }
  }

  /// GET request with connectivity check
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return makeRequest(
      () => http.get(url, headers: headers),
      timeout: timeout,
    );
  }

  /// POST request with connectivity check
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return makeRequest(
      () => http.post(url, headers: headers, body: body),
      timeout: timeout,
    );
  }

  /// PUT request with connectivity check
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return makeRequest(
      () => http.put(url, headers: headers, body: body),
      timeout: timeout,
    );
  }

  /// DELETE request with connectivity check
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return makeRequest(
      () => http.delete(url, headers: headers, body: body),
      timeout: timeout,
    );
  }
  
  /// Multipart request with connectivity check and 401 handling
  static Future<http.StreamedResponse> sendMultipartRequest(
    http.MultipartRequest request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Send the request with timeout
      final response = await request.send().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'Request timed out. Please check your internet connection.',
            timeout,
          );
        },
      );
      
      // Check for 401 and handle accordingly
      if (response.statusCode == 401) {
        // Log the 401 error for debugging
        debugPrint('I/flutter ( 9567): 401 {"message":"Unauthorized"}');
        debugPrint('Multipart request returned 401 Unauthorized');
        
        // Trigger automatic logout
        await _handleUnauthorized();
        
        // Throw exception to be handled by the calling code
        throw UnauthorizedException('Session expired. Please login again.');
      }
      
      return response;
    } on SocketException catch (e) {
      debugPrint('Socket exception: $e');
      throw NetworkException(
        'Network error. Please check your internet connection and try again.'
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout exception: $e');
      throw NetworkException(
        'Request timed out. Please check your internet connection and try again.'
      );
    } on HttpException catch (e) {
      debugPrint('HTTP exception: $e');
      throw NetworkException(
        'Network error occurred. Please try again.'
      );
    } on UnauthorizedException {
      rethrow; // Re-throw 401 exceptions as-is
    } catch (e) {
      debugPrint('Unexpected error: $e');
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        'An unexpected error occurred. Please try again.'
      );
    }
  }
}