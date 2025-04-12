import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_key.dart';

class ZakatService {
  static final String _apiKey = goldApiKey;
  static const String _baseUrl = 'https://www.goldapi.io/api';

  Future<Map<String, double>> fetchMetalPrices() async {
    try {
      // Fetch 24K gold in grams
      final goldResponse = await http.get(
        Uri.parse('$_baseUrl/XAU/USD'),
        headers: {
          'x-access-token': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (goldResponse.statusCode != 200) {
        throw Exception('Gold API error: ${goldResponse.statusCode}');
      }

      final goldData = jsonDecode(goldResponse.body);
      final goldPriceGram24k = (goldData['price_gram_24k'] as num?)?.toDouble();
      if (goldPriceGram24k == null) {
        throw Exception('Gold gram price (24k) not available');
      }

      // Fetch 999 silver in grams
      final silverResponse = await http.get(
        Uri.parse('$_baseUrl/XAG/USD'),
        headers: {
          'x-access-token': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (silverResponse.statusCode != 200) {
        throw Exception('Silver API error: ${silverResponse.statusCode}');
      }

      final silverData = jsonDecode(silverResponse.body);
      double silverPriceGram999;

      if (silverData.containsKey('price_gram_999')) {
        silverPriceGram999 = (silverData['price_gram_999'] as num).toDouble();
      } else if (silverData.containsKey('price')) {
        // fallback: convert troy ounce to gram (1 troy ounce = 31.1035 grams)
        silverPriceGram999 = (silverData['price'] as num).toDouble() / 31.1035;
      } else {
        throw Exception('Silver gram price (999) not available');
      }

      return {
        'goldGram24k': goldPriceGram24k,
        'silverGram999': silverPriceGram999,
      };
    } catch (e) {
      throw Exception('Failed to fetch metal prices: $e');
    }
  }
}
