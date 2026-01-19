import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../data/database/database.dart';
import '../data/database/tables.dart';
import '../l10n/app_localizations.dart';
import '../data/services/notification_service.dart';

import '../utils/category_utils.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const TransactionFormScreen({super.key, this.transaction, this.initialType});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'PLN', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      _type = t.type;
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
      _selectedCurrency = t.currency;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;

    final transactionProvider = context.read<TransactionProvider>();

    if (widget.transaction == null) {
      await transactionProvider.addTransaction(
        amount: amount,
        currency: _selectedCurrency,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        type: _type,
        description: description,
      );

      // Trigger notification if enabled
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.notificationsEnabled && mounted) {
        final category = context
            .read<CategoryProvider>()
            .categories
            .firstWhere((c) => c.id == _selectedCategoryId)
            .name;

        final l10n = AppLocalizations.of(context)!;
        final typeStr = _type == TransactionType.income
            ? l10n.income
            : l10n.expense;

        await NotificationService().showTransactionNotification(
          title: l10n.transactionAdded,
          body: l10n.newTransaction(
            amount.toStringAsFixed(2),
            getLocalizedCategoryName(context, category),
            _selectedCurrency,
            typeStr,
          ),
        );
      }
    } else {
      await transactionProvider.updateTransaction(
        widget.transaction!.copyWith(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          categoryId: _selectedCategoryId!,
          type: _type,
          description: drift.Value(description),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteTransaction() async {
    if (widget.transaction == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TransactionProvider>().deleteTransaction(
        widget.transaction!.id,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? l10n.addTransaction
              : l10n.editTransaction,
        ),
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l10n.income),
                  icon: const Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l10n.expense),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _selectedCategoryId = null;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: InputDecoration(
                labelText: l10n.currency,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.currency_exchange),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(value: currency, child: Text(currency));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
              },
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                final categories = categoryProvider.getCategoriesByType(_type);

                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(
                        getLocalizedCategoryName(context, category.name),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.date),
              subtitle: Text(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).toString(),
                ).format(_selectedDate),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
