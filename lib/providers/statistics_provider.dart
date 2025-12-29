import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/database/tables.dart';

class StatisticsProvider extends ChangeNotifier {
  final AppDatabase _database;
  
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<CategoryStats> _expensesByCategory = [];
  bool _isLoading = false;

  StatisticsProvider(this._database);

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;
  List<CategoryStats> get expensesByCategory => _expensesByCategory;
  bool get isLoading => _isLoading;

  Future<void> loadMonthlyStats(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    await _loadStats(start, end);
  }

  Future<void> loadYearlyStats(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    await _loadStats(start, end);
  }

  Future<void> loadCustomStats(DateTime start, DateTime end) async {
    await _loadStats(start, end);
  }

  Future<void> _loadStats(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    _totalIncome = await _database.getTotalByType(
      TransactionType.income,
      start,
      end,
    );
    
    _totalExpense = await _database.getTotalByType(
      TransactionType.expense,
      start,
      end,
    );

    _expensesByCategory = await _database.getExpensesByCategory(start, end);

    _isLoading = false;
    notifyListeners();
  }
}
