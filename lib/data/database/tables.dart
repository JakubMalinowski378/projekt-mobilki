import 'package:drift/drift.dart';

enum TransactionType {
  income,
  expense,
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => textEnum<TransactionType>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get description => text().withLength(min: 0, max: 500).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CurrencyRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  RealColumn get rate => real()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
