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
    if (basis == 'Gold') {
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
    if (count < 5) return 'No zakat due';
    if (count >= 5 && count < 10) return '1 sheep';
    if (count >= 10 && count < 15) return '2 sheep';
    if (count >= 15 && count < 20) return '3 sheep';
    if (count >= 20 && count < 25) return '4 sheep';
    if (count >= 25 && count < 36) return '1 camel';
    if (count >= 36 && count < 46) return '2 camels';
    if (count >= 46 && count < 56) return '3 camels';
    int extra = ((count - 55) / 10).floor();
    return '${3 + extra} camels';
  }

  String _calculateCowZakat(double count) {
    if (count < 30) return 'No zakat due';
    if (count >= 30 && count <= 39) return '1 taba’ah';
    if (count >= 40 && count <= 59) return '1 musinnah';
    if (count >= 60 && count <= 69) return '2 taba’ahs';
    if (count >= 70 && count <= 79) return '1 taba’ah and 1 musinnah';
    if (count >= 80 && count <= 89) return '2 musinnah';
    if (count >= 90 && count <= 99) return '3 taba’ahs';
    if (count >= 100 && count <= 109) return '2 taba’ahs and 1 musinnah';
    if (count >= 110 && count <= 119) return '1 taba’ah and 2 musinnah';
    if (count >= 120 && count <= 129) return 'Either 4 taba’ahs or 3 musinnah';
    return 'Zakat calculation for this number not implemented';
  }

  String _calculateSheepZakat(double count) {
    if (count < 40) return 'No zakat due';
    if (count <= 120) return '1 sheep';
    if (count <= 200) return '2 sheep';
    int extra = ((count - 200) ~/ 100);
    return '${2 + extra} sheep';
  }
}
