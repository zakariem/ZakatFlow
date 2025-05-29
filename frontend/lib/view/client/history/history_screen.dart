import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/zakat_providers.dart';
import '../../../viewmodels/history_viewmodel.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../utils/theme/app_color.dart';
import '../../../models/history_model.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final String? successMessage;
  final Map<String, dynamic>? donationData;

  const HistoryScreen({super.key, this.successMessage, this.donationData});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _initialized = false;
  bool showDonationAlert = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      resetZakatProviders(ref);
      _fetchHistory();
      _initialized = true;

      // Show success message after build
      if (widget.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }

      // Show donation alert if coming from donation screen
      if (widget.donationData != null) {
        setState(() {
          showDonationAlert = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showDonationSuccessDialog();
          }
        });
      }
    }
  }

  void _showDonationSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: AppColors.backgroundLight,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(
                  'Donation Successful!',
                  style: TextStyle(color: AppColors.primaryGold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Amount',
                  '${widget.donationData!['amount']} ${widget.donationData!['currency'] ?? 'USD'}',
                ),
                _buildInfoRow('Recipient', widget.donationData!['agentName']),
                _buildInfoRow('Account', widget.donationData!['userAccountNo']),
                _buildInfoRow(
                  'Date',
                  DateTime.now().toString().substring(0, 16),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSuccess,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.buttonSuccess),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thank you for your generous donation!',
                          style: TextStyle(color: AppColors.buttonSuccess),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGold,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _fetchHistory() async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token != null) {
      await ref
          .read(historyViewModelProvider)
          .loadHistory(token, HistoryRole.user);
      final error = ref.read(historyViewModelProvider).error;
      if (error != null && mounted) {
        ErrorScanckbar.showSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyVm = ref.watch(historyViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,

        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: historyVm.isLoading ? null : _fetchHistory,
          ),
        ],
      ),

      body:
          historyVm.isLoading
              ? Center(child: Loader())
              : historyVm.history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(historyVm.history),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textGray.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No payment history found',
            style: TextStyle(fontSize: 18, color: AppColors.textGray),
          ),
          SizedBox(height: 8),
          Text(
            'Your donation history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryModel> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final payment = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showPaymentDetails(payment),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accentLightGold,
                        child: Icon(Icons.account_balance, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.agentName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Account: ${payment.userAccountNo}',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${payment.amount} ${payment.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primaryGold,
                            ),
                          ),
                          Text(
                            payment.paidAt.toLocal().toString().substring(
                              0,
                              10,
                            ),
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(payment.paymentMethod),
                        backgroundColor: AppColors.secondaryBeige,
                        labelStyle: TextStyle(color: AppColors.primaryGold),
                      ),
                      Text(
                        'Tap for details',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDetails(HistoryModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Payment Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildDetailRow(
                  'Date',
                  payment.paidAt.toLocal().toString().substring(0, 16),
                ),
                _buildDetailRow(
                  'Amount',
                  '${payment.amount} ${payment.currency}',
                ),
                _buildDetailRow('Recipient', payment.agentName),
                _buildDetailRow('Account', payment.userAccountNo),
                _buildDetailRow('Payment Method', payment.paymentMethod),
                _buildDetailRow('Transaction ID', payment.id),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
