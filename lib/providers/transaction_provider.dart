import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database/database.dart';
import '../data/database/tables.dart';

class TransactionProvider extends ChangeNotifier {
  final AppDatabase _database;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  TransactionProvider(this._database) {
    _loadTransactions();
  }

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await _database.getAllTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required double amount,
    required String currency,
    required DateTime date,
    required int categoryId,
    required TransactionType type,
    String? description,
  }) async {
    await _database.insertTransaction(
      TransactionsCompanion.insert(
        amount: amount,
        currency: currency,
        date: date,
        categoryId: categoryId,
        type: type,
        description: drift.Value(description),
      ),
    );
    await _loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _database.updateTransaction(transaction);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _database.deleteTransaction(id);
    await _loadTransactions();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _database.getTransactionsByDateRange(start, end);
  }
}
