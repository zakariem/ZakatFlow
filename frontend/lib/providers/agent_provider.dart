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

  Future<void> _safeNotifyListeners() async {
    await Future.microtask(() => notifyListeners());
  }

  Future<void> fetchAgents(String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    await _safeNotifyListeners();

    try {
      _agents = await _agentsService.getAgents(token);
      print('AgentProvider: Successfully loaded ${_agents.length} agents');
      _successMessage = "Agents loaded successfully";
    } catch (e) {
      print('AgentProvider: Error loading agents: $e');
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      await _safeNotifyListeners();
    }
  }

  Future<void> fetchAgentById(String id, String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    await _safeNotifyListeners();
    try {
      final agent = await _agentsService.getAgentById(id, token);
      _selectedAgent = agent;
      // Update the agent in the list if it exists
      final index = _agents.indexWhere((a) => a.id == id);
      if (index != -1) {
        _agents[index] = agent;
      }
      _successMessage = "Agent loaded successfully";
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      await _safeNotifyListeners();
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
    await _safeNotifyListeners();
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
      await _safeNotifyListeners();
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
    await _safeNotifyListeners();
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
      await _safeNotifyListeners();
    }
  }

  Future<void> deleteAgent(String id, String token) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    await _safeNotifyListeners();
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
      await _safeNotifyListeners();
    }
  }
}

// Riverpod provider for AgentProvider
final agentProviderNotifierProvider = ChangeNotifierProvider<AgentProvider>((
  ref,
) {
  return AgentProvider(AgentsService());
});
