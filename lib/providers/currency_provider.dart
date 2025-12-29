import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final AppDatabase _database;
  final CurrencyService _currencyService;
  
  Map<String, double> _rates = {};
  bool _isLoading = false;
  DateTime? _lastUpdate;

  CurrencyProvider(this._database, this._currencyService);

  Map<String, double> get rates => _rates;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdate => _lastUpdate;

  Future<void> updateRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rates = await _currencyService.fetchExchangeRates();
      _lastUpdate = DateTime.now();

      // Save to database
      for (final entry in _rates.entries) {
        await _database.insertCurrencyRate(
          CurrencyRatesCompanion.insert(
            currency: entry.key,
            rate: entry.value,
            date: _lastUpdate!,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating rates: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<double> convert(double amount, String from, String to) async {
    if (_rates.isEmpty) {
      await updateRates();
    }
    return await _currencyService.convertCurrency(amount, from, to, _rates);
  }
}
