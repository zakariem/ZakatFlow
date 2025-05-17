import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/agent_view_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import 'agent_form_screen.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../utils/widgets/snackbar/success_snackbar.dart';

class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = ref.read(authViewModelProvider).user?.token;
      if (token != null) {
        await ref.read(agentViewModelProvider).loadAgents(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final agentViewModel = ref.watch(agentViewModelProvider);

    // Show error/success snackbar after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (agentViewModel.error != null && agentViewModel.error!.isNotEmpty) {
        ErrorScanckbar.showSnackBar(context, agentViewModel.error!);
        ref.read(agentViewModelProvider).clearMessages();
      } else if (agentViewModel.successMessage != null && agentViewModel.successMessage!.isNotEmpty) {
        SuccessSnackbar.showSnackBar(context, agentViewModel.successMessage!);
        ref.read(agentViewModelProvider).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Agents'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textWhite,
        elevation: 2,
      ),
      body: _buildBody(agentViewModel),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textWhite,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AgentFormScreen()),
          );
        },
        tooltip: 'Add Agent',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(AgentViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: Loader());
    }

    if (viewModel.agents.isEmpty) {
      return Center(
        child: Text(
          'No agents found.',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.agents.length,
      itemBuilder: (context, index) {
        final agent = viewModel.agents[index];
        return Card(
          color: AppColors.secondaryBeige,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading:
                agent.profileImageUrl != null
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(agent.profileImageUrl!),
                    )
                    : CircleAvatar(
                      backgroundColor: AppColors.accentLightGold,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
            title: Text(
              agent.fullName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              agent.email,
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
        );
      },
    );
  }
}
