import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import '../../../viewmodels/agent_view_model.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  String? selectedAgentId;
  String phoneNumber = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token != null) {
      await ref.read(agentViewModelProvider).loadAgents(token);
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  void _handleSubmit() {
    final viewModel = ref.read(agentViewModelProvider);
    final selectedAgent = viewModel.agents.firstWhere(
      (a) => a.id == selectedAgentId,
      orElse: () => viewModel.agents.first,
    );

    if (phoneNumber.isNotEmpty) {
      print('Selected Agent: ${selectedAgent.fullName}');
      print('Phone Number: $phoneNumber');
    } else {
      print('No agent selected or phone number is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(agentViewModelProvider);

    if (!_initialized || viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: Loader()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.agents.length,
                itemBuilder: (context, index) {
                  final agent = viewModel.agents[index];
                  final isSelected = selectedAgentId == agent.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color:
                        isSelected
                            ? AppColors.accentLightGold
                            : AppColors.secondaryBeige,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading:
                          agent.profileImageUrl != null
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  agent.profileImageUrl!,
                                ),
                              )
                              : const CircleAvatar(
                                backgroundColor: AppColors.accentLightGold,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                      title: Text(agent.fullName),
                      subtitle: Text(agent.email),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) {
                          setState(() {
                            selectedAgentId = isSelected ? null : agent.id;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedAgentId = isSelected ? null : agent.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter the phone number to pay from',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                phoneNumber = value;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Bixid'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
