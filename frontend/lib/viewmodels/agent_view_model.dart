import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/agent_model.dart';
import '../providers/agent_provider.dart';

class AgentViewModel {
  final AgentProvider agentProvider;

  AgentViewModel(this.agentProvider);

  List<Agent> get agents => agentProvider.agents;
  Agent? get selectedAgent => agentProvider.selectedAgent;
  bool get isLoading => agentProvider.isLoading;
  String? get error => agentProvider.error;
  String? get successMessage => agentProvider.successMessage;

  Future<void> clearMessages() async {
    await Future.microtask(() => agentProvider.clearMessages());
  }

  Future<void> loadAgents(String token) async {
    await agentProvider.fetchAgents(token);
  }

  Future<void> selectAgent(String id, String token) async {
    await agentProvider.fetchAgentById(id, token);
  }

  Future<void> addAgent(
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    await agentProvider.createAgent(agentData, imageFile, token);
  }

  Future<void> editAgent(
    String id,
    Map<String, String> agentData,
    XFile? imageFile,
    String token,
  ) async {
    await agentProvider.updateAgent(id, agentData, imageFile, token);
  }

  Future<void> removeAgent(String id, String token) async {
    await agentProvider.deleteAgent(id, token);
  }
}

final agentViewModelProvider = Provider<AgentViewModel>((ref) {
  final agentProvider = ref.watch(agentProviderNotifierProvider);
  return AgentViewModel(agentProvider);
});