import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/zakat_providers.dart';

final zakatViewModelProvider = Provider<ZakatViewModel>(
  (ref) => ZakatViewModel(ref),
);

class ZakatViewModel {
  final Ref ref;
  ZakatViewModel(this.ref);

  static const double SHEEP_PRICE = 20;
  static const double CAMEL_PRICE = 500;
  static const double COW_PRICE = 150;

  double calculateZakat(Map<String, double> metalPrices) {
    final basis = ref.read(basisProvider);

    double goldInput = double.tryParse(ref.read(goldValueProvider)) ?? 0;
    double silverInput = double.tryParse(ref.read(silverValueProvider)) ?? 0;
    final goldPricePerGram = metalPrices['goldGram24k'] ?? 0;
    final silverPricePerGram = metalPrices['silverGram999'] ?? 0;
    double goldValue = goldInput * goldPricePerGram;
    double silverValue = silverInput * silverPricePerGram;
    final cash = double.tryParse(ref.read(cashValueProvider)) ?? 0;
    final deposited = double.tryParse(ref.read(depositedProvider)) ?? 0;
    final loans = double.tryParse(ref.read(loansProvider)) ?? 0;
    final investments = double.tryParse(ref.read(investmentsProvider)) ?? 0;
    final stock = double.tryParse(ref.read(stockProvider)) ?? 0;

    final assets =
        goldValue +
        silverValue +
        cash +
        deposited +
        loans +
        investments +
        stock;

    final borrowed = double.tryParse(ref.read(borrowedProvider)) ?? 0;
    final wages = double.tryParse(ref.read(wagesProvider)) ?? 0;
    final taxes = double.tryParse(ref.read(taxesProvider)) ?? 0;
    final liabilities = borrowed + wages + taxes;

    double netAssets = assets - liabilities;
    double baseZakat = 0;

    if (basis == 'Gold') {
      if (netAssets >= (85 * goldPricePerGram)) {
        baseZakat = netAssets * 0.025;
      }
    } else {
      if (netAssets >= (595 * silverPricePerGram)) {
        baseZakat = netAssets * 0.025;
      }
    }

    double animalZakat = 0;
    double camelCount = double.tryParse(ref.read(camelValueProvider)) ?? 0;
    double cowCount = double.tryParse(ref.read(cowValueProvider)) ?? 0;
    double sheepCount = double.tryParse(ref.read(sheepValueProvider)) ?? 0;

    animalZakat += _calculateCamelZakat(camelCount);
    animalZakat += _calculateCowZakat(cowCount);
    animalZakat += _calculateSheepZakat(sheepCount);

    return baseZakat + animalZakat;
  }

  Map<String, double> getNisabThresholds(Map<String, double> metalPrices) {
    final goldPrice = metalPrices['goldGram24k'] ?? 0;
    final silverPrice = metalPrices['silverGram999'] ?? 0;
    return {'gold': goldPrice * 85, 'silver': silverPrice * 595};
  }

  double _calculateCamelZakat(double count) {
    if (count < 5) return 0;

    if (count >= 5 && count < 10) return 1 * SHEEP_PRICE;

    if (count >= 10 && count < 15) return 2 * SHEEP_PRICE;

    if (count >= 15 && count < 20) return 3 * SHEEP_PRICE;

    if (count >= 20 && count < 25) return 4 * SHEEP_PRICE;

    if (count >= 25 && count < 36) return CAMEL_PRICE;

    return ((count / 25).floor()) * CAMEL_PRICE;
  }

  double _calculateCowZakat(double count) {
    if (count < 30) return 0;

    int units = ((count - 30) ~/ 10) + 1;
    return units * COW_PRICE;
  }

  double _calculateSheepZakat(double count) {
    if (count < 40) return 0;

    if (count <= 120) return 1 * SHEEP_PRICE;
    if (count <= 200) return 2 * SHEEP_PRICE;

    int extraUnits = ((count - 200) ~/ 100) + 2;
    return extraUnits * SHEEP_PRICE;
  }
}
