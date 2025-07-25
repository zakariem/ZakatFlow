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

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TickerProviderStateMixin {
  bool _initialized = false;
  bool showDonationAlert = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      resetZakatProviders(ref);
      _fetchHistory();
      _initialized = true;
      _animationController.forward();

      // Show success message after build
      if (widget.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    // Assign to a local variable for cleaner and safer access.
    final donationData = widget.donationData;
    if (donationData == null) return;

    final actualZakatAmount = (donationData['actualZakatAmount'] as num?) ?? 0.0;
    final currency = donationData['currency'] as String? ?? 'USD';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Donation Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Test Payment',
                      '${actualZakatAmount.toStringAsFixed(2)} $currency',
                    ),
                    _buildInfoRow(
                      'Actual Zakat',
                      '${actualZakatAmount.toStringAsFixed(2)} $currency',
                    ),
                    _buildInfoRow(
                      'Recipient',
                      donationData['agentName'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Account',
                      donationData['userAccountNo'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Date',
                      DateTime.now().toString().substring(0, 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thank you for your generous donation!',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold,
                      AppColors.accentLightGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundLight.withOpacity(0.8),
              AppColors.accentLightGold.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(historyVm, screenSize, isTablet, isDesktop),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: historyVm.isLoading
                            ? const Center(child: Loader())
                            : historyVm.history.isEmpty
                                ? _buildEmptyState(
                                    screenSize, isTablet, isDesktop)
                                : _buildHistoryList(historyVm.history,
                                    screenSize, isTablet, isDesktop),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size screenSize, bool isTablet, bool isDesktop) {
    final containerWidth =
        isDesktop ? 600.0 : (isTablet ? 500.0 : screenSize.width * 0.85);
    final iconSize = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
    final titleSize = isDesktop ? 28.0 : (isTablet ? 24.0 : 20.0);
    final subtitleSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);
    final padding = isDesktop ? 48.0 : (isTablet ? 40.0 : 24.0);
    final margin = isDesktop ? 64.0 : (isTablet ? 48.0 : 24.0);

    return Center(
      child: Container(
        width: containerWidth,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white.withOpacity(0.9)],
          ),
          borderRadius:
              BorderRadius.circular(isDesktop ? 32 : (isTablet ? 28 : 24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.1),
              blurRadius: isDesktop ? 30 : (isTablet ? 25 : 20),
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.2),
                    AppColors.accentLightGold.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: iconSize * 0.5,
                color: AppColors.primaryGold,
              ),
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
            Text(
              'No Payment History',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            Text(
              'Your donation history will appear here\nonce you make your first contribution',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : (isTablet ? 24 : 20),
                vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.1),
                    AppColors.accentLightGold.withOpacity(0.1),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(isDesktop ? 24 : (isTablet ? 22 : 20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: isDesktop ? 20 : (isTablet ? 18 : 16),
                    color: AppColors.primaryGold,
                  ),
                  SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : 8)),
                  Text(
                    'Start your giving journey today',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
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

  Widget _buildHistoryList(
      List<HistoryModel> history, Size screenSize, bool isTablet, bool isDesktop) {
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);
    final verticalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    final itemMargin = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final itemPadding = isDesktop ? 28.0 : (isTablet ? 24.0 : 20.0);
    final iconSize = isDesktop ? 60.0 : (isTablet ? 55.0 : 50.0);
    final titleSize = isDesktop ? 20.0 : (isTablet ? 19.0 : 18.0);
    final subtitleSize = isDesktop ? 14.0 : (isTablet ? 13.5 : 13.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // For desktop, use a grid layout with multiple columns
        if (isDesktop && constraints.maxWidth > 1200) {
          return GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth > 1600 ? 3 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final payment = history[index];
              return _buildHistoryCard(payment, itemPadding, iconSize,
                  titleSize, subtitleSize, isDesktop, isTablet);
            },
          );
        }

        // For tablet and mobile, use a list layout
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final payment = history[index];
            return Container(
              margin: EdgeInsets.only(bottom: itemMargin),
              child: _buildHistoryCard(payment, itemPadding, iconSize,
                  titleSize, subtitleSize, isDesktop, isTablet),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(
      HistoryModel payment,
      double itemPadding,
      double iconSize,
      double titleSize,
      double subtitleSize,
      bool isDesktop,
      bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius:
            BorderRadius.circular(isDesktop ? 24 : (isTablet ? 22 : 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.08),
            blurRadius: isDesktop ? 20 : (isTablet ? 18 : 15),
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isDesktop ? 12 : (isTablet ? 10 : 8),
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(isDesktop ? 24 : (isTablet ? 22 : 20)),
          onTap: () => _showPaymentDetails(payment, context),
          child: Padding(
            padding: EdgeInsets.all(itemPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // This Column now correctly holds both Rows and the divider
              children: [
                Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentLightGold,
                            AppColors.primaryGold,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            blurRadius: isDesktop ? 12 : (isTablet ? 10 : 8),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: iconSize * 0.48,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : (isTablet ? 18 : 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.agentName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: titleSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isDesktop ? 12 : (isTablet ? 10 : 8),
                              vertical: isDesktop ? 6 : (isTablet ? 5 : 4),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  isDesktop ? 10 : (isTablet ? 9 : 8)),
                            ),
                            child: Text(
                              'Account: ${payment.userAccountNo}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isDesktop ? 16 : (isTablet ? 14 : 12),
                            vertical: isDesktop ? 8 : (isTablet ? 7 : 6),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGold.withOpacity(0.1),
                                AppColors.accentLightGold.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                isDesktop ? 14 : (isTablet ? 13 : 12)),
                          ),
                          child: Text(
                            '${payment.actualZakatAmount.toStringAsFixed(2)} ${payment.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0),
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 8 : (isTablet ? 7 : 6)),
                        Text(
                          payment.paidAt.toLocal().toString().substring(
                                0,
                                10,
                              ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize:
                                isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 20 : (isTablet ? 18 : 16)),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryGold.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : (isTablet ? 18 : 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : (isTablet ? 14 : 12),
                        vertical: isDesktop ? 8 : (isTablet ? 7 : 6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBeige.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 24 : (isTablet ? 22 : 20)),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            size: isDesktop ? 16 : (isTablet ? 15 : 14),
                            color: AppColors.primaryGold,
                          ),
                          SizedBox(width: isDesktop ? 8 : (isTablet ? 7 : 6)),
                          Text(
                            payment.paymentMethod,
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w500,
                              fontSize: isDesktop
                                  ? 13.0
                                  : (isTablet ? 12.5 : 12.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: isDesktop ? 16 : (isTablet ? 15 : 14),
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: isDesktop ? 6 : (isTablet ? 5 : 4)),
                        Text(
                          'Tap for details',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize:
                                isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // **FIX**: Removed the extra closing brace '}' that was here.
  // This was causing the class to end prematurely.

  void _showPaymentDetails(HistoryModel payment, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;
    final modalPadding = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final iconSize = isDesktop ? 60.0 : (isTablet ? 55.0 : 50.0);
    final titleSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);
    final borderRadius = isDesktop ? 36.0 : (isTablet ? 32.0 : 28.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.backgroundLight],
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isDesktop ? 30 : (isTablet ? 25 : 20),
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.all(modalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isDesktop ? 60 : (isTablet ? 55 : 50),
              height: isDesktop ? 6 : (isTablet ? 5.5 : 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.3),
                    AppColors.primaryGold,
                    AppColors.primaryGold.withOpacity(0.3),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(isDesktop ? 12 : (isTablet ? 11 : 10)),
              ),
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
            Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold,
                        AppColors.accentLightGold,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: iconSize * 0.48,
                  ),
                ),
                SizedBox(width: isDesktop ? 20 : (isTablet ? 18 : 16)),
                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
            Container(
              padding:
                  EdgeInsets.all(isDesktop ? 28.0 : (isTablet ? 24.0 : 20.0)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.05),
                    AppColors.accentLightGold.withOpacity(0.05),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Date',
                    payment.paidAt.toLocal().toString().substring(0, 16),
                    isDesktop,
                    isTablet,
                  ),
                  _buildDetailRow(
                    'Amount',
                    '${payment.actualZakatAmount.toStringAsFixed(2)} ${payment.currency}',
                    isDesktop,
                    isTablet,
                  ),
                  _buildDetailRow(
                      'Recipient', payment.agentName, isDesktop, isTablet),
                  _buildDetailRow(
                      'Account', payment.userAccountNo, isDesktop, isTablet),
                  _buildDetailRow('Payment Method', payment.paymentMethod,
                      isDesktop, isTablet),
                  _buildDetailRow(
                      'Transaction ID', payment.id, isDesktop, isTablet),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
            Container(
              width: double.infinity,
              height: isDesktop ? 60 : (isTablet ? 56 : 52),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold,
                    AppColors.accentLightGold,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: isDesktop ? 16 : (isTablet ? 14 : 12),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, bool isDesktop, bool isTablet) {
    final verticalPadding = isDesktop ? 14.0 : (isTablet ? 12.0 : 10.0);
    final labelWidth = isDesktop ? 140.0 : (isTablet ? 130.0 : 120.0);
    final labelSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final valueSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final horizontalPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final valuePadding = isDesktop ? 8.0 : (isTablet ? 7.0 : 6.0);
    final borderRadius = isDesktop ? 12.0 : (isTablet ? 10.0 : 8.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: labelWidth,
            padding:
                EdgeInsets.symmetric(vertical: isDesktop ? 4 : (isTablet ? 3 : 2)),
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: valuePadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.1),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: valueSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(
      dynamic historyVm, Size screenSize, bool isTablet, bool isDesktop) {
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);
    final verticalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    final titleSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final subtitleSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
    final containerSize = isDesktop ? 48.0 : (isTablet ? 44.0 : 40.0);
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                Text(
                  'Track your donations',
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: isDesktop ? 12 : (isTablet ? 10 : 8),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: historyVm.isLoading ? null : () => _fetchHistory(),
                child: Container(
                  padding:
                      EdgeInsets.all(isDesktop ? 12 : (isTablet ? 10 : 8)),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: historyVm.isLoading
                        ? AppColors.textSecondary
                        : AppColors.primaryGold,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}