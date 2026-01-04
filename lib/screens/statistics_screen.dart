import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/statistics_provider.dart';
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
    final provider = context.read<StatisticsProvider>();
    if (_showMonthly) {
      provider.loadMonthlyStats(_selectedMonth);
    } else {
      provider.loadYearlyStats(_selectedMonth.year);
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
            icon: Icon(_showMonthly ? Icons.calendar_month : Icons.calendar_today),
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
              _buildSummaryCards(context, provider, l10n),
              const SizedBox(height: 24),
              if (provider.expensesByCategory.isNotEmpty) ...[
                _buildExpensesPieChart(context, provider, l10n),
                const SizedBox(height: 24),
                _buildCategoryList(provider, l10n),
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
              ? DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_selectedMonth)
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${provider.totalIncome.toStringAsFixed(2)}',
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${provider.totalExpense.toStringAsFixed(2)}',
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

  Widget _buildExpensesPieChart(
    BuildContext context,
    StatisticsProvider provider,
    AppLocalizations l10n,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.expensesByCategory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: provider.expensesByCategory
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final stat = entry.value;
                    final percentage =
                        (stat.total / provider.totalExpense) * 100;
                    return PieChartSectionData(
                      value: stat.total,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    StatisticsProvider provider,
    AppLocalizations l10n,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.expensesByCategory.length,
        itemBuilder: (context, index) {
          final stat = provider.expensesByCategory[index];
          final percentage = (stat.total / provider.totalExpense) * 100;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colors[index % colors.length],
              radius: 8,
            ),
            title: Text(getLocalizedCategoryName(context, stat.categoryName)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stat.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
