import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/database/database.dart';
import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/currency_provider.dart';
import '../l10n/app_localizations.dart';

import '../utils/category_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _showMonthly = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final statsProvider = context.read<StatisticsProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final targetCurrency = settingsProvider.targetCurrency;

    if (_showMonthly) {
      statsProvider.loadMonthlyStats(
        _selectedMonth,
        currencyProvider,
        targetCurrency,
      );
    } else {
      statsProvider.loadYearlyStats(
        _selectedMonth.year,
        currencyProvider,
        targetCurrency,
      );
    }
  }

  void _previousPeriod() {
    setState(() {
      if (_showMonthly) {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
      } else {
        _selectedMonth = DateTime(_selectedMonth.year - 1);
      }
    });
    _loadStats();
  }

  void _nextPeriod() {
    setState(() {
      if (_showMonthly) {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
        );
      } else {
        _selectedMonth = DateTime(_selectedMonth.year + 1);
      }
    });
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        actions: [
          IconButton(
            icon: Icon(
              _showMonthly ? Icons.calendar_month : Icons.calendar_today,
            ),
            onPressed: () {
              setState(() {
                _showMonthly = !_showMonthly;
                _loadStats();
              });
            },
          ),
        ],
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              _buildSummaryCards(
                context,
                provider,
                l10n,
                Provider.of<SettingsProvider>(context).targetCurrency,
              ),
              const SizedBox(height: 24),
              if (provider.incomeByCategory.isNotEmpty) ...[
                _buildChartSection(
                  context,
                  title: l10n.incomeByCategory,
                  stats: provider.incomeByCategory,
                  total: provider.totalIncome,
                  baseColors: [
                    Colors.green,
                    Colors.teal,
                    Colors.lime,
                    Colors.lightGreen,
                  ],
                  targetCurrency: Provider.of<SettingsProvider>(
                    context,
                  ).targetCurrency,
                ),
                const SizedBox(height: 24),
              ],
              if (provider.expensesByCategory.isNotEmpty) ...[
                _buildChartSection(
                  context,
                  title: l10n.expensesByCategory,
                  stats: provider.expensesByCategory,
                  total: provider.totalExpense,
                  baseColors: [
                    Colors.red,
                    Colors.orange,
                    Colors.pink,
                    Colors.purple,
                  ],
                  targetCurrency: Provider.of<SettingsProvider>(
                    context,
                  ).targetCurrency,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousPeriod,
        ),
        Text(
          _showMonthly
              ? DateFormat.yMMMM(
                  Localizations.localeOf(context).toString(),
                ).format(_selectedMonth)
              : _selectedMonth.year.toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextPeriod,
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    StatisticsProvider provider,
    AppLocalizations l10n,
    String targetCurrency,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l10n.totalIncome,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalIncome.toStringAsFixed(2)} $targetCurrency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l10n.totalExpense,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalExpense.toStringAsFixed(2)} $targetCurrency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(
    BuildContext context, {
    required String title,
    required List<CategoryStats> stats,
    required double total,
    required List<MaterialColor> baseColors,
    required String targetCurrency,
  }) {
    // Generate variations of base colors if needed
    final colors = List<Color>.generate(
      stats.length,
      (index) =>
          baseColors[index %
              baseColors.length][(index ~/ baseColors.length + 5) * 100]!,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // ... (retaining rest of widget tree)
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: stats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;
                    final percentage = (stat.total / total) * 100;
                    final isSmall = percentage < 5;

                    return PieChartSectionData(
                      value: stat.total,
                      title: isSmall ? '' : '${percentage.toStringAsFixed(1)}%',
                      color: colors[index],
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      badgeWidget: isSmall
                          ? _buildBadge(percentage, colors[index])
                          : null,
                      badgePositionPercentageOffset: 1.2,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final stat = stats[index];
                final percentage = (stat.total / total) * 100;

                // Check if all amounts are in target currency
                final allInTargetCurrency =
                    stat.originalAmounts.length == 1 &&
                    stat.originalAmounts.keys.first == targetCurrency;

                return ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colors[index],
                      radius: 8,
                    ),
                    title: Text(
                      getLocalizedCategoryName(context, stat.categoryName),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150, maxHeight: 70),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (allInTargetCurrency)
                              Text(
                                '${stat.total.toStringAsFixed(2)} $targetCurrency',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              )
                            else ...[
                              ...stat.originalAmounts.entries.map(
                                (e) => Text(
                                  '${e.value.toStringAsFixed(2)} ${e.key}',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '≈ ${stat.total.toStringAsFixed(2)} $targetCurrency',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 2),
        ],
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
