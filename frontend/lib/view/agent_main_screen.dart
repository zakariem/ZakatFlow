import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage:
                agent?.profileImageUrl != null
                    ? NetworkImage(agent!.profileImageUrl!)
                    : null,
            child:
                agent?.profileImageUrl == null
                    ? const Icon(Icons.person)
                    : null,
          ),
        ),
        title: Text(
          agent?.fullName ?? 'Agent Dashboard',
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
      body:
          isLoading
              ? const Center(child: Loader())
              : agent == null
              ? const Center(child: Text("Hay'ad lama helin"))
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildChartsSection(),
                      const SizedBox(height: 24),
                      _buildFilterSection(),
                      const SizedBox(height: 16),
                      _buildPaymentHistory(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSummaryCards() {
    final historyVm = ref.watch(historyViewModelProvider);
    final payments = historyVm.history;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final totalPayments = payments.length;
    final totalAmount = payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
    final todayPayments =
        payments.where((payment) {
          final today = DateTime.now();
          return payment.paidAt.year == today.year &&
              payment.paidAt.month == today.month &&
              payment.paidAt.day == today.day;
        }).length;
    final todayAmount = payments
        .where((payment) {
          final today = DateTime.now();
          return payment.paidAt.year == today.year &&
              payment.paidAt.month == today.month &&
              payment.paidAt.day == today.day;
        })
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Payments',
              totalPayments.toString(),
              Icons.payment,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Total Amount',
              formatter.format(totalAmount),
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Today\'s Payments',
              todayPayments.toString(),
              Icons.today,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Today\'s Amount',
              formatter.format(todayAmount),
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPaymentMethodChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildDailyPaymentsChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodChart() {
    final historyVm = ref.watch(historyViewModelProvider);
    final payments = historyVm.history;

    if (payments.isEmpty) {
      return _buildEmptyChart('Payment Methods');
    }

    final paymentsByMethod = <String, int>{};
    for (final payment in payments) {
      paymentsByMethod[payment.paymentMethod] =
          (paymentsByMethod[payment.paymentMethod] ?? 0) + 1;
    }

    final sections =
        paymentsByMethod.entries.map((entry) {
          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.red,
          ];
          final index = paymentsByMethod.keys.toList().indexOf(entry.key);
          final color = colors[index % colors.length];

          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Container(
      height: 200,
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
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPaymentsChart() {
    final historyVm = ref.watch(historyViewModelProvider);
    final payments = historyVm.history;

    if (payments.isEmpty) {
      return _buildEmptyChart('Daily Payments');
    }

    final dailyPayments = <String, double>{};
    for (final payment in payments) {
      final dateKey = DateFormat('MM/dd').format(payment.paidAt);
      dailyPayments[dateKey] = (dailyPayments[dateKey] ?? 0) + payment.amount;
    }

    final spots =
        dailyPayments.entries.toList().asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.value);
        }).toList();

    return Container(
      height: 200,
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
        children: [
          const Text(
            'Daily Payments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      height: 200,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('No data available', style: TextStyle(color: Colors.grey[600])),
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
                children:
                    _filterOptions.map((filter) {
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

  Widget _buildPaymentHistory() {
    final historyVm = ref.watch(historyViewModelProvider);

    if (historyVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyVm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${historyVm.error}',
              style: TextStyle(color: Colors.red[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (historyVm.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
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
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredPayments = _filterPayments(historyVm.history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = filteredPayments[index];
            return _buildPaymentCard(payment);
          },
        ),
      ],
    );
  }

  List<dynamic> _filterPayments(List<dynamic> payments) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Today':
        return payments.where((payment) {
          return payment.paidAt.year == now.year &&
              payment.paidAt.month == now.month &&
              payment.paidAt.day == now.day;
        }).toList();

      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return payments.where((payment) {
          return payment.paidAt.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          );
        }).toList();

      case 'This Month':
        return payments.where((payment) {
          return payment.paidAt.year == now.year &&
              payment.paidAt.month == now.month;
        }).toList();

      default:
        return payments;
    }
  }

  Widget _buildPaymentCard(dynamic payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(payment.paidAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'APPROVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Payer',
                    payment.userFullName,
                    Icons.person,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Phone',
                    payment.userAccountNo,
                    Icons.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              'Payment Method',
              payment.paymentMethod,
              Icons.credit_card,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
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
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
