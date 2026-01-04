import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/database/tables.dart';
import 'currency_provider.dart';

class StatisticsProvider extends ChangeNotifier {
  final AppDatabase _database;
  
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<CategoryStats> _expensesByCategory = [];
  List<CategoryStats> _incomeByCategory = [];
  bool _isLoading = false;

  StatisticsProvider(this._database);

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;
  List<CategoryStats> get expensesByCategory => _expensesByCategory;
  List<CategoryStats> get incomeByCategory => _incomeByCategory;
  bool get isLoading => _isLoading;

  Future<void> loadMonthlyStats(
    DateTime month, 
    CurrencyProvider currencyProvider, 
    String targetCurrency,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    await _loadStats(start, end, currencyProvider, targetCurrency);
  }

  Future<void> loadYearlyStats(
    int year,
    CurrencyProvider currencyProvider,
    String targetCurrency,
  ) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    await _loadStats(start, end, currencyProvider, targetCurrency);
  }

  Future<void> loadCustomStats(
    DateTime start, 
    DateTime end,
    CurrencyProvider currencyProvider,
    String targetCurrency,
  ) async {
    await _loadStats(start, end, currencyProvider, targetCurrency);
  }

  Future<void> _loadStats(
    DateTime start, 
    DateTime end,
    CurrencyProvider currencyProvider,
    String targetCurrency,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Fetch all transactions in range
    final transactions = await _database.getTransactionsByDateRange(start, end);
    
    double income = 0;
    double expense = 0;
    final Map<String, double> expenseMap = {};
    final Map<String, double> incomeMap = {};
    final Map<String, Map<String, double>> expenseOriginalMap = {};
    final Map<String, Map<String, double>> incomeOriginalMap = {};

    // Get categories to map IDs to names
    final categories = await _database.getAllCategories();
    final categoryMap = {for (var c in categories) c.id: c.name};

    for (final t in transactions) {
      final convertedAmount = await currencyProvider.convert(
        t.amount, 
        t.currency, 
        targetCurrency,
      );
      final catName = categoryMap[t.categoryId] ?? 'Unknown';

      if (t.type == TransactionType.income) {
        income += convertedAmount;
        incomeMap[catName] = (incomeMap[catName] ?? 0) + convertedAmount;
        
        incomeOriginalMap.putIfAbsent(catName, () => {});
        incomeOriginalMap[catName]![t.currency] = 
            (incomeOriginalMap[catName]![t.currency] ?? 0) + t.amount;
      } else {
        expense += convertedAmount;
        expenseMap[catName] = (expenseMap[catName] ?? 0) + convertedAmount;
        
        expenseOriginalMap.putIfAbsent(catName, () => {});
        expenseOriginalMap[catName]![t.currency] = 
            (expenseOriginalMap[catName]![t.currency] ?? 0) + t.amount;
      }
    }

    _totalIncome = income;
    _totalExpense = expense;
    
    _expensesByCategory = expenseMap.entries
        .map((e) => CategoryStats(
          categoryName: e.key, 
          total: e.value,
          originalAmounts: expenseOriginalMap[e.key] ?? {},
        ))
        .toList();
        
    _incomeByCategory = incomeMap.entries
        .map((e) => CategoryStats(
          categoryName: e.key, 
          total: e.value,
          originalAmounts: incomeOriginalMap[e.key] ?? {},
        ))
        .toList();

    _isLoading = false;
    notifyListeners();
  }
}
