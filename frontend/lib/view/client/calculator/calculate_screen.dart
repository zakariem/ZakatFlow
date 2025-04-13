import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../providers/zakat_providers.dart';
import '../../../utils/constant/validation_utils.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_dropdown.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../viewmodels/zakat/zakat_view_model.dart';

class CalculateScreen extends ConsumerStatefulWidget {
  const CalculateScreen({super.key});

  @override
  ConsumerState<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends ConsumerState<CalculateScreen> {
  final formKey = GlobalKey<FormState>();
  final Map<StateProvider<String>, TextEditingController> controllers = {};
  bool isCalculating = false; // Tracks calculation/loading state

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
    final metalPricesAsync = ref.watch(metalPricesProvider);
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Dynamic Zakat Calculator',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      body: metalPricesAsync.when(
        data:
            (metalPrices) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildZakatSummaryCard(ref, metalPrices),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          final current = ref.read(showMoreSummaryProvider);
                          ref.read(showMoreSummaryProvider.notifier).state =
                              !current;
                        },
                        child: Text(
                          ref.watch(showMoreSummaryProvider)
                              ? 'Show less ▲'
                              : 'Show more ▼',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown(
                      label: 'Select Calculation Basis',
                      provider: basisProvider,
                      options: ['Gold', 'Silver'],
                    ),
                    ..._buildFields(ref),
                    const SizedBox(height: 30),
                    // Show a loading indicator if a calculation is in progress
                    isCalculating
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isCalculating = true;
                              });
                              // Simulate some processing delay (this can be removed if calculation is fast)
                              await Future.delayed(const Duration(seconds: 1));
                              final zakatMap = viewModel.calculateZakat(
                                metalPrices,
                              );
                              setState(() {
                                isCalculating = false;
                              });
                              // Use the correct key: 'financialZakat'
                              final formattedZakat = NumberFormat(
                                '#,##0.00',
                              ).format(zakatMap['financialZakat']);
                              final animalZakat = zakatMap['animalZakat'];
                              final camelZakat = animalZakat['camels'];
                              final cowZakat = animalZakat['cows'];
                              final sheepZakat = animalZakat['sheep'];

                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text('Zakat Calculation'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '💰 Monetary Zakat: \$$formattedZakat USD',
                                          ),
                                          const SizedBox(height: 12),
                                          Text('🐫 Camel Zakat: $camelZakat'),
                                          Text('🐄 Cow Zakat: $cowZakat'),
                                          Text('🐑 Sheep Zakat: $sheepZakat'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          text: 'Calculate Zakat',
                        ),
                  ],
                ),
              ),
            ),
        loading: () => const Center(child: LoaderPage()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildZakatSummaryCard(
    WidgetRef ref,
    Map<String, double> metalPrices,
  ) {
    final showMoreSummary = ref.watch(showMoreSummaryProvider);
    final viewModel = ref.read(zakatViewModelProvider);
    final nisab = viewModel.getNisabThresholds(metalPrices);

    if (!showMoreSummary) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '💡 How Zakat is Calculated .............',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 How Zakat is Calculated',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zakat is an annual obligation for every adult Muslim who owns wealth above the Nisab threshold for one full lunar year. It is calculated at 2.5% of your net zakatable assets, plus any additional liabilities such as livestock Zakat.',
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ What to Include:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '• Zakatable Assets: Gold, silver, cash, savings, business assets, investments, and livestock.\n'
            '• Possession Period: Must have been held for at least one full lunar year.',
          ),
          const SizedBox(height: 8),
          const Text(
            '➖ What You Can Deduct:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SelectableText(
            '• Debts due within the next 12 months\n'
            '• Overdue payments\n'
            '• Up to 12 months of long-term debt instalments\n\n'
            'Note: Expenses not yet due, long-term debts beyond 12 months, and interest (riba) cannot be deducted.',
          ),
          const SizedBox(height: 8),
          const Text(
            '🧮 Net Assets Formula:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Net Assets = Total Zakatable Assets – Deductible Liabilities',
          ),
          const SizedBox(height: 8),
          const Text(
            '📉 Nisab Threshold for 2025:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(
            '• Using Silver (595 grams) ≈  ${r"$"}${nisab['silver']?.toStringAsFixed(2) ?? "N/A"}\n'
            '• Using Gold (85 grams) ≈  ${r"$"}${nisab['gold']?.toStringAsFixed(2) ?? "N/A"}\n\n'
            'Pay Zakat only if your net assets exceed one of these values.',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(WidgetRef ref) {
    final fields = [
      {'label': 'Weight of gold (in grams)', 'provider': goldValueProvider},
      {'label': 'Weight of silver (in grams)', 'provider': silverValueProvider},
      {'label': 'Cash (in hand and bank)', 'provider': cashValueProvider},
      {'label': 'Deposited for future purpose', 'provider': depositedProvider},
      {'label': 'Loans given out', 'provider': loansProvider},
      {
        'label': 'Business investments, shares, pensions',
        'provider': investmentsProvider,
      },
      {'label': 'Value of stock', 'provider': stockProvider},
      {
        'label': 'Borrowed money / goods on credit',
        'provider': borrowedProvider,
      },
      {'label': 'Wages due to employees', 'provider': wagesProvider},
      {
        'label': 'Immediate dues (taxes, rent, utilities)',
        'provider': taxesProvider,
      },
      {'label': 'عدد الإبل', 'provider': camelValueProvider},
      {'label': 'عدد البقر', 'provider': cowValueProvider},
      {'label': 'عدد الغنم', 'provider': sheepValueProvider},
    ];

    return fields.map((field) {
      final label = field['label'] as String;
      final provider = field['provider'] as StateProvider<String>;
      final controller = controllers[provider]!;

      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: CustomField(
          labelText: label,
          controller: controller,
          keyboardType: TextInputType.number,
          validator: ValidationUtils.validateNumberField,
        ),
      );
    }).toList();
  }
}
