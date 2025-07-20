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
          'Sida Zakaatul Maalka loo xisaabiyo iyadoo la raacayo Shareecada Islaamka...',
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
            '📿 Qaddarka Zakat al-Maal ee Dahabka iyo Qalinka (Shareecada Islaamka)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zakat al-Maal waxaa laga bixiyaa marka hantida qofka Muslimka ah gaarto nisab (ugu yaraan xadka waajibka ah) oo uu haysto sanad hijri ah oo buuxa.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Waxaa ku salaysan Xadiisyada Rasuulka ﷺ, gaar ahaan xadiisyada laga weriyey Abuu Hurayrah, Caa\'isha, iyo Cali bin Abii Daalib.',
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ 1. Dahab (Gold) – Nisab: 85 gram',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Xadiis: "Lama jiro zakat dahab ilaa uu gaaro 20 mithqal..." (Sunan Abu Dawud, no. 1567, saxiix)\n'
            '20 mithqal ≈ 85 gram oo dahab ah.\n'
            'Marka dahabkaaga gaaro ama dhaafo 85g oo aad haysatay muddo 1 sanad hijri ah:\n'
            '2.5% (1/40) in aad ka bixiso zakat.',
          ),
          const SizedBox(height: 8),
          const Text(
            '🧮 Tusaale Dahab:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Haddii aad haysato 100g dahab:\n'
            'Zakat: 100 × 2.5% = 2.5g dahab',
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ 2. Qalin (Silver) – Nisab: 595 gram',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Xadiis: "Zakada qalinka waa marka ay gaarto 200 dirham..." (Sunan Ibn Majah, no. 1791, saxiix)\n'
            '200 dirham ≈ 595 gram oo qalinka ah.\n'
            'Haddii aad haysato 595g ama ka badan oo qalinka ah muddo sanad ah:\n'
            'Waxaa waajib ah in aad bixiso 2.5% zakat.',
          ),
          const SizedBox(height: 8),
          const Text(
            '🧮 Tusaale Qalin:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Haddii aad haysato 600g silver:\n'
            'Zakat: 600 × 2.5% = 15g silver',
          ),
          const SizedBox(height: 12),
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
            'Hanti Saafi ah = Wadarta Hantida – Deymaha la jarayo\n'
            'Zakaatul Maal = 2.5% ee hantida saafi ah (keliya haddii ay ka badan tahay nisabka)',
          ),
          const SizedBox(height: 8),
          const Text(
            '📉 Xadka Nisabka (Maanta):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(
            '• Dahab (85 garaam) ≈ \$${nisab['gold']?.toStringAsFixed(2) ?? "N/A"}\n'
            '• Qalin (595 garaam) ≈ \$${nisab['silver']?.toStringAsFixed(2) ?? "N/A"}\n\n'
            'Zakaat bixi haddii hantidaada saafi ah ay ka badan tahay mid ka mid ah qiimahan.',
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Fiiro Gaar ah:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Dadka badankood maanta waxay xisaabiyaan nisabka iyadoo lagu saleynayo qiimaha dahabka ama qalinka suuqa (waxaa kala duwan):\n'
            '• Dahabku wuu qaalisan yahay, qalinkuna waa jaban yahay.\n'
            '• Qofka raba in uu naftiisa ku adkeeyo wuxuu xisaabiyaa zakada ku saleysan silver (si ay u waajibto horay).\n'
            '• Qofka raba raxmad wuxuu isticmaalaa dahabka (waayo waa nisab sare, way adagtahay in la gaaro).',
          ),
          const SizedBox(height: 8),
          const Text(
            '✅ Gunaanad:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SelectableText(
            'Hanti | Nisab (miisaan) | Zakat % | Qaddarka laga bixinayo\n'
            'Dahab (Gold) | 85g | 2.5% | 2.125g zakat (marka la gaaro)\n'
            'Qalin (Silver) | 595g | 2.5% | 14.875g zakat (marka la gaaro)',
          ),
        ],
      ),
    );
  }
}
