import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _baseCurrency = 'USD';

  Future<Map<String, double>> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$_baseCurrency'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  Future<double> convertCurrency(
    double amount,
    String from,
    String to,
    Map<String, double> rates,
  ) async {
    if (from == to) return amount;
    
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    
    // Convert to base currency (USD) then to target currency
    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }
}
