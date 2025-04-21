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
      camelValueProvider,
      cowValueProvider,
      sheepValueProvider,
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
            widget.isCalculating
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      widget.onCalculationStart();
                      await Future.delayed(const Duration(seconds: 1));

                      final zakatMap = viewModel.calculateZakat(
                        widget.metalPrices,
                      );
                      widget.onCalculationEnd();

                      final formattedZakat = NumberFormat(
                        '#,##0.00',
                      ).format(zakatMap['financialZakat']);
                      final animal = zakatMap['animalZakat'];
                      final camel = animal['camels'];
                      final cow = animal['cows'];
                      final sheep = animal['sheep'];

                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Zakat Calculation'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💰 Monetary Zakat: \$$formattedZakat USD',
                                  ),
                                  Text('🐫 Zakada Geela: $camel'),
                                  Text('🐄 Zakada Loda: $cow'),
                                  Text('🐑 Zakada Ariga: $sheep'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  text: 'Xisaabi Zakaatul Maal',
                ),
          ],
        ),
      ),
    );
  }
}
