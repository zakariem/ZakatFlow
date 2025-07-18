import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../viewmodels/zakat/zakat_fitr_viewmodel.dart';

class ZakaatulFitr extends ConsumerStatefulWidget {
  const ZakaatulFitr({super.key});

  @override
  ConsumerState<ZakaatulFitr> createState() => _ZakaatulFitrState();
}

class _ZakaatulFitrState extends ConsumerState<ZakaatulFitr> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfPeopleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialValue = ref.read(numberOfPeopleProvider);
    _numberOfPeopleController.text = initialValue;
    _numberOfPeopleController.addListener(() {
      ref.read(numberOfPeopleProvider.notifier).state =
          _numberOfPeopleController.text;
    });
  }

  @override
  void dispose() {
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                      'Zakada Fitr - Macluumaad Muhiim ah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Zakada Fitr waa zakaa waajib ah oo lagu bixiyo dhammaadka bisha Ramadaan. Waxay waajib ku tahay qof kasta oo Muslim ah oo awood u leh.',
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

              // Requirements Card
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
                      'Shuruudaha Zakada Fitr',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement('1. In aad Muslim tahay'),
                    _buildRequirement('2. In aad nool tahay maalinta Ciidka'),
                    _buildRequirement(
                      '3. In aad awood u leedahay (ma ahayn sabool)',
                    ),
                    _buildRequirement(
                      '4. In aad leedahay cunto ku filan maalinta iyo habeenka',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haddii shuruudahan la buuxiyo, waa in la bixiyaa qof kasta oo qoyska ku jira.',
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

              // Calculation Card
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
                      'Xisaabinta Zakada Fitr',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Qof kasta wuxuu bixiyaa: 2.5 kg bariis ama cunto kale oo aasaasi ah',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waqtiga bixinta: Ka hor inta aan la bilaaban salaada Ciidka',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Input Field
              Text(
                'Tirada Dadka ee Qoyska',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomField(
                controller: _numberOfPeopleController,
                keyboardType: TextInputType.number,
                labelText: 'Tirada Dadka',
                hintText: 'Geli tirada dadka ee qoyska',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fadlan geli tirada dadka';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Fadlan geli tiro sax ah (ugu yaraan 1)';
                  }
                  return null;
                },
                onChanged: (value) {
                  ref.read(numberOfPeopleProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 30),

              // Calculate Button
              Center(
                child: CustomButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      final zakatFitrViewModel = ref.read(
                        zakatFitrViewModelProvider,
                      );
                      final result = zakatFitrViewModel.calculateZakatFitr();

                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: AppColors.backgroundLight,
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.calculate,
                                    color: AppColors.primaryGold,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Natiijada Zakada Fitr',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSuccess,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.rice_bowl,
                                      size: 48,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tirada Dadka: ${result['numberOfPeople']} qof',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Wadarta Bariiska: ${result['totalRice']} kg',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundInfo,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Xasuusnow: Waa in la bixiyaa ka hor inta aan la bilaaban salaada Ciidka',
                                        style: const TextStyle(
                                          fontSize: 14,
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
                  text: 'Xisaabi Zakada Fitr',
                ),
              ),
              const SizedBox(height: 20),

              // Additional Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Macluumaad Dheeraad ah',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Zakada Fitr waxaa lagu bixiyaa bariis, burr, timir, ama cunto kale oo aasaasi ah\n'
                      '• Saxaabadu waxay bixin jireen Zakat al-Fitr iyadoo ah cunto (sida timir, galley, ama qamadi), sida uu Nabigu ﷺ faray. Sidaas darteed, Zakat al-Fitr asalkeeda waa in lagu bixiyaa cunto, ma aha lacag.\n'
                      '• Waa in la siiyaa masaakiinta iyo kuwa baahan ka hor Ciidka',
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
}
