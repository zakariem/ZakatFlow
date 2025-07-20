import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/client_navigation_provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/payment_provider.dart';
import '../../../utils/theme/app_color.dart';
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
    final token = ref.read(authViewModelProvider).user?.token;
    if (token != null) {
      ref.read(agentViewModelProvider).selectAgent(widget.agentId, token);
    } else {
      ErrorScanckbar.showSnackBar(
        context,
        'Authentication error. Please login again.',
      );
    }
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
      if (!next.isLoading && next.error != null) {
        print('Payment error: ${next.error}');
        // Don't show error snackbar here as it's handled in _handleDonation
      }
      // Note: Success case is handled in _handleDonation method
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textWhite),
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
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: AppColors.textWhite),
            onPressed: () {
              // Share functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share functionality coming soon!'),
                  backgroundColor: AppColors.primaryGold,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                      strokeWidth: 4.0, // Increased stroke width
                    ),
                    const SizedBox(height: 24), // Increased spacing
                    Text(
                      'Loading agent details...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600, // Slightly bolder
                        fontSize: 18, // Increased font size
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we fetch the information',
                      style: TextStyle(color: AppColors.textGray, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : selectedAgent == null
              ? Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80, // Increased size
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 24), // Increased spacing
                      Text(
                        'Hay\'adka lama helin',
                        style: TextStyle(
                          color: AppColors.textPrimary, // Darker text color
                          fontSize: 22, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16), // Increased spacing
                      Text(
                        'Could not load agent details. Please check your connection and try again.',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32), // Increased spacing
                      ElevatedButton.icon(
                        onPressed: () => _loadAgentDetails(),
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text('Refresh', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.textWhite,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ), // Increased padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Increased radius
                          ),
                          elevation: 4, // Added elevation
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Image Section with Hero Animation
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'agent-${selectedAgent.id}',
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image:
                                    selectedAgent.profileImageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            selectedAgent.profileImageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {
                                            print(
                                              'Error loading image: $exception',
                                            );
                                            return;
                                          },
                                        )
                                        : null,
                                color:
                                    selectedAgent.profileImageUrl == null
                                        ? AppColors.primaryGold.withOpacity(0.8)
                                        : null,
                              ),
                              child:
                                  selectedAgent.profileImageUrl == null
                                      ? Center(
                                        child: Icon(
                                          Icons.business,
                                          size: 80,
                                          color: AppColors.textWhite,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                          // Gradient overlay for better text visibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.8),
                                ],
                                stops: const [0.5, 0.75, 1.0],
                              ),
                            ),
                          ),
                          // Agent name overlay at bottom of image
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAgent.fullName,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 3.0,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        selectedAgent.role,
                                        style: TextStyle(
                                          color: AppColors.textWhite,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            size: 16,
                                            color: AppColors.textWhite,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'La Xaqiijiyay',
                                            style: TextStyle(
                                              color: AppColors.textWhite,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Agent Details Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 12,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 14),
                          // Donate Button with Gradient
                          Container(
                            width: double.infinity,
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  AppColors.accentLightGold,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _showDonateOptions(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.textWhite,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: AppColors.textWhite,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ku Deeq',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textWhite,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
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
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Dooro Ficil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(ctx);
                        clientNavigator.setIndex(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLightGold,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xisaabi Zakadaada',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ama',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showDonationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Wax Lee Kusada Qeeso',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: AppColors.primaryGold,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Deeq u Dir',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Description text
                            Text(
                              'Fadlan geli qadarka aad doonayso iyo lambarka telefoonka aad lacagta ka bixinayso.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomField(
                              controller: _amountController,
                              hintText:
                                  'Lacagta aad doonayso in aad bixiso geli',
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
                            const SizedBox(height: 16),
                            // Note about test payment
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderPrimary,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Waxaa la qaadi doonaa \$0.01 oo ah lacag tijaabo ah, kadibna qadarka dhabta ah ee aad gelisay.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Actions Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _amountController.clear();
                              _phoneController.clear();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Ka Noqo',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final paymentState = ref.watch(
                                paymentNotifierProvider,
                              );
                              return ElevatedButton(
                                onPressed:
                                    paymentState.isLoading
                                        ? null
                                        : () => _handleDonation(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  foregroundColor: AppColors.textWhite,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    paymentState.isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Bixi',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      // Attempt payment with test amount ($0.01)
      await paymentNotifier.pay(
        userFullName: user.fullName,
        userAccountNo: phoneNumber,
        agentId: selectedAgent.id,
        agentName: selectedAgent.fullName,
        amount: 0.01,
        actualZakatAmount: amount,
      );

      // Check the payment state after the payment attempt
      final paymentState = ref.read(paymentNotifierProvider);

      if (!context.mounted) return;

      // Close the donation dialog first
      Navigator.pop(dialogContext);

      // Clear input fields
      _amountController.clear();
      _phoneController.clear();

      if (paymentState.error != null) {
        // Payment failed or was cancelled
        print('Payment failed: ${paymentState.error}');

        if (!context.mounted) return;

        // Show error message and stay on agent details screen
        ErrorScanckbar.showSnackBar(
          context,
          paymentState.error!.contains('joojisay')
              ? paymentState.error!
              : 'Khalad ayaa dhacay: ${paymentState.error}',
        );
        return; // Exit early on payment failure
      }

      // Payment was successful
      if (!context.mounted) return;

      // Create donation data to pass to history screen with actual zakat amount
      final donationData = {
        'userFullName': user.fullName,
        'userAccountNo': phoneNumber,
        'agentId': selectedAgent.id,
        'agentName': selectedAgent.fullName,
        'amount': 0.01,
        'actualZakatAmount': amount,
        'currency': 'USD',
      };

      // Success: navigate back and show success message
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Lacag bixinta waa la howlgaliyay. Waxaa la qaadayaa \$0.01 oo tijaabo ah iyo \$${amount.toStringAsFixed(2)} oo ah qadarka dhabta ah.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(8),
        ),
      );

      // Navigate to history tab with donation data
      ref
          .read(clientNavigationProvider.notifier)
          .setIndex(2, donationData: donationData);
    } catch (e) {
      // Handle any unexpected exceptions
      print('Payment exception: ${e.toString()}');

      if (!context.mounted) return;

      // Close the donation dialog
      Navigator.pop(dialogContext);

      // Clear input fields
      _amountController.clear();
      _phoneController.clear();

      if (!context.mounted) return;

      // Show error message and stay on agent details screen
      ErrorScanckbar.showSnackBar(
        context,
        'Khalad ayaa dhacay: ${e.toString()}',
      );
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Increased radius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10, // Increased blur
            spreadRadius: 1, // Added spread
            offset: const Offset(0, 4), // Adjusted offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20, // Increased font size
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5, // Added letter spacing
            ),
          ),
          const SizedBox(height: 16), // Increased spacing
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Added padding around icon
            decoration: BoxDecoration(
              color: AppColors.backgroundLight, // Added background color
              borderRadius: BorderRadius.circular(8), // Added border radius
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGold,
              size: 22,
            ), // Changed color and increased size
          ),
          const SizedBox(width: 16), // Increased spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15, // Increased font size
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3, // Added letter spacing
                  ),
                ),
                const SizedBox(height: 4), // Increased spacing
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17, // Increased font size
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3, // Added line height
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
