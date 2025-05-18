import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import '../providers/auth_providers.dart';
import '../utils/theme/app_color.dart';
import '../utils/widgets/snackbar/success_snackbar.dart';
import '../viewmodels/agent_view_model.dart';
import 'auth/login_screen.dart';

class AgentMainScreen extends ConsumerStatefulWidget {
  const AgentMainScreen({super.key});

  @override
  ConsumerState<AgentMainScreen> createState() => _AgentMainScreenState();
}

class _AgentMainScreenState extends ConsumerState<AgentMainScreen> {
  @override
  void initState() {
    super.initState();
    _fetchAgent();
  }

  Future<void> _fetchAgent() async {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    final user = authState.user;
    if (user == null) return;

    await agentViewModel.selectAgent(user.id, user.token);

    if (!mounted) return; // Exit early if widget is disposed

    final error = agentViewModel.error;
    final success = agentViewModel.successMessage;

    if (error != null) {
      ErrorScanckbar.showSnackBar(context, error);
      await agentViewModel.clearMessages();
    } else if (success != null) {
      SuccessSnackbar.showSnackBar(context, success);
      await agentViewModel.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final agent = agentViewModel.selectedAgent;
    final isLoading = agentViewModel.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading:
            agent?.profileImageUrl != null
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(agent!.profileImageUrl!),
                  ),
                )
                : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(child: Icon(Icons.person)),
                ),
        title: Text(
          agent?.fullName ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchAgent,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await ref.read(authViewModelProvider.notifier).logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } catch (error) {
                if (!mounted) return;
                ErrorScanckbar.showSnackBar(context, 'Logout failed: $error');
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: Loader())
              : agent == null
              ? const Center(child: Text('Hay\'ad mala helin'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Total Donations",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "\$${agent.totalDonation ?? 0} USD",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Dadka lacag noo soo direen",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        "Not found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
