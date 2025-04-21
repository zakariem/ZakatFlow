import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/zakat_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../viewmodels/zakat/zakat_view_model.dart';

class ZakatSummaryCard extends ConsumerWidget {
  final Map<String, double> metalPrices;

  const ZakatSummaryCard({super.key, required this.metalPrices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            '• Marka la adeegsado Qalin (595 garaam) ≈  \$${nisab['silver']?.toStringAsFixed(2) ?? "N/A"}\n'
            '• Marka la adeegsado Dahab (85 garaam) ≈  \$${nisab['gold']?.toStringAsFixed(2) ?? "N/A"}\n\n'
            'Zakaat bixi oo keliya haddii hantidaada saafi ah ay ka badan tahay mid ka mid ah qiimayaashan.',
          ),
        ],
      ),
    );
  }
}
