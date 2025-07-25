import 'dart:math';

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
    // Use addPostFrameCallback to ensure context is available for Snackbars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  /// Loads agent data and payment history from the server
  Future<void> _loadData() async {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    final historyVm = ref.read(historyViewModelProvider.notifier);
    final user = authState.user;

    if (user == null) return;

    // Load agent
    await agentViewModel.selectAgent(user.id, user.token);

    if (mounted) {
      if (agentViewModel.error != null) {
        ErrorScanckbar.showSnackBar(context, agentViewModel.error!);
      } else if (agentViewModel.successMessage != null) {
        SuccessSnackbar.showSnackBar(context, agentViewModel.successMessage!);
      }
      await agentViewModel.clearMessages();
    }

    // Load payment history
    if (mounted) {
      await historyVm.loadHistory(user.token, HistoryRole.agent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final agent = agentViewModel.selectedAgent;
    final isLoading = agentViewModel.isLoading;
    
    // Responsive padding based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = max(16.0, screenWidth * 0.04);

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
            margin: const EdgeInsets.only(right: 12, left: 4),
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
                        "Agent data could not be loaded.",
                        textAlign: TextAlign.center,
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
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
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
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  // MARK: - Summary Cards

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
        
    // RESPONSIVE: Use LayoutBuilder to calculate the aspect ratio for the GridView
    // This ensures cards are well-proportioned on any screen size.
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisSpacing = 16.0;
        final cardWidth = (constraints.maxWidth - crossAxisSpacing) / 2;
        // Aim for a consistent height to calculate aspect ratio
        final cardHeight = 125.0; 
        final aspectRatio = cardWidth / cardHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('📊 PERFORMANCE', 'Performance Overview'),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: [
                _buildSummaryCard(
                  'Total Payments', totalPayments.toString(),
                  Icons.payment_rounded, [AppColors.info, AppColors.info.withOpacity(0.7)], '💳',
                ),
                _buildSummaryCard(
                  'Total Amount', formatter.format(totalAmount),
                  Icons.attach_money_rounded, [AppColors.success, AppColors.success.withOpacity(0.7)], '💰',
                ),
                _buildSummaryCard(
                  "Today's Payments", todayPayments.toString(),
                  Icons.today_rounded, [AppColors.warning, AppColors.warning.withOpacity(0.7)], '📅',
                ),
                _buildSummaryCard(
                  "Today's Amount", formatter.format(todayAmount),
                  Icons.trending_up_rounded, [AppColors.primaryGold, AppColors.accentDarkGold], '📈',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      List<Color> gradientColors, String emoji) {
    return Container(
      decoration: _buildCardBaseDecoration(gradientColors[0]),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.textWhite, size: 18),
                ),
                Text(emoji, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const Spacer(),
            // RESPONSIVE: Use FittedBox to scale down text if it's too long for the card.
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w500,
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

  // MARK: - Charts

  Widget _buildChartsSection() {
    // RESPONSIVE: Use LayoutBuilder to switch between a Row and a Column layout
    // for the charts based on the available width.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch to a vertical layout on screens narrower than 480px
        bool useVerticalLayout = constraints.maxWidth < 480;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('📈 ANALYTICS', 'Analytics Dashboard'),
            const SizedBox(height: 20),
            if (useVerticalLayout)
              Column(
                children: [
                  _buildPaymentMethodChart(),
                  const SizedBox(height: 16),
                  _buildDailyPaymentsChart(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPaymentMethodChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDailyPaymentsChart()),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodChart() {
    final historyVm = ref.watch(historyViewModelProvider);
    final payments = historyVm.history;

    if (payments.isEmpty) return _buildEmptyChart('Payment Methods');

    final paymentsByMethod = <String, int>{};
    for (final payment in payments) {
      paymentsByMethod[payment.paymentMethod] = (paymentsByMethod[payment.paymentMethod] ?? 0) + 1;
    }

    final sections = paymentsByMethod.entries.map((entry) {
      final colors = [AppColors.info, AppColors.success, AppColors.warning, AppColors.primaryGold, AppColors.error];
      final index = paymentsByMethod.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      height: 220,
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          children: [
            Text('Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

    if (payments.isEmpty) return _buildEmptyChart('Daily Payments');

    final dailyPayments = <String, double>{};
    final sortedPayments = List.from(payments)..sort((a, b) => a.paidAt.compareTo(b.paidAt));
    final recentPayments = sortedPayments.length > 7 ? sortedPayments.sublist(sortedPayments.length - 7) : sortedPayments;

    for (final payment in recentPayments) {
      final dateKey = DateFormat('MM/dd').format(payment.paidAt);
      dailyPayments[dateKey] = (dailyPayments[dateKey] ?? 0) + payment.actualZakatAmount;
    }

    final spots = dailyPayments.entries.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Container(
      height: 220,
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          children: [
            Text('Recent Daily Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                      gradient: LinearGradient(colors: [AppColors.primaryGold, AppColors.accentLightGold]),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primaryGold,
                          strokeWidth: 2,
                          strokeColor: AppColors.textWhite,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primaryGold.withOpacity(0.3), AppColors.primaryGold.withOpacity(0.05)],
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

  // MARK: - Filters & Payment History

  Widget _buildFilterSection() {
    return Container(
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryGold, AppColors.accentLightGold]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.filter_list_rounded, color: AppColors.textWhite, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Filter Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: AppColors.backgroundGray.withOpacity(0.3),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryGold : AppColors.borderPrimary.withOpacity(0.3),
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

    if (historyVm.isLoading && historyVm.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyVm.error != null) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error Loading History',
        message: historyVm.error!,
        iconColor: AppColors.error
      );
    }
    
    final filteredPayments = _filterPayments(historyVm.history);

    if (filteredPayments.isEmpty) {
       return _buildEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No Payments Found',
        message: _selectedFilter == 'All'
            ? 'Payments will appear here once users make donations.'
            : 'No payments found for the selected filter.'
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT PAYMENTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), width: 1),
              ),
              child: Text(
                '${filteredPayments.length} found',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredPayments.length,
          itemBuilder: (context, index) => _buildPaymentCard(filteredPayments[index]),
        ),
      ],
    );
  }

  List<dynamic> _filterPayments(List<dynamic> payments) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        return payments.where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month && p.paidAt.day == now.day).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDateOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return payments.where((p) => p.paidAt.isAfter(weekStartDateOnly.subtract(const Duration(microseconds: 1)))).toList();
      case 'This Month':
        return payments.where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month).toList();
      default:
        return payments;
    }
  }

  Widget _buildPaymentCard(dynamic payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryGold, AppColors.accentLightGold]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.primaryGold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Icon(Icons.payment_rounded, color: AppColors.textWhite, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.currency} ${payment.actualZakatAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(payment.paidAt),
                        style: TextStyle(fontSize: 13, color: AppColors.textGray, fontWeight: FontWeight.w500),
                      ),
                    ],
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
                border: Border.all(color: AppColors.borderPrimary.withOpacity(0.1), width: 1),
              ),
              // RESPONSIVE: Use LayoutBuilder to stack info items vertically on small cards
              child: LayoutBuilder(builder: (context, constraints) {
                final useVerticalLayoutForInfo = constraints.maxWidth < 320;
                final infoItems = [
                  _buildInfoItem('Payer', payment.userFullName, Icons.person_rounded),
                  _buildInfoItem('Phone', payment.userAccountNo, Icons.phone_rounded),
                ];
                return Column(
                  children: [
                    if (useVerticalLayoutForInfo)
                      Column(children: [infoItems[0], const SizedBox(height: 16), infoItems[1]])
                    else
                      Row(children: [
                        Expanded(child: infoItems[0]),
                        const SizedBox(width: 8),
                        Expanded(child: infoItems[1]),
                      ]),
                    const SizedBox(height: 16),
                    _buildInfoItem('Payment Method', payment.paymentMethod, Icons.credit_card_rounded),
                  ],
                );
              }),
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
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Reusable Helper Widgets

  Widget _buildSectionHeader(String tag, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), width: 1),
          ),
          child: Text(tag, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
      ],
    );
  }

  BoxDecoration _buildCardBaseDecoration(Color shadowColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: shadowColor.withOpacity(0.1), spreadRadius: 0, blurRadius: 20, offset: const Offset(0, 8)),
      ],
      border: Border.all(color: AppColors.borderPrimary.withOpacity(0.1), width: 1),
    );
  }

  BoxDecoration _buildCardSurfaceDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textGray).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 48, color: iconColor ?? AppColors.textGray),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: AppColors.textGray, fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      height: 220,
      decoration: _buildCardBaseDecoration(AppColors.shadowLight),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _buildCardSurfaceDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.textGray),
            const SizedBox(height: 12),
            Text('No data available', style: TextStyle(color: AppColors.textGray, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}