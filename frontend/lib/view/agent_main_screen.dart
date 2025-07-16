import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// Main screen for agent users displaying dashboard with payment analytics,
/// summary cards, charts, and payment history with filtering capabilities.
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

  /// Loads agent data and payment history from the server
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
        elevation: 0,
        backgroundColor: AppColors.primaryGold,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGold, AppColors.accentDarkGold],
            ),
          ),
        ),
        title: Row(
          children: [
            // Profile picture on the left
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  agent?.profileImageUrl != null
                      ? NetworkImage(agent!.profileImageUrl!)
                      : null,
              backgroundColor: AppColors.secondaryWhite,
              child:
                  agent?.profileImageUrl == null
                      ? const Icon(
                        Icons.person,
                        color: AppColors.primaryGold,
                        size: 24,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            // Agent name in the center
            Expanded(
              child: Text(
                agent != null ? agent.fullName : 'Agent Dashboard',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              tooltip: 'Refresh',
              onPressed: _loadData,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textWhite),
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
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.secondaryBeige.withOpacity(0.3),
              AppColors.backgroundLight,
            ],
          ),
        ),
        child:
            isLoading
                ? const Center(child: Loader())
                : agent == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 80,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Hay'ad lama helin",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primaryGold,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 32),
                        _buildChartsSection(),
                        const SizedBox(height: 32),
                        _buildFilterSection(),
                        const SizedBox(height: 24),
                        _buildPaymentHistory(),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
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
      (sum, payment) => sum + payment.actualZakatAmount,
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
        .fold<double>(0.0, (sum, payment) => sum + payment.actualZakatAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.2),
                    AppColors.accentLightGold.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '📊 PERFORMANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _buildSummaryCard(
              'Total Payments',
              totalPayments.toString(),
              Icons.payment_rounded,
              [AppColors.info, AppColors.info.withOpacity(0.7)],
              '💳',
            ),
            _buildSummaryCard(
              'Total Amount',
              formatter.format(totalAmount),
              Icons.attach_money_rounded,
              [AppColors.success, AppColors.success.withOpacity(0.7)],
              '💰',
            ),
            _buildSummaryCard(
              'Today\'s Payments',
              todayPayments.toString(),
              Icons.today_rounded,
              [AppColors.warning, AppColors.warning.withOpacity(0.7)],
              '📅',
            ),
            _buildSummaryCard(
              'Today\'s Amount',
              formatter.format(todayAmount),
              Icons.trending_up_rounded,
              [AppColors.primaryGold, AppColors.accentDarkGold],
              '📈',
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
    List<Color> gradientColors,
    String emoji,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.textWhite, size: 20),
                ),
                Text(emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withOpacity(0.2),
                    AppColors.info.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '📈 ANALYTICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
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
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
      dailyPayments[dateKey] =
          (dailyPayments[dateKey] ?? 0) + payment.actualZakatAmount;
    }

    final spots =
        dailyPayments.entries.toList().asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.value);
        }).toList();

    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Daily Payments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          AppColors.accentLightGold,
                        ],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primaryGold,
                            strokeWidth: 2,
                            strokeColor: AppColors.textWhite,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryGold.withOpacity(0.3),
                            AppColors.primaryGold.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold,
                        AppColors.accentLightGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter by Time Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children:
                  _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.primaryGold,
                                      AppColors.accentLightGold,
                                    ],
                                  )
                                  : null,
                          color:
                              isSelected
                                  ? null
                                  : AppColors.backgroundGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryGold
                                    : AppColors.borderPrimary.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primaryGold.withOpacity(
                                        0.3,
                                      ),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final historyVm = ref.watch(historyViewModelProvider);

    if (historyVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyVm.error != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryWhite,
              AppColors.secondaryBeige.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.borderPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Error: ${historyVm.error}',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (historyVm.history.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryWhite,
              AppColors.secondaryBeige.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.borderPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  size: 48,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No payments found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payments will appear here once users make donations',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final filteredPayments = _filterPayments(historyVm.history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.accentLightGold],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PAYMENT HISTORY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${filteredPayments.length} payments',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
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

  /// Filters payments based on the selected time period
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryWhite,
            AppColors.secondaryBeige.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.borderPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold,
                        AppColors.accentLightGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.payment_rounded,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.currency} ${payment.actualZakatAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(payment.paidAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'APPROVED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderPrimary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Payer',
                          payment.userFullName,
                          Icons.person_rounded,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Phone',
                          payment.userAccountNo,
                          Icons.phone_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    'Payment Method',
                    payment.paymentMethod,
                    Icons.credit_card_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
