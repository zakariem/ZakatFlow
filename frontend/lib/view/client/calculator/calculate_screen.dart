import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/utils/widgets/loader.dart';

import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import 'calculate_form.dart';

class CalculateScreen extends ConsumerStatefulWidget {
  const CalculateScreen({super.key});

  @override
  ConsumerState<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends ConsumerState<CalculateScreen> {
  bool isCalculating = false;

  @override
  Widget build(BuildContext context) {
    final metalPricesAsync = ref.watch(metalPricesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Xisaabinta Zakaatul Maal',
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
      ),
      body: metalPricesAsync.when(
        data:
            (metalPrices) => CalculateForm(
              metalPrices: metalPrices,
              isCalculating: isCalculating,
              onCalculationStart: () => setState(() => isCalculating = true),
              onCalculationEnd: () => setState(() => isCalculating = false),
            ),
        loading: () => const Center(child: LoaderPage()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
