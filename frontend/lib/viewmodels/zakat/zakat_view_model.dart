import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/zakat_providers.dart';

final zakatViewModelProvider = Provider<ZakatViewModel>(
  (ref) => ZakatViewModel(ref),
);

class ZakatViewModel {
  final Ref ref;
  ZakatViewModel(this.ref);

  Map<String, dynamic> calculateZakat(Map<String, double> metalPrices) {
    final basis = ref.read(basisProvider);

    // Retrieve input values for gold and silver
    double goldInput = double.tryParse(ref.read(goldValueProvider)) ?? 0;
    double silverInput = double.tryParse(ref.read(silverValueProvider)) ?? 0;
    final goldPricePerGram = metalPrices['goldGram24k'] ?? 0;
    final silverPricePerGram = metalPrices['silverGram999'] ?? 0;
    double goldValue = goldInput * goldPricePerGram;
    double silverValue = silverInput * silverPricePerGram;

    // Retrieve cash and other asset values
    final cash = double.tryParse(ref.read(cashValueProvider)) ?? 0;
    final deposited = double.tryParse(ref.read(depositedProvider)) ?? 0;
    final loans = double.tryParse(ref.read(loansProvider)) ?? 0;
    final investments = double.tryParse(ref.read(investmentsProvider)) ?? 0;
    final stock = double.tryParse(ref.read(stockProvider)) ?? 0;
    double assets =
        goldValue +
        silverValue +
        cash +
        deposited +
        loans +
        investments +
        stock;

    // Retrieve liabilities values
    final borrowed = double.tryParse(ref.read(borrowedProvider)) ?? 0;
    final wages = double.tryParse(ref.read(wagesProvider)) ?? 0;
    final taxes = double.tryParse(ref.read(taxesProvider)) ?? 0;
    double liabilities = borrowed + wages + taxes;

    double netAssets = assets - liabilities;
    double financialZakat = 0;

    // Determine whether to use the gold or silver nisab threshold
    if (basis == 'Dahab') {
      final goldNisab = 85 * goldPricePerGram;
      if (netAssets >= goldNisab) {
        financialZakat = netAssets * 0.025;
      }
    } else {
      final silverNisab = 595 * silverPricePerGram;
      if (netAssets >= silverNisab) {
        financialZakat = netAssets * 0.025;
      }
    }

    // Calculate zakat for livestock
    double camelCount = double.tryParse(ref.read(camelValueProvider)) ?? 0;
    double cowCount = double.tryParse(ref.read(cowValueProvider)) ?? 0;
    double sheepCount = double.tryParse(ref.read(sheepValueProvider)) ?? 0;
    String camelZakat = _calculateCamelZakat(camelCount);
    String cowZakat = _calculateCowZakat(cowCount);
    String sheepZakat = _calculateSheepZakat(sheepCount);

    return {
      'financialZakat': financialZakat,
      'nisabThresholds': getNisabThresholds(metalPrices),
      'netAssets': netAssets,
      'animalZakat': {
        'camels': camelZakat,
        'cows': cowZakat,
        'sheep': sheepZakat,
      },
    };
  }

  Map<String, double> getNisabThresholds(Map<String, double> metalPrices) {
    final goldPrice = metalPrices['goldGram24k'] ?? 0;
    final silverPrice = metalPrices['silverGram999'] ?? 0;
    return {'gold': 85 * goldPrice, 'silver': 595 * silverPrice};
  }

  String _calculateCamelZakat(double count) {
    if (count < 5) return 'Zakada lama rabo (ma jirto zakaa la bixinayo)';
    if (count >= 5 && count < 10) return '1 ido ama 1 ari';
    if (count >= 10 && count < 15) return '2 ido ama 2 ari';
    if (count >= 15 && count < 20) return '3 ido ama 3 ari';
    if (count >= 20 && count < 25) return '4 ido ama 4 ari';
    if (count >= 25 && count < 36) {
      return '1 neef geel dhedig ah oo hal sano jirsatay (bint makaad)';
    }
    if (count >= 36 && count < 46) {
      return '1 neef geel dhedig ah oo laba sano jirsatay (bint laboon)';
    }
    if (count >= 46 && count < 61) {
      return '1 neef geel dhedig ah oo saddex sano jirsatay (hiqqa)';
    }
    if (count >= 61 && count < 76) {
      return '1 neef geel dhedig ah oo afar sano jirsatay (jadh’a)';
    }
    if (count >= 76 && count < 91) {
      return '2 neef geel dhedig ah oo laba sano jirsatay';
    }
    if (count >= 91 && count < 121) {
      return '2 neef geel dhedig ah oo saddex sano jirsatay';
    }

    int extra = ((count - 120) / 40).floor();
    return 'Zakada waa ${extra + 3} neef geel (hal neef 40 kii neefba kadib)';
  }

  String _calculateCowZakat(double count) {
    if (count < 30) return 'ma jirto zakaa la bixinayo';

    int tabaahCount = 0;
    int musinnahCount = 0;

    // Start calculation for each range
    if (count >= 30 && count <= 39) {
      tabaahCount = 1;
    } else if (count >= 40 && count <= 59) {
      musinnahCount = 1;
    } else if (count >= 60 && count <= 69) {
      tabaahCount = 2;
    } else if (count >= 70 && count <= 79) {
      tabaahCount = 1;
      musinnahCount = 1;
    } else if (count >= 80 && count <= 89) {
      musinnahCount = 2;
    } else if (count >= 90 && count <= 99) {
      tabaahCount = 3;
    } else if (count >= 100 && count <= 109) {
      tabaahCount = 2;
      musinnahCount = 1;
    } else if (count >= 110 && count <= 119) {
      tabaahCount = 1;
      musinnahCount = 2;
    } else if (count >= 120) {
      double remaining = count - 120;
      tabaahCount =
          (remaining / 30).floor() +
          4; // 4 taba'ahs for the first 120 cows, then 1 taba'ah for each 30 extra cows
      musinnahCount = (remaining / 30).floor() + 3; // Similarly for musinnahs
    }

    // Return zakat calculation in Af-Soomaali
    if (tabaahCount > 0 && musinnahCount > 0) {
      return '$tabaahCount taba’ah iyo $musinnahCount musinnah';
    } else if (tabaahCount > 0) {
      return '$tabaahCount taba’ah';
    } else if (musinnahCount > 0) {
      return '$musinnahCount musinnah';
    } else {
      return 'Xisaabinta zakada ee tiradan lama fulin';
    }
  }

  String _calculateSheepZakat(double count) {
    if (count < 40) return 'ma jirto zakaa la bixinayo';
    if (count <= 120) return '1 ido ama 1 ari';
    if (count <= 200) return '2 ido ama 2 ari';
    int extra = ((count - 200) ~/ 100);
    return '${2 + extra} sheep';
  }
}
