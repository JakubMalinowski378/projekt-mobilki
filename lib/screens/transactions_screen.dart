import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/currency_provider.dart';
import 'transaction_form_screen.dart';
import '../l10n/app_localizations.dart';

import '../utils/category_utils.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransactionFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer4<TransactionProvider, CategoryProvider, CurrencyProvider, SettingsProvider>(
        builder: (context, transactionProvider, categoryProvider, currencyProvider, settingsProvider, _) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = transactionProvider.transactions;

          return Column(
            children: [
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withAlpha(128),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first transaction',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final category = categoryProvider.categories
                              .firstWhere((c) => c.id == transaction.categoryId);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type.name == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  transaction.type.name == 'income'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(getLocalizedCategoryName(context, category.name)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transaction.description != null)
                                    Text(transaction.description!),
                                  Text(
                                    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(transaction.date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.type.name == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransactionFormScreen(
                                      transaction: transaction,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
