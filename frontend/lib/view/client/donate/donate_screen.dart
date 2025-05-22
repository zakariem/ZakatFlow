import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/constant/validation_utils.dart';
import 'package:frontend/utils/widgets/custom/custom_field.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/client_navigation_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../viewmodels/agent_view_model.dart';
import '../../../viewmodels/payment_viewmodel.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key, required this.amount});
  final double amount;

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  String? selectedAgentId;
  late TextEditingController _phoneController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _handleSubmit() async {
    final phoneNumber = _phoneController.text.trim();
    if (selectedAgentId == null || phoneNumber.isEmpty) {
      ErrorScanckbar.showSnackBar(context, 'Dooro Hay\'ada');
      return;
    }

    final agent = ref
        .read(agentViewModelProvider)
        .agents
        .firstWhere((a) => a.id == selectedAgentId);
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);

    await paymentNotifier.pay(
      userFullName: ref.read(authViewModelProvider).user!.fullName,
      userAccountNo: phoneNumber,
      agentId: agent.id,
      agentName: agent.fullName,
      amount: widget.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final agentVm = ref.watch(agentViewModelProvider);
    final paymentState = ref.watch(paymentNotifierProvider);

    if (!_initialized || agentVm.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: Loader()),
      );
    }

    ref.listen<PaymentState>(paymentNotifierProvider, (prev, next) {
      if (!next.isLoading) {
        if (next.error != null) {
          ErrorScanckbar.showSnackBar(context, next.error!);
        } else if (next.data != null) {
          // Navigate to HistoryScreen with success message
          Navigator.of(context).pop();
          ref.read(clientNavigationProvider.notifier).setIndex(2);
        }
      }
    });

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
                itemCount: agentVm.agents.length,
                itemBuilder: (context, index) {
                  final agent = agentVm.agents[index];
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
                      trailing: Radio<String>(
                        value: agent.id,
                        groupValue: selectedAgentId,
                        onChanged: (value) {
                          setState(() {
                            selectedAgentId = value;
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
            CustomField(
              hintText: 'Number kaa lacag ta katureysid geli',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: ValidationUtils.validatePhoneNumber,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: paymentState.isLoading ? null : _handleSubmit,
                child:
                    paymentState.isLoading
                        ? Loader() // You can customize this Loader
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.payment, color: AppColors.primaryGold),
                            SizedBox(width: 8),
                            Text('Bixid'),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
