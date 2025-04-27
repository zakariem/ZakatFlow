import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../viewmodels/zakat/zakat_xoolaha_viewmodel.dart';

class ZakaatulXoolaha extends ConsumerStatefulWidget {
  const ZakaatulXoolaha({super.key});

  @override
  ConsumerState<ZakaatulXoolaha> createState() => _ZakaatulXoolahaState();
}

class _ZakaatulXoolahaState extends ConsumerState<ZakaatulXoolaha> {
  final formKey = GlobalKey<FormState>();
  final Map<StateProvider<String>, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final providers = [
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.03,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWarning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Fiiro Gaar ah: Ma bixin karno xoolaha adiga kugu saaran Zakaatul-Maalka. Halkan waxaad kaliya ka xisaabin kartaa tirada Zakaatul-Xoolaha ee kugu waajibay.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Input Fields
              buildTextField(
                label: 'Tirada Geela (Camels)',
                provider: camelValueProvider,
              ),
              const SizedBox(height: 18),

              buildTextField(
                label: 'Tirada Lo\'da (Cows)',
                provider: cowValueProvider,
              ),
              const SizedBox(height: 18),

              buildTextField(
                label: 'Tirada Ido (Sheep)',
                provider: sheepValueProvider,
              ),
              const SizedBox(height: 30),

              // Button
              Center(
                child: CustomButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      final zakatViewModel = ref.read(
                        zakatXoolahaViewModelProvider,
                      );
                      final result = zakatViewModel.calculateLivestockZakat();

                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: AppColors.backgroundLight,
                              title: const Text(
                                'Natiijada Zakaatul-Xoolaha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                              content: Text(
                                '🐪 Geela (Camels): ${result['camels']}\n'
                                '🐄 Lo\'da (Cows): ${result['cows']}\n'
                                '🐑 Ido (Sheep): ${result['sheep']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryGold,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  text: 'Xisaabi Zakaatul-Xoolaha',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required StateProvider<String> provider,
  }) {
    return CustomField(
      controller: controllers[provider]!,
      keyboardType: TextInputType.number,
      labelText: label,
      hintText: 'Geli $label',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Fadlan geli $label';
        }
        if (double.tryParse(value) == null) {
          return 'Fadlan geli tiro sax ah';
        }
        return null;
      },
      onChanged: (value) {
        ref.read(provider.notifier).state = value;
      },
    );
  }
}
