// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get transactions => 'Transactions';

  @override
  String get statistics => 'Statistics';

  @override
  String get categories => 'Categories';

  @override
  String get settings => 'Settings';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get currency => 'Currency';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get type => 'Type';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get monthlyStats => 'Monthly Statistics';

  @override
  String get yearlyStats => 'Yearly Statistics';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expenses';

  @override
  String get balance => 'Balance';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get notifications => 'Notifications';

  @override
  String get shakeToAdd => 'Shake to add transaction';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get language => 'Language';

  @override
  String get currencyRates => 'Currency Rates';

  @override
  String get updateRates => 'Update Rates';

  @override
  String get noRatesAvailable => 'No rates available';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get baseCurrency => 'Base Currency';

  @override
  String get yourBaseCurrency => 'Your base currency';

  @override
  String get searchCurrency => 'Search currency...';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBusiness => 'Business';

  @override
  String get catInvestments => 'Investments';

  @override
  String get catFoodDining => 'Food & Dining';

  @override
  String get catTransportation => 'Transportation';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catBillsUtilities => 'Bills & Utilities';

  @override
  String get catHealthcare => 'Healthcare';

  @override
  String get transactionAdded => 'Transaction Added';

  @override
  String newTransaction(
    Object amount,
    Object category,
    Object currency,
    Object type,
  ) {
    return '$type: $category - $amount $currency';
  }
}
