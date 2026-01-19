import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/currency_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class CurrencyRatesScreen extends StatefulWidget {
  const CurrencyRatesScreen({super.key});

  @override
  State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyProvider = context.read<CurrencyProvider>();
      if (currencyProvider.rates.isEmpty) {
        currencyProvider.updateRates();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRates() async {
    await context.read<CurrencyProvider>().updateRates();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currencyRates),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRates,
            tooltip: l10n.updateRates,
          ),
        ],
      ),
      body: Consumer2<CurrencyProvider, SettingsProvider>(
        builder: (context, currencyProvider, settingsProvider, _) {
          if (currencyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (currencyProvider.rates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRatesAvailable,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshRates,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.updateRates),
                  ),
                ],
              ),
            );
          }

          final baseCurrency = settingsProvider.targetCurrency;
          final lastUpdate = currencyProvider.lastUpdate;

          // Get all currencies and sort them
          final allCurrencies = currencyProvider.rates.keys.toList()..sort();

          // Filter currencies based on search query
          final currencies = _searchQuery.isEmpty
              ? allCurrencies
              : allCurrencies
                    .where(
                      (currency) =>
                          currency.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

          return Column(
            children: [
              if (lastUpdate != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Text(
                    '${l10n.lastUpdated}: ${DateFormat('yyyy-MM-dd HH:mm').format(lastUpdate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${l10n.baseCurrency}: $baseCurrency',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchCurrency,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRates,
                  child: ListView.builder(
                    itemCount: currencies.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      final rate = currencyProvider.rates[currency]!;

                      // Calculate rate relative to base currency
                      final baseRate =
                          currencyProvider.rates[baseCurrency] ?? 1.0;
                      final relativeRate = rate / baseRate;

                      final isBaseCurrency = currency == baseCurrency;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isBaseCurrency ? 3 : 1,
                        color: isBaseCurrency
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isBaseCurrency
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                            child: Text(
                              currency.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            currency,
                            style: TextStyle(
                              fontWeight: isBaseCurrency
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            isBaseCurrency
                                ? l10n.yourBaseCurrency
                                : '1 $baseCurrency = ${relativeRate.toStringAsFixed(4)} $currency',
                          ),
                          trailing: Text(
                            relativeRate.toStringAsFixed(4),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isBaseCurrency
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
