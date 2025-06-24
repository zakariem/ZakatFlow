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
          'Sida Zakaatul Maalka loo xisaabiyo iyadoo la raacayo habka dhaqanka Soomaaliyeed...',
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
            '💡 Habka Xisaabinta Zakaatul Maal (Dhaqanka Soomaaliyeed)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zakaatul Maal ee dhaqanka Soomaaliyeed waxaa lagu xisaabiyaa 10% marka hantidaadu gaarto qiimaha 200g ee qalinka (silver). Tani waa hab sahlan oo dad badan ay fahmaan.',
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ Waxa La Xisaabinayo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '• Lacagta caddaanka ah, dahabka, ganacsiga iyo wixii la mid ah\n'
            '• Waa in hantidu gaarto ama dhaafto qiimaha 200 garaam ee qalinka\n'
            '• Muddada haynta: ugu yaraan 1 sannad dayaxeed',
          ),
          const SizedBox(height: 8),
          const Text(
            '➖ Waxa La Ka Jarayo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SelectableText(
            '• Deymaha degdegga ah ee la bixinayo sanadkan\n'
            '• Kharashaadka daruuriga ah ee la qorsheeyay\n\n'
            'Fiiro gaar ah: Deymaha aan caddayn ama aan degdeg ahayn lama jarayo.',
          ),
          const SizedBox(height: 8),
          const Text(
            '🧮 Qaaciddada Hantida Saafi ah:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Hanti Saafi ah = Wadarta Hantida – Deymaha la jarayo\nZakaatul Maal = 10% ee hantida saafi ah (keliya haddii ay ka badan tahay 200g qalinka)',
          ),
          const SizedBox(height: 8),
          const Text(
            '📉 Xadka Dhaqameed ee Nisabka:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(
            '• Marka la adeegsado Qalin (200 garaam) ≈  \$${nisab['silver']?.toStringAsFixed(2) ?? "N/A"}\n\n'
            'Zakaat bixi haddii hantidaada saafi ah ay ka badan tahay qiimahan.',
          ),
          const SizedBox(height: 8),
          const Text(
            '📌 Fiiro Gaar ah:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '• Habkan dhaqameed wuxuu fududeeyaa xisaabinta Zakaatul Maalka.\n'
            '• Waxaa lagu talinayaa in laga bilaabo marka hantidaadu gaarto qiimaha 200g ee qalinka.\n'
            '• Tusaale ahaan: haddii aad haysato \$400 → Zakaatul Maalkaagu waa \$40 (10%).',
          ),
        ],
      ),
    );
  }
}
