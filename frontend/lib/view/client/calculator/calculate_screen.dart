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
          'Xisaabinta Zakaatul Maal',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
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
                                          Text('🐫 Zakada Geela: $camelZakat'),
                                          Text('🐄 Zakada Lo`da: $cowZakat'),
                                          Text(
                                            '🐑 Zakada Ariga iyo Idaha: $sheepZakat',
                                          ),
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
                          text: 'Xisaabi Zakaatul Maal',
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
          'Sida Zakaatul Maalka loo xisaabiyo .............',
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
            '💡 Sida Zakaatka Loo Xisaabiyo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zakaatku waa waajib sannadle ah oo saaran Muslim kasta oo qaangaar ah oo haysta hanti ka badan xadka Nisabka muddo sannad dayaxeed buuxa ah. Waxaa laga xisaabiyaa 2.5% ee hantida laga bixiyo Zakaatka, oo lagu daro wixii waajibyo dheeraad ah sida Zakaatka xoolaha.',
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ Waxa la Xisaabinayo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '• Hantida laga bixiyo Zakaat: Dahab, lacag caddaan ah, kayd, hanti ganacsi, maalgashi, iyo xoolo.\n'
            '• Muddada Haynta: Waa in la hayay ugu yaraan hal sannad dayaxeed buuxa.',
          ),
          const SizedBox(height: 8),
          const Text(
            '➖ Waxa la Ka Jarayo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SelectableText(
            '• Deymaha la bixinayo 12-ka bilood ee soo socda\n'
            '• Bixino dib u dhacay\n'
            '• Ilaa 12 bilood oo ka mid ah deyn muddo-dheer ah\n\n'
            'Ogeysiis: Kharashaadka aan weli la gaarin waqtigooda, deymaha ka badan 12 bilood, iyo ribada (riba) lama jarayo.',
          ),
          const SizedBox(height: 8),
          const Text(
            '🧮 Qaaciddada Hantida Saafi ah:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Hanti Saafi ah = Wadarta Hantida laga bixiyo Zakaat – Waajibaadka laga jari karo',
          ),
          const SizedBox(height: 8),
          const Text(
            '📉 Xadka Nisabka ee 2025:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(
            '• Marka la adeegsado Qalin (595 garaam) ≈  ${r"$"}${nisab['silver']?.toStringAsFixed(2) ?? "N/A"}\n'
            '• Marka la adeegsado Dahab (85 garaam) ≈  ${r"$"}${nisab['gold']?.toStringAsFixed(2) ?? "N/A"}\n\n'
            'Zakaat bixi oo keliya haddii hantidaada saafi ah ay ka badan tahay mid ka mid ah qiimayaashan.',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(WidgetRef ref) {
    final fields = [
      {'label': 'Miisaanka dahabka (gram)', 'provider': goldValueProvider},
      {
        'label': 'Miisaanka lacagta dayaxa (gram)',
        'provider': silverValueProvider,
      },
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
      {'label': 'Qiimaha saamiyada', 'provider': stockProvider},
      {'label': 'Lacag ama alaab lagu amaahdo', 'provider': borrowedProvider},
      {'label': 'Mushaarka loo leeyahay shaqaalaha', 'provider': wagesProvider},
      {
        'label': 'Xoolo degdeg ah (cashuuraha, kirada, adeegyada)',
        'provider': taxesProvider,
      },
      {'label': 'Tirada geela', 'provider': camelValueProvider},
      {'label': 'Tirada lo’da', 'provider': cowValueProvider},
      {'label': 'Tirada idaha', 'provider': sheepValueProvider},
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
