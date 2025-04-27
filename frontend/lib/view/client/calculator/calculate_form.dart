import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_dropdown.dart';
import '../../../viewmodels/zakat/zakat_view_model.dart';
import 'fields_section.dart';
import 'zakat_summary_card.dart';

class CalculateForm extends ConsumerStatefulWidget {
  final Map<String, double> metalPrices;
  final bool isCalculating;
  final VoidCallback onCalculationStart;
  final VoidCallback onCalculationEnd;

  const CalculateForm({
    super.key,
    required this.metalPrices,
    required this.isCalculating,
    required this.onCalculationStart,
    required this.onCalculationEnd,
  });

  @override
  ConsumerState<CalculateForm> createState() => _CalculateFormState();
}

class _CalculateFormState extends ConsumerState<CalculateForm> {
  final formKey = GlobalKey<FormState>();
  final Map<StateProvider<String>, TextEditingController> controllers = {};

  bool _showResult = false;
  double _totalAssets = 0.0;
  double _computedZakat = 0.0;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final providers = [
      goldValueProvider,
      silverValueProvider,
      cashValueProvider,
      depositedProvider,
      loansProvider,
      investmentsProvider,
      stockProvider,
      borrowedProvider,
      wagesProvider,
      taxesProvider,
    ];

    for (var provider in providers) {
      final initialText = ref.read(provider);
      final controller = TextEditingController(text: initialText);
      controller.addListener(() {
        ref.read(provider.notifier).state = controller.text;
      });
      controllers[provider] = controller;
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(zakatViewModelProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.02,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZakatSummaryCard(metalPrices: widget.metalPrices),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  final current = ref.read(showMoreSummaryProvider);
                  ref.read(showMoreSummaryProvider.notifier).state = !current;
                },
                child: Text(
                  ref.watch(showMoreSummaryProvider)
                      ? 'Muuji wax ka yar ▲'
                      : 'Muuji wax dheeraad ah ▼',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Dooro habka xisaabinta',
              provider: basisProvider,
              options: ['Dahab', 'Qalin'],
            ),
            ...buildFields(ref, controllers),
            const SizedBox(height: 30),

            // Calculate button or loading indicator
            widget.isCalculating
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                  onTap: () async {
                    if (!formKey.currentState!.validate()) return;

                    // Start calculation
                    widget.onCalculationStart();

                    // Simulate delay
                    await Future.delayed(const Duration(seconds: 1));

                    // Perform zakat calculation
                    final zakatMap = viewModel.calculateZakat(
                      widget.metalPrices,
                    );
                    final totalAssets = zakatMap['netAssets'] as double;
                    final computedZakat = zakatMap['financialZakat'] as double;

                    setState(() {
                      _totalAssets = totalAssets;
                      _computedZakat = computedZakat;
                      _showResult = true;
                    });

                    // End calculation
                    widget.onCalculationEnd();
                  },
                  text: 'Xisaabi Zakaatul Maal',
                ),

            const SizedBox(height: 20),

            // Display results after first calculation
            if (_showResult) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Total assets'),
                trailing: Text(
                  '\$${NumberFormat('#,##0.00').format(_totalAssets)} USD',
                  style: const TextStyle(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.bold, // Bolder font
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Zakat payable'),
                trailing: Text(
                  '\$${NumberFormat('#,##0.00').format(_computedZakat)} USD',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Pay Now button only if zakat > 0
              if (_computedZakat > 0)
                CustomButton(onTap: () {}, text: 'Pay Now'),
            ],
          ],
        ),
      ),
    );
  }
}
