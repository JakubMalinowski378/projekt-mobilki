import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, CurrencyRates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _insertDefaultCategories();
        },
      );

  Future<void> _insertDefaultCategories() async {
    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(
          name: 'Salary',
          type: TransactionType.income,
        ),
        CategoriesCompanion.insert(
          name: 'Business',
          type: TransactionType.income,
        ),
        CategoriesCompanion.insert(
          name: 'Investments',
          type: TransactionType.income,
        ),
        CategoriesCompanion.insert(
          name: 'Food & Dining',
          type: TransactionType.expense,
        ),
        CategoriesCompanion.insert(
          name: 'Transportation',
          type: TransactionType.expense,
        ),
        CategoriesCompanion.insert(
          name: 'Shopping',
          type: TransactionType.expense,
        ),
        CategoriesCompanion.insert(
          name: 'Entertainment',
          type: TransactionType.expense,
        ),
        CategoriesCompanion.insert(
          name: 'Bills & Utilities',
          type: TransactionType.expense,
        ),
        CategoriesCompanion.insert(
          name: 'Healthcare',
          type: TransactionType.expense,
        ),
      ]);
    });
  }

  // Category queries
  Future<List<Category>> getAllCategories() => select(categories).get();
  
  Future<List<Category>> getCategoriesByType(TransactionType type) =>
      (select(categories)..where((c) => c.type.equals(type.name))).get();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // Transaction queries
  Future<List<Transaction>> getAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(transactions)
            ..where((t) => t.date.isBetweenValues(start, end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactions).replace(transaction);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // Statistics queries
  Future<double> getTotalByType(TransactionType type, DateTime start, DateTime end) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals(type.name))
      ..where(transactions.date.isBetweenValues(start, end));
    
    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  Future<List<CategoryStats>> getExpensesByCategory(DateTime start, DateTime end) async {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId))
    ])
      ..where(transactions.type.equals(TransactionType.expense.name))
      ..where(transactions.date.isBetweenValues(start, end));

    final result = await query.get();
    
    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      final transaction = row.readTable(transactions);
      final category = row.readTable(categories);
      categoryTotals[category.name] = 
          (categoryTotals[category.name] ?? 0) + transaction.amount;
    }

    return categoryTotals.entries
        .map((e) => CategoryStats(categoryName: e.key, total: e.value))
        .toList();
  }

  // Currency Rate queries
  Future<List<CurrencyRate>> getAllCurrencyRates() => select(currencyRates).get();

  Future<CurrencyRate?> getLatestRate(String currency) async {
    final query = select(currencyRates)
      ..where((r) => r.currency.equals(currency))
      ..orderBy([(r) => OrderingTerm.desc(r.date)])
      ..limit(1);
    
    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }

  Future<int> insertCurrencyRate(CurrencyRatesCompanion rate) =>
      into(currencyRates).insert(rate);

  Future<int> deleteCurrencyRate(int id) =>
      (delete(currencyRates)..where((r) => r.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_tracker.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}

class CategoryStats {
  final String categoryName;
  final double total;

  CategoryStats({required this.categoryName, required this.total});
}
