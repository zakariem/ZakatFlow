import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';

import '../../../providers/zakat_providers.dart';
import 'calculate_form.dart';

class ZakaatulmaalScreen extends ConsumerStatefulWidget {
  const ZakaatulmaalScreen({super.key});

  @override
  ConsumerState<ZakaatulmaalScreen> createState() => _ZakaatulmaalScreenState();
}

class _ZakaatulmaalScreenState extends ConsumerState<ZakaatulmaalScreen> {
  bool isCalculating = false;

  @override
  Widget build(BuildContext context) {
    final metalPricesAsync = ref.watch(metalPricesProvider);

    return metalPricesAsync.when(
      data:
          (metalPrices) => CalculateForm(
            metalPrices: metalPrices,
            isCalculating: isCalculating,
            onCalculationStart: () => setState(() => isCalculating = true),
            onCalculationEnd: () => setState(() => isCalculating = false),
          ),
      loading: () => const Center(child: LoaderPage()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
