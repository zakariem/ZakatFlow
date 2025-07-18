import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../viewmodels/zakat/zakat_agriculture_viewmodel.dart';

class ZakaatulBeeraha extends ConsumerStatefulWidget {
  const ZakaatulBeeraha({super.key});

  @override
  ConsumerState<ZakaatulBeeraha> createState() => _ZakaatulBeerahaState();
}

class _ZakaatulBeerahaState extends ConsumerState<ZakaatulBeeraha> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _cropWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialValue = ref.read(cropWeightProvider);
    _cropWeightController.text = initialValue;
    _cropWeightController.addListener(() {
      ref.read(cropWeightProvider.notifier).state = _cropWeightController.text;
    });
  }

  @override
  void dispose() {
    _cropWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final viewModel = ref.read(zakatAgricultureViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
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
              // Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundInfo,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakada Beeraha - Macluumaad Muhiim ah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Zakada beeraha waa zakaa waajib ah oo lagu bixiyo wax-soo-saarka dhulka sida sarreen, shaciir, bariis, iyo cuntada kale ee la kaydin karo.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nisab Requirements Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWarning,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shuruudaha Zakada Beeraha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement('1. Wax-soo-saarka in uu gaaro ama dhaafto 653 kg (5 wasaq)'),
                    _buildRequirement('2. In ay tahay cunto la kaydin karo'),
                    _buildRequirement('3. In la bixiyo maalinta la goosanayo'),
                    _buildRequirement('4. In milkiilaha dhulku uu leeyahay wax-soo-saarka'),
                    const SizedBox(height: 8),
                    Text(
                      'Tusaale: Sarreen, shaciir, bariis, galley, timir, canab (haddii la qalaliyo)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Zakat Rates Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSuccess,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qiyaasta Zakada Beeraha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildZakatRate('🌧️ Roobka iyo biyaha dabiiciga ah', '10%', 'Haddii dhulka lagu waraabayo roob ama biyo dabiici ah'),
                    const SizedBox(height: 8),
                    _buildZakatRate('💧 Waraabka dadaalka aadanaha', '5%', 'Haddii dhulka lagu waraabayo dadaal iyo qalabka aadanaha'),
                    const SizedBox(height: 8),
                    _buildZakatRate('🔄 Isku-dhafan (roob iyo waraab)', '7.5%', 'Haddii labada hab waraabka la isticmaalo'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Input Fields
              Text(
                'Macluumaadka Wax-soo-saarka',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 15),

              // Crop Type Dropdown
              Text(
                'Nooca Wax-soo-saarka',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  final selectedCropType = ref.watch(cropTypeProvider);
                  return DropdownButtonFormField<String>(
                    value: selectedCropType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                      ),
                      hintText: 'Dooro nooca wax-soo-saarka',
                    ),
                    items: viewModel.getCropTypes().map((crop) {
                      return DropdownMenuItem<String>(
                        value: crop['value']!,
                        child: Text(crop['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(cropTypeProvider.notifier).state = value;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 15),

              // Crop Weight Input
              Text(
                'Miisaanka Wax-soo-saarka (kg)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomField(
                controller: _cropWeightController,
                keyboardType: TextInputType.number,
                labelText: 'Miisaanka (kg)',
                hintText: 'Geli miisaanka wax-soo-saarka kilogram',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fadlan geli miisaanka wax-soo-saarka';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 0) {
                    return 'Fadlan geli miisaan sax ah';
                  }
                  return null;
                },
                onChanged: (value) {
                  ref.read(cropWeightProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 15),

              // Irrigation Type Dropdown
              Text(
                'Nooca Waraabka',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  final selectedIrrigationType = ref.watch(irrigationTypeProvider);
                  return DropdownButtonFormField<String>(
                    value: selectedIrrigationType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                      ),
                      hintText: 'Dooro nooca waraabka',
                    ),
                    items: viewModel.getIrrigationTypes().map((irrigation) {
                      return DropdownMenuItem<String>(
                        value: irrigation['value']!,
                        child: Text(irrigation['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(irrigationTypeProvider.notifier).state = value;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 30),

              // Calculate Button
              Center(
                child: CustomButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      final zakatAgricultureViewModel = ref.read(
                        zakatAgricultureViewModelProvider,
                      );
                      final result = zakatAgricultureViewModel.calculateAgriculturalZakat();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: AppColors.backgroundLight,
                          title: Row(
                            children: [
                              Icon(
                                Icons.agriculture,
                                color: AppColors.primaryGold,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Natiijada Zakada Beeraha',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Crop Information
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundInfo,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Macluumaadka Wax-soo-saarka:',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.info,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nooca: ${result['cropType']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Miisaanka: ${result['cropWeight']} kg',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Waraabka: ${result['irrigationDescription']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Nisab Check
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: result['nisabReached'] 
                                        ? AppColors.backgroundSuccess 
                                        : AppColors.backgroundWarning,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        result['nisabReached'] 
                                            ? Icons.check_circle 
                                            : Icons.warning,
                                        color: result['nisabReached'] 
                                            ? AppColors.success 
                                            : AppColors.warning,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          result['nisabReached']
                                              ? 'Nisaabka waa la gaaray (${result['nisabThreshold']} kg)'
                                              : 'Nisaabka lama gaarin (loo baahan yahay ${result['nisabThreshold']} kg)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: result['nisabReached'] 
                                                ? AppColors.success 
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Zakat Calculation
                                if (result['nisabReached']) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primaryGold.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Xisaabinta Zakada:',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Qiyaasta: ${result['zakatRatePercentage']}%',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Zakada la bixinayo: ${result['zakatAmount'].toStringAsFixed(1)} kg',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundWarning,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Zakaa lama rabo maadaama nisaabka lama gaarin.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // Islamic Basis
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundInfo,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Xasuusnow: "Bixiya xaqqiisa maalinta la goosanayo" - Surah Al-An\'am 6:141',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.info,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGold,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Waad ku mahadsan tahay',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  text: 'Xisaabi Zakada Beeraha',
                ),
              ),
              const SizedBox(height: 20),

              // Additional Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundInfo.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Macluumaad Dheeraad ah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Zakada beeraha waxaa lagu dhisay Quraanka iyo Xadiithka Rasuulka ﷺ\n'
                      '• Waa in la bixiyaa maalinta la goosanayo, ma aha kadib markii la iibiyo\n'
                      '• Haddii wax-soo-saarka la burburiyo ka hor goosashada, zakaa lama rabo\n'
                      '• Milkiilaha dhulku ayaa bixiya, ma aha kiraystaha',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatRate(String title, String percentage, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                percentage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}