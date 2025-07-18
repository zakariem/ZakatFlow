import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/zakat_service.dart';

final storage = FlutterSecureStorage();

final basisProvider = StateProvider<String>((ref) => 'Qalin');
final goldValueProvider = StateProvider<String>((ref) => '0');
final silverValueProvider = StateProvider<String>((ref) => '0');
final cashValueProvider = StateProvider<String>((ref) => '0');
final camelValueProvider = StateProvider<String>((ref) => '0');
final cowValueProvider = StateProvider<String>((ref) => '0');
final sheepValueProvider = StateProvider<String>((ref) => '0');
final depositedProvider = StateProvider<String>((ref) => '0');
final loansProvider = StateProvider<String>((ref) => '0');
final investmentsProvider = StateProvider<String>((ref) => '0');
final stockProvider = StateProvider<String>((ref) => '0');
final borrowedProvider = StateProvider<String>((ref) => '0');
final wagesProvider = StateProvider<String>((ref) => '0');
final taxesProvider = StateProvider<String>((ref) => '0');
final showMoreSummaryProvider = StateProvider<bool>((ref) => false);

// Zakat al-Fitr provider
final numberOfPeopleProvider = StateProvider<String>((ref) => '1');

// Agricultural Zakat providers
final cropWeightProvider = StateProvider<String>((ref) => '');
final irrigationTypeProvider = StateProvider<String>((ref) => 'Roob'); // Rain-fed by default
final cropTypeProvider = StateProvider<String>((ref) => 'Sarreen'); // Wheat by default

void resetZakatProviders(WidgetRef ref) {
  ref.invalidate(basisProvider);
  ref.invalidate(goldValueProvider);
  ref.invalidate(silverValueProvider);
  ref.invalidate(cashValueProvider);
  ref.invalidate(camelValueProvider);
  ref.invalidate(cowValueProvider);
  ref.invalidate(sheepValueProvider);
  ref.invalidate(depositedProvider);
  ref.invalidate(loansProvider);
  ref.invalidate(investmentsProvider);
  ref.invalidate(stockProvider);
  ref.invalidate(borrowedProvider);
  ref.invalidate(wagesProvider);
  ref.invalidate(taxesProvider);
  ref.invalidate(showMoreSummaryProvider);
  ref.invalidate(numberOfPeopleProvider);
  ref.invalidate(cropWeightProvider);
  ref.invalidate(irrigationTypeProvider);
  ref.invalidate(cropTypeProvider);
  ref.invalidate(metalPricesProvider);
}


final metalPricesProvider = FutureProvider<Map<String, double>>((ref) async {
  const storageKey = 'metal_prices';
  const timestampKey = 'metal_prices_timestamp';

  final timestampStr = await storage.read(key: timestampKey);
  if (timestampStr != null) {
    final savedTime = DateTime.tryParse(timestampStr);
    if (savedTime != null) {
      final now = DateTime.now();
      final diff = now.difference(savedTime);

      if (diff.inHours < 24) {
        final storedJson = await storage.read(key: storageKey);
        if (storedJson != null) {
          final data = jsonDecode(storedJson);
          return {
            'goldGram24k': (data['goldGram24k'] as num).toDouble(),
            'silverGram999': (data['silverGram999'] as num).toDouble(),
          };
        }
      }
    }

    await storage.delete(key: storageKey);
    await storage.delete(key: timestampKey);
  }

  final service = ZakatService();
  final prices = await service.fetchMetalPrices();

  await storage.write(key: storageKey, value: jsonEncode(prices));
  await storage.write(
    key: timestampKey,
    value: DateTime.now().toIso8601String(),
  );

  return prices;
});
