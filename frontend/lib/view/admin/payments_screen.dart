import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/payment_service.dart';
import '../../utils/theme/app_color.dart';
import '../../viewmodels/payment_viewmodel.dart';

// Provider for admin payments
final adminPaymentsProvider = StateNotifierProvider.family<PaymentNotifier, PaymentState, String>(
  (ref, token) => PaymentNotifier(PaymentService(), token),
);

class PaymentsScreen extends ConsumerStatefulWidget {
  final String token;
  
  const PaymentsScreen({super.key, required this.token});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPaymentsProvider(widget.token).notifier).getAllPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(adminPaymentsProvider(widget.token));
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Payment Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminPaymentsProvider(widget.token).notifier).getAllPayments();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(paymentState.data),
          _buildFilterSection(),
          Expanded(
            child: _buildPaymentsList(paymentState),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(dynamic payments) {
    if (payments == null || payments is! List) {
      return const SizedBox.shrink();
    }

    final totalPayments = payments.length;
    final totalAmount = payments.fold<double>(
      0.0,
      (sum, payment) => sum + (payment['amount']?.toDouble() ?? 0.0),
    );
    final todayPayments = payments.where((payment) {
      final paidAt = DateTime.tryParse(payment['paidAt'] ?? '');
      if (paidAt == null) return false;
      final today = DateTime.now();
      return paidAt.year == today.year &&
          paidAt.month == today.month &&
          paidAt.day == today.day;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Payments',
              totalPayments.toString(),
              Icons.payment,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Amount',
              '\$${totalAmount.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Today',
              todayPayments.toString(),
              Icons.today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[600],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(PaymentState paymentState) {
    if (paymentState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (paymentState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${paymentState.error}',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(adminPaymentsProvider(widget.token).notifier).getAllPayments();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final payments = paymentState.data;
    if (payments == null || payments is! List || payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payments will appear here once users make donations',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredPayments = _filterPayments(payments);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  List<dynamic> _filterPayments(List<dynamic> payments) {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'Today':
        return payments.where((payment) {
          final paidAt = DateTime.tryParse(payment['paidAt'] ?? '');
          if (paidAt == null) return false;
          return paidAt.year == now.year &&
              paidAt.month == now.month &&
              paidAt.day == now.day;
        }).toList();
      
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return payments.where((payment) {
          final paidAt = DateTime.tryParse(payment['paidAt'] ?? '');
          if (paidAt == null) return false;
          return paidAt.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
      
      case 'This Month':
        return payments.where((payment) {
          final paidAt = DateTime.tryParse(payment['paidAt'] ?? '');
          if (paidAt == null) return false;
          return paidAt.year == now.year && paidAt.month == now.month;
        }).toList();
      
      default:
        return payments;
    }
  }

  Widget _buildPaymentCard(dynamic payment) {
    final paidAt = DateTime.tryParse(payment['paidAt'] ?? '');
    final amount = payment['amount']?.toDouble() ?? 0.0;
    final currency = payment['currency'] ?? 'USD';
    final userFullName = payment['userFullName'] ?? 'Unknown';
    final agentName = payment['agentName'] ?? 'Unknown';
    final userAccountNo = payment['userAccountNo'] ?? '';
    final paymentMethod = payment['paymentMethod'] ?? 'mwallet_account';
    final waafiResponse = payment['waafiResponse'] ?? {};
    final transactionId = waafiResponse['transactionId'] ?? 'N/A';
    final state = waafiResponse['state'] ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currency ${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        paidAt != null
                            ? DateFormat('MMM dd, yyyy • hh:mm a').format(paidAt)
                            : 'Date not available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: state == 'APPROVED' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: state == 'APPROVED' ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Payer', userFullName, Icons.person),
                ),
                Expanded(
                  child: _buildInfoItem('Agent', agentName, Icons.support_agent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Phone', userAccountNo, Icons.phone),
                ),
                Expanded(
                  child: _buildInfoItem('Method', paymentMethod, Icons.credit_card),
                ),
              ],
            ),
            if (transactionId != 'N/A') ...[
              const SizedBox(height: 12),
              _buildInfoItem('Transaction ID', transactionId, Icons.receipt_long),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
