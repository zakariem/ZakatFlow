import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class BaseHttpService {
  
  /// Make HTTP request with connectivity check
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
}