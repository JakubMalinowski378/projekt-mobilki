import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../data/database/database.dart';
import '../data/database/tables.dart';
import '../l10n/app_localizations.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _type = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _type = widget.category!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();

    if (widget.category == null) {
      await provider.addCategory(
        name: _nameController.text,
        type: _type,
      );
    } else {
      await provider.updateCategory(
        widget.category!.copyWith(
          name: _nameController.text,
          type: _type,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteCategory() async {
    if (widget.category == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? '
          'This may affect existing transactions.',
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
      await context.read<CategoryProvider>().deleteCategory(
        widget.category!.id,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null
            ? l10n.addCategory
            : l10n.editCategory),
        actions: [
          if (widget.category != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCategory,
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
