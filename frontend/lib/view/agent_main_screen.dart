import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:frontend/utils/widgets/snackbar/success_snackbar.dart';
import '../providers/auth_providers.dart';
import '../providers/history_provider.dart';
import '../utils/theme/app_color.dart';
import '../viewmodels/agent_view_model.dart';
import '../viewmodels/history_viewmodel.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    final historyVm = ref.read(historyViewModelProvider);
    final user = authState.user;

    if (user == null) return;

    // Load agent
    await agentViewModel.selectAgent(user.id, user.token);

    if (!mounted) return;

    if (agentViewModel.error != null) {
      ErrorScanckbar.showSnackBar(context, agentViewModel.error!);
    } else if (agentViewModel.successMessage != null) {
      SuccessSnackbar.showSnackBar(context, agentViewModel.successMessage!);
    }
    await agentViewModel.clearMessages();

    // Load payment history
    await historyVm.loadHistory(user.token, HistoryRole.agent);
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: agent?.profileImageUrl != null
                ? NetworkImage(agent!.profileImageUrl!)
                : null,
            child: agent?.profileImageUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
        ),
        title: Text(
          agent?.fullName ?? 'Agent',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await ref.read(authViewModelProvider.notifier).logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ErrorScanckbar.showSnackBar(context, 'Logout failed: $e');
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: Loader())
          : agent == null
              ? const Center(child: Text("Hay'ad lama helin"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAgentDonationCard(agent.totalDonation ?? 0),
                        const SizedBox(height: 32),
                        const DividerWithText("Dadka lacag noo soo direen"),
                        const SizedBox(height: 16),
                        _buildPaymentHistory(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAgentDonationCard(double totalDonation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primaryGold,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              "\$$totalDonation USD",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final historyVm = ref.watch(historyViewModelProvider);

    if (historyVm.isLoading) return const Center(child: Loader());

    if (historyVm.error != null) {
      return Center(
        child: Text("Error: ${historyVm.error}", style: const TextStyle(color: Colors.red)),
      );
    }

    if (historyVm.history.isEmpty) {
      return const Center(
        child: Text("No payments found.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historyVm.history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payment = historyVm.history[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.person, color: AppColors.primaryGold),
            title: Text(payment.userFullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account: ${payment.userAccountNo}"),
                Text("Amount: ${payment.amount} ${payment.currency}"),
                Text("Date: ${payment.paidAt.toLocal()}"),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 18),
                Text(payment.paymentMethod, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
