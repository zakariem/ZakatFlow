import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _isConnected = await _checkInternetConnection(result);
      _connectionStatusController.add(_isConnected);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          final isConnected = await _checkInternetConnection(results);
          if (_isConnected != isConnected) {
            _isConnected = isConnected;
            _connectionStatusController.add(_isConnected);
            debugPrint('Connectivity changed: $_isConnected');
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
      _isConnected = false;
      _connectionStatusController.add(_isConnected);
    }
  }

  /// Check if device has internet connection
  Future<bool> _checkInternetConnection(dynamic results) async {
    List<ConnectivityResult> connectivityResults;
    
    // Handle both single ConnectivityResult and List<ConnectivityResult>
    if (results is List<ConnectivityResult>) {
      connectivityResults = results;
    } else if (results is ConnectivityResult) {
      connectivityResults = [results];
    } else {
      return false;
    }

    // If no connectivity, return false
    if (connectivityResults.contains(ConnectivityResult.none)) {
      return false;
    }

    // If connected to wifi, mobile, or ethernet, assume internet access
    // Remove the strict internet access check as it can be unreliable
    if (connectivityResults.contains(ConnectivityResult.wifi) || 
        connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.ethernet)) {
      return true;
    }

    return false;
  }

  /// Check connectivity status once
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return await _checkInternetConnection(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      // If connectivity check fails, assume connected to avoid blocking the user
      return true;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}