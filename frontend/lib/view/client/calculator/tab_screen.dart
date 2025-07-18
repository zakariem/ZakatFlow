import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view/client/calculator/Zakaatul_xoolaha.dart';
import 'package:frontend/view/client/calculator/zakaatul_maal.dart';
import 'package:frontend/view/client/calculator/zakaatul_fitr.dart';
import 'package:frontend/view/client/calculator/zakaatul_beeraha.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/calculator_tab_provider.dart';
import '../../../utils/theme/app_color.dart';

class TabScreen extends ConsumerStatefulWidget {
  const TabScreen({super.key});

  @override
  ConsumerState<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends ConsumerState<TabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> screens = const [ZakaatulmaalScreen(), ZakaatulXoolaha(), ZakaatulFitr(), ZakaatulBeeraha()];

  @override
  void initState() {
    super.initState();
    final tabs = ref.read(tabViewModelProvider).getTabs();
    _tabController = TabController(length: tabs.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(tabIndexProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(tabViewModelProvider).getTabs();
    ref.watch(tabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Xisaabinta Zakada',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGold,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: tabs.map((tab) => Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                tab,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          )).toList(),
        ),
      ),
      body: TabBarView(controller: _tabController, children: screens),
    );
  }
}
