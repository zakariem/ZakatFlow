import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../providers/auth_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../utils/widgets/snackbar/success_snackbar.dart';
import '../../../viewmodels/agent_view_model.dart';
import 'agent_form_screen.dart';

class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token != null) {
      await ref.read(agentViewModelProvider).loadAgents(token);
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
    await _handleMessages();
  }

  Future<void> _handleMessages() async {
    final viewModel = ref.read(agentViewModelProvider);
    if (!mounted) return;

    await Future.delayed(Duration.zero); // Wait for context to be ready

    if (viewModel.error != null && viewModel.error!.isNotEmpty) {
      ErrorScanckbar.showSnackBar(context, viewModel.error!);
      viewModel.clearMessages();
    } else if (viewModel.successMessage != null &&
        viewModel.successMessage!.isNotEmpty) {
      SuccessSnackbar.showSnackBar(context, viewModel.successMessage!);
      viewModel.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(agentViewModelProvider);

    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: Loader()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Hay\'adaha'),
        backgroundColor: AppColors.textWhite,
        elevation: 2,
      ),
      body: _buildBody(viewModel),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textWhite,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgentFormScreen()),
          );
        },
        tooltip: 'Kusoo dar hay\'ad',
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
          'Hay\'ado lama helin',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initialize,
      child: ListView.builder(
        itemCount: viewModel.agents.length,
        itemBuilder: (context, index) {
          final agent = viewModel.agents[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            child: Slidable(
              key: ValueKey(agent.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      final token = ref.read(authViewModelProvider).user?.token;
                      if (token != null) {
                        await ref
                            .read(agentViewModelProvider)
                            .removeAgent(agent.id, token);
                        if (mounted) {
                          await _handleMessages();
                        }
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Tirtir',
                    borderRadius: BorderRadius.circular(7),
                  ),
                ],
              ),
              child: Card(
                color: AppColors.secondaryBeige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ListTile(
                  leading:
                      agent.profileImageUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              agent.profileImageUrl!,
                            ),
                          )
                          : CircleAvatar(
                            backgroundColor: AppColors.accentLightGold,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgentFormScreen(agent: agent),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
