import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/zakat_providers.dart';

final zakatAgricultureViewModelProvider = Provider<ZakatAgricultureViewModel>(
  (ref) => ZakatAgricultureViewModel(ref),
);

class ZakatAgricultureViewModel {
  final Ref ref;
  ZakatAgricultureViewModel(this.ref);

  /// Calculates Agricultural Zakat based on Islamic jurisprudence
  /// Nisab: ~653 kg (5 wasq = 300 sa')
  /// Rates: 10% (rain-fed), 5% (irrigated), 7.5% (mixed)
  Map<String, dynamic> calculateAgriculturalZakat() {
    final cropWeightStr = ref.read(cropWeightProvider);
    final irrigationType = ref.read(irrigationTypeProvider);
    final cropType = ref.read(cropTypeProvider);
    
    final double cropWeight = double.tryParse(cropWeightStr) ?? 0;
    const double nisabThreshold = 653; // kg (5 wasq)
    
    // Determine zakat rate based on irrigation type
    double zakatRate = 0;
    String irrigationDescription = '';
    
    switch (irrigationType) {
      case 'Roob': // Rain-fed
        zakatRate = 0.10; // 10%
        irrigationDescription = 'Roobka iyo biyaha dabiiciga ah';
        break;
      case 'Waraabka': // Irrigated
        zakatRate = 0.05; // 5%
        irrigationDescription = 'Waraabka iyo dadaalka aadanaha';
        break;
      case 'Isku-dhafan': // Mixed
        zakatRate = 0.075; // 7.5%
        irrigationDescription = 'Isku-dhafan (roob iyo waraab)';
        break;
      default:
        zakatRate = 0.10;
        irrigationDescription = 'Roobka iyo biyaha dabiiciga ah';
    }
    
    // Check if nisab is reached
    bool nisabReached = cropWeight >= nisabThreshold;
    double zakatAmount = nisabReached ? cropWeight * zakatRate : 0;
    
    return {
      'cropWeight': cropWeight,
      'cropType': cropType,
      'irrigationType': irrigationType,
      'irrigationDescription': irrigationDescription,
      'zakatRate': zakatRate,
      'zakatRatePercentage': (zakatRate * 100).toInt(),
      'nisabThreshold': nisabThreshold,
      'nisabReached': nisabReached,
      'zakatAmount': zakatAmount,
      'unit': 'kg',
    };
  }
  
  /// Gets information about Agricultural Zakat requirements
  Map<String, dynamic> getAgriculturalZakatInfo() {
    return {
      'description': 'Zakada Beeraha waa zakaa waajib ah oo lagu bixiyo wax-soo-saarka dhulka.',
      'nisabInfo': 'Heerka ugu yar: ~653 kg (5 wasaq = 300 sac)',
      'requirements': [
        'In wax-soo-saarka gaaro ama dhaafto 653 kg',
        'In ay tahay cunto la kaydin karo (sida sarreen, shaciir, timir)',
        'In la bixiyo maalinta la goosanayo',
        'In milkiilaha dhulku uu leeyahay wax-soo-saarka',
      ],
      'rates': {
        'rainFed': {
          'percentage': 10,
          'description': 'Roobka iyo biyaha dabiiciga ah - 10%',
          'details': 'Haddii dhulka lagu waraabayo roob ama biyo dabiici ah'
        },
        'irrigated': {
          'percentage': 5,
          'description': 'Waraabka dadaalka aadanaha - 5%',
          'details': 'Haddii dhulka lagu waraabayo dadaal iyo qalabka aadanaha'
        },
        'mixed': {
          'percentage': 7.5,
          'description': 'Isku-dhafan - 7.5%',
          'details': 'Haddii labada hab waraabka la isticmaalo'
        }
      },
      'timing': 'Maalinta la goosanayo wax-soo-saarka',
      'eligibleCrops': [
        'Sarreen (Wheat)',
        'Shaciir (Barley)', 
        'Bariis (Rice)',
        'Galley (Corn)',
        'Timir (Dates)',
        'Canab (Grapes - haddii la qalaliyo)'
      ],
      'islamicBasis': {
        'quran': 'Surah Al-An\'am 6:141 - "Bixiya xaqqiisa maalinta la goosanayo"',
        'hadith': 'Sahih Bukhari 1483 - Boqolkiiba toban waxa roobku waraabayo, boqolkiiba shan waxa dadaalku waraabayo'
      }
    };
  }
  
  /// Validates crop weight input
  bool isValidCropWeight(String weight) {
    if (weight.isEmpty) return false;
    final double? parsed = double.tryParse(weight);
    return parsed != null && parsed >= 0;
  }
  
  /// Gets crop types in Somali
  List<Map<String, String>> getCropTypes() {
    return [
      {'value': 'Sarreen', 'label': 'Sarreen (Wheat)'},
      {'value': 'Shaciir', 'label': 'Shaciir (Barley)'},
      {'value': 'Bariis', 'label': 'Bariis (Rice)'},
      {'value': 'Galley', 'label': 'Galley (Corn)'},
      {'value': 'Timir', 'label': 'Timir (Dates)'},
      {'value': 'Canab', 'label': 'Canab (Grapes)'},
    ];
  }
  
  /// Gets irrigation types in Somali
  List<Map<String, String>> getIrrigationTypes() {
    return [
      {'value': 'Roob', 'label': 'Roob (Rain-fed) - 10%'},
      {'value': 'Waraabka', 'label': 'Waraabka (Irrigated) - 5%'},
      {'value': 'Isku-dhafan', 'label': 'Isku-dhafan (Mixed) - 7.5%'},
    ];
  }
}