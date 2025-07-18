import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/zakat_providers.dart';

final zakatFitrViewModelProvider = Provider<ZakatFitrViewModel>(
  (ref) => ZakatFitrViewModel(ref),
);

class ZakatFitrViewModel {
  final Ref ref;
  ZakatFitrViewModel(this.ref);

  /// Calculates Zakat al-Fitr based on the number of people
  /// Each person requires 2.5 kg of rice (or equivalent staple food)
  Map<String, dynamic> calculateZakatFitr() {
    // Get the number of people from the provider
    final numberOfPeopleStr = ref.read(numberOfPeopleProvider);
    final numberOfPeople = int.tryParse(numberOfPeopleStr) ?? 1;
    
    // Standard amount per person is 2.5 kg of rice
    const double ricePerPerson = 2.5;
    
    // Calculate total rice needed
    final double totalRice = numberOfPeople * ricePerPerson;
    
    return {
      'numberOfPeople': numberOfPeople,
      'ricePerPerson': ricePerPerson,
      'totalRice': totalRice,
      'unit': 'kg',
      'foodType': 'bariis', // rice in Somali
    };
  }
  
  /// Gets information about Zakat al-Fitr requirements
  Map<String, dynamic> getZakatFitrInfo() {
    return {
      'description': 'Zakada Fitr waa zakaa waajib ah oo lagu bixiyo dhammaadka bisha Ramadaan.',
      'requirements': [
        'In aad Muslim tahay',
        'In aad nool tahay maalinta Ciidka',
        'In aad awood u leedahay (ma ahayn sabool)',
        'In aad leedahay cunto ku filan maalinta iyo habeenka',
      ],
      'amount': '2.5 kg bariis qof kasta',
      'timing': 'Ka hor inta aan la bilaaban salaada Ciidka',
      'alternatives': [
        'Bariis',
        'Burr',
        'Timir',
        'Cunto kale oo aasaasi ah',
      ],
    };
  }
  
  /// Validates if the number of people is valid
  bool isValidNumberOfPeople(String value) {
    final number = int.tryParse(value);
    return number != null && number > 0;
  }
  
  /// Gets the monetary equivalent if someone prefers to pay in cash
  /// This would need to be updated based on local rice prices
  Map<String, dynamic> getMonetaryEquivalent(double ricePrice) {
    final numberOfPeopleStr = ref.read(numberOfPeopleProvider);
    final numberOfPeople = int.tryParse(numberOfPeopleStr) ?? 1;
    const double ricePerPerson = 2.5;
    final double totalRice = numberOfPeople * ricePerPerson;
    final double totalCost = totalRice * ricePrice;
    
    return {
      'totalRice': totalRice,
      'pricePerKg': ricePrice,
      'totalCost': totalCost,
      'currency': 'USD', // or local currency
    };
  }
}