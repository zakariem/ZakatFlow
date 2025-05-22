import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/history_service.dart';

enum HistoryRole { user, agent, admin }

class HistoryViewModel extends ChangeNotifier {
  final HistoryService service;
  List<HistoryModel> history = [];
  bool isLoading = false;
  String? error;

  HistoryViewModel({required this.service});

  Future<void> loadHistory(String token, HistoryRole role) async {
    isLoading = true;
    error = null;
    Future.microtask(() => notifyListeners());
    try {
      List<HistoryModel> result;
      switch (role) {
        case HistoryRole.user:
          result = await service.fetchUserHistory(token);
          break;
        case HistoryRole.agent:
          result = await service.fetchAgentHistory(token);
          break;
        case HistoryRole.admin:
          result = await service.fetchAdminHistory(token);
          break;
      }
      history = result;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
}
