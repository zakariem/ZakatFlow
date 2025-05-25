import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/client_navigation_provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/payment_provider.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../utils/constant/validation_utils.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../viewmodels/agent_view_model.dart';
import '../../../viewmodels/payment_viewmodel.dart';

class AgentDetailScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentDetailScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends ConsumerState<AgentDetailScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgentDetails();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadAgentDetails() {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    agentViewModel.selectAgent(widget.agentId, authState.user!.token);
  }

  @override
  Widget build(BuildContext context) {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final selectedAgent = agentViewModel.selectedAgent;
    final isLoading = agentViewModel.isLoading;

    // Add payment state listener in build method
    ref.listen<PaymentState>(paymentNotifierProvider, (prev, next) {
      print(
        'Payment state changed: isLoading=${next.isLoading}, error=${next.error}, data=${next.data != null}',
      );
      if (!next.isLoading) {
        if (next.error != null) {
          print('Payment error: ${next.error}');
          ErrorScanckbar.showSnackBar(context, next.error!);
        } else if (next.data != null) {
          // Success - navigate back
          Navigator.pop(context);
          ref.read(clientNavigationProvider.notifier).setIndex(2);
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(agentViewModelProvider)
                .loadAgents(ref.read(authViewModelProvider).user!.token);
          },
        ),
        title: Text(
          'Faahfaahin Hay\'ad',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: Loader())
              : selectedAgent == null
              ? Center(
                child: Text(
                  'Hay\'adka lama helin',
                  style: TextStyle(color: AppColors.textGray, fontSize: 16),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Image Section
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image:
                            selectedAgent.profileImageUrl != null
                                ? DecorationImage(
                                  image: NetworkImage(
                                    selectedAgent.profileImageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                                : null,
                        color:
                            selectedAgent.profileImageUrl == null
                                ? AppColors.accentLightGold
                                : null,
                      ),
                      child:
                          selectedAgent.profileImageUrl == null
                              ? Center(
                                child: Icon(
                                  Icons.business,
                                  size: 80,
                                  color: AppColors.textSecondary,
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                    ),

                    // Agent Details Section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Agent Name
                          Text(
                            selectedAgent.fullName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentLightGold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              selectedAgent.role,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Contact Info
                          _buildInfoCard('Macluumaadka Xiriirka', [
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              selectedAgent.email,
                            ),
                            _buildInfoRow(
                              Icons.phone,
                              'Telefoon',
                              selectedAgent.phoneNumber,
                            ),
                            _buildInfoRow(
                              Icons.location_on,
                              'Cinwaanka',
                              selectedAgent.address,
                            ),
                          ]),
                          const SizedBox(height: 30),

                          // Donate Button with Alert
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _showDonateOptions(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentLightGold,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Deeq u Dir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _showDonateOptions(BuildContext context) {
    final clientNavigator = ref.read(clientNavigationProvider.notifier);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Dooro Ficil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(ctx);
                    clientNavigator.setIndex(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLightGold,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Xisaabi Zakadaada'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('ama'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showDonationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Wax Lee Kusada Qeeso'),
                ),
              ],
            ),
          ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Deeq u Dir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomField(
                    controller: _amountController,
                    hintText: 'Lacagta aad doonayso in aad bixiso geli',
                    labelText: 'Qadarka Lacagta',
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validateNumberField,
                  ),
                  const SizedBox(height: 16),
                  CustomField(
                    controller: _phoneController,
                    hintText: 'Number kaa lacag ta katureysid geli',
                    labelText: 'Lambarka Telefoonka',
                    keyboardType: TextInputType.phone,
                    validator: ValidationUtils.validatePhoneNumber,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _amountController.clear();
                  _phoneController.clear();
                },
                child: Text(
                  'Ka Noqo',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final paymentState = ref.watch(paymentNotifierProvider);
                  return ElevatedButton(
                    onPressed:
                        paymentState.isLoading
                            ? null
                            : () => _handleDonation(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentLightGold,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child:
                        paymentState.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textPrimary,
                                ),
                              ),
                            )
                            : const Text('Bixi'),
                  );
                },
              ),
            ],
          ),
    );
  }

  Future<void> _handleDonation(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    final phoneNumber = _phoneController.text.trim();
    final selectedAgent = ref.read(agentViewModelProvider).selectedAgent;
    final user = ref.read(authViewModelProvider).user;

    if (amount == null || amount <= 0) {
      ErrorScanckbar.showSnackBar(context, 'Fadlan geli qadarka saxda ah');
      return;
    }

    if (selectedAgent == null || user == null) {
      ErrorScanckbar.showSnackBar(
        context,
        'Khalad ayaa dhacay, fadlan isku day mar kale',
      );
      return;
    }

    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);

    try {
      // Optional: Show loading state here if you use a loading indicator
      // Example: setState(() => isLoading = true);

      // Attempt payment
      await paymentNotifier.pay(
        userFullName: user.fullName,
        userAccountNo: phoneNumber,
        agentId: selectedAgent.id,
        agentName: selectedAgent.fullName,
        amount: amount,
      );

      if (!context.mounted) return;

      // Success: close dialogs and navigate
      Navigator.pop(dialogContext); // close payment dialog

      // Clear input fields
      _amountController.clear();
      _phoneController.clear();
    } catch (e) {
      if (!context.mounted) return;

      // Ensure dialogs are closed
      Navigator.pop(dialogContext);

      if (!context.mounted) return;

      print('Payment exception: ${e.toString()}');
      ErrorScanckbar.showSnackBar(
        context,
        'Khalad ayaa dhacay: ${e.toString()}',
      );
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
