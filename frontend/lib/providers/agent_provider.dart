import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/agent_model.dart';
import '../services/agents_service.dart';

class AgentProvider extends ChangeNotifier {
  final AgentsService _agentsService;

  AgentProvider(this._agentsService);

  List<Agent> _agents = [];
  Agent? _selectedAgent;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<Agent> get agents => _agents;
  Agent? get selectedAgent => _selectedAgent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> fetchAgents(String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      _agents = await _agentsService.getAgents(token);
      _successMessage = "Agents loaded successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAgentById(String id, String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      _selectedAgent = await _agentsService.getAgentById(id, token);
      _successMessage = "Agent loaded successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAgent(
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      final newAgent = await _agentsService.createAgent(
        agentData,
        imageFile,
        token,
      );
      _agents.add(newAgent);
      _successMessage = "Agent created successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAgent(
    String id,
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      final updated = await _agentsService.updateAgent(
        id,
        agentData,
        imageFile,
        token,
      );
      final index = _agents.indexWhere((a) => a.id == id);
      if (index != -1) {
        _agents[index] = updated;
      }
      if (_selectedAgent?.id == id) {
        _selectedAgent = updated;
      }
      _successMessage = "Agent updated successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAgent(String id, String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _agentsService.deleteAgent(id, token);
      _agents.removeWhere((a) => a.id == id);
      if (_selectedAgent?.id == id) {
        _selectedAgent = null;
      }
      _successMessage = "Agent deleted successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Riverpod provider for AgentProvider
final agentProviderNotifierProvider = ChangeNotifierProvider<AgentProvider>((
  ref,
) {
  return AgentProvider(AgentsService());
});
