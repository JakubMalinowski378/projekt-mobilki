import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/currency_provider.dart';
import '../data/database/tables.dart';
import '../l10n/app_localizations.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final statisticsProvider = context.read<StatisticsProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    statisticsProvider.loadMonthlyStats(
      DateTime.now(),
      currencyProvider,
      settingsProvider.targetCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.home), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(context, theme, l10n),
              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActions(context, theme, l10n),
              const SizedBox(height: 24),

              // Recent Transactions
              _buildRecentTransactions(context, theme, l10n),
              const SizedBox(height: 24),

              // Monthly Overview
              _buildMonthlyOverview(context, theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Consumer2<StatisticsProvider, SettingsProvider>(
      builder: (context, statsProvider, settingsProvider, _) {
        final currency = settingsProvider.targetCurrency;
        final balance = statsProvider.balance;
        final totalIncome = statsProvider.totalIncome;
        final totalExpense = statsProvider.totalExpense;

        return Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: balance >= 0
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.red.shade400, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentBalance,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBalanceItem(
                      l10n.income,
                      totalIncome,
                      currency,
                      Icons.arrow_upward,
                      Colors.white,
                    ),
                    _buildBalanceItem(
                      l10n.expenses,
                      totalExpense,
                      currency,
                      Icons.arrow_downward,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceItem(
    String label,
    double amount,
    String currency,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} $currency',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                l10n.addIncome,
                Icons.add_circle_outline,
                Colors.green,
                () => _navigateToTransactionForm(TransactionType.income),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                l10n.addExpense,
                Icons.remove_circle_outline,
                Colors.red,
                () => _navigateToTransactionForm(TransactionType.expense),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTransactionForm(TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(initialType: type),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentTransactions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Consumer3<TransactionProvider, CurrencyProvider, SettingsProvider>(
          builder: (context, provider, currencyProvider, settingsProvider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final recentTransactions = provider.transactions.take(5).toList();
            final targetCurrency = settingsProvider.targetCurrency;

            if (recentTransactions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.noTransactions,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return FutureBuilder<double>(
                    future: transaction.currency != targetCurrency
                        ? currencyProvider.convert(
                            transaction.amount,
                            transaction.currency,
                            targetCurrency,
                          )
                        : Future.value(transaction.amount),
                    builder: (context, snapshot) {
                      final convertedAmount =
                          snapshot.data ?? transaction.amount;
                      final showConversion =
                          transaction.currency != targetCurrency &&
                          snapshot.hasData;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.type == TransactionType.income
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          child: Icon(
                            transaction.type == TransactionType.income
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(
                          transaction.description ?? l10n.noDescription,
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(transaction.date),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (showConversion)
                              Text(
                                '${convertedAmount.toStringAsFixed(2)} $targetCurrency',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      transaction.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            Text(
                              showConversion
                                  ? '(${transaction.amount.toStringAsFixed(2)} ${transaction.currency})'
                                  : '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                              style: TextStyle(
                                fontSize: showConversion ? 12 : 16,
                                fontWeight: showConversion
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: showConversion
                                    ? theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      )
                                    : (transaction.type ==
                                              TransactionType.income
                                          ? Colors.green
                                          : Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthlyOverview(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.thisMonth,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<StatisticsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (provider.expensesByCategory.isEmpty ||
                provider.totalExpense == 0) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.noDataAvailable,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              );
            }

            final topCategories = provider.expensesByCategory.take(3).toList();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...topCategories.map((category) {
                      final percentage =
                          (category.total / provider.totalExpense * 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.primaries[topCategories.indexOf(
                                        category,
                                      ) %
                                      Colors.primaries.length],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
