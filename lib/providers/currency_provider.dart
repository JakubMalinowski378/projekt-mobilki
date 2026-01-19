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
    if (_isLoading) return;
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
      // Schedule update after the current frame to avoid calling notifyListeners during build
      Future.microtask(() => updateRates());
      // Return the unconverted amount if rates aren't loaded yet
      return amount;
    }
    return await _currencyService.convertCurrency(amount, from, to, _rates);
  }
}
