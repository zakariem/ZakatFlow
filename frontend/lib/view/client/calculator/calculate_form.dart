import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/custom/custom_field.dart';
import 'package:frontend/view/client/donate/donate_screen.dart';
import 'package:intl/intl.dart';
import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_dropdown.dart';
import '../../../utils/widgets/loader.dart';
import '../../../viewmodels/zakat/zakat_view_model.dart';
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

  final List<Map<String, dynamic>> fields = [
    {'label': 'Miisaanka dahabka (grams)', 'provider': goldValueProvider},
    {'label': 'Miisaanka qalinka (grams)', 'provider': silverValueProvider},
    {'label': 'Lacagta (gacanta iyo bangiga)', 'provider': cashValueProvider},
    {
      'label': 'Lacagta lagu deponay mustaqbalka',
      'provider': depositedProvider,
    },
    {'label': 'Deyn bixinta', 'provider': loansProvider},
    {
      'label': 'Maalgashiga ganacsiga, saamiyada, mushaharka hawlgabka',
      'provider': investmentsProvider,
    },
    {'label': 'Qiimaha saamiyada (shares)', 'provider': stockProvider},
    {'label': 'Lacag ama alaab lagu amaahdo', 'provider': borrowedProvider},
    {'label': 'Mushaarka loo leeyahay shaqaalaha', 'provider': wagesProvider},
    {'label': 'Cashuuraha iyo kirada', 'provider': taxesProvider},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (var field in fields) {
      final provider = field['provider'] as StateProvider<String>;
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
    final basis = ref.watch(basisProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final filteredFields =
        fields.where((field) {
          final provider = field['provider'] as StateProvider<String>;
          if (provider == goldValueProvider) return basis == 'Dahab';
          if (provider == silverValueProvider) return basis == 'Qalin';
          return true;
        }).toList();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06,
        vertical: height * 0.03,
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
            const SizedBox(height: 20),

            ...filteredFields.map((field) {
              final label = field['label'] as String;
              final provider = field['provider'] as StateProvider<String>;
              final controller = controllers[provider]!;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  labelText: label,
                  hintText: 'Fadlan geli $label',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fadlan geli $label';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Fadlan geli tiro sax ah';
                    }
                    return null;
                  },
                ),
              );
            }),

            const SizedBox(height: 30),

            // Calculate Button Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.isCalculating
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Loader(),
                      ),
                    )
                  : CustomButton(
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return;

                        widget.onCalculationStart();
                        await Future.delayed(const Duration(seconds: 1));

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

                        widget.onCalculationEnd();
                      },
                      text: 'Xisaabi Zakaatul Maal',
                    ),
            ),

            const SizedBox(height: 20),

            if (_showResult) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Totalka Lacagtada'),
                trailing: Text(
                  '\$${NumberFormat('#,##0.00').format(_totalAssets)} USD',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Zakada lagaarabo'),
                trailing: Text(
                  '\$${NumberFormat('#,##0.00').format(_computedZakat)} USD',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_computedZakat > 0)
                CustomButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DonationScreen(amount: _computedZakat),
                      ),
                    );
                  },
                  text: 'Hadda Bixi',
                ),
            ],
          ],
        ),
      ),
    );
  }
}
