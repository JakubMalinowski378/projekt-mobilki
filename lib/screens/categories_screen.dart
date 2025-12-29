import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../data/database/tables.dart';
import 'category_form_screen.dart';
import '../l10n/app_localizations.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.categories),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.income),
              Tab(text: l10n.expense),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoryFormScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _CategoryList(type: TransactionType.income),
            _CategoryList(type: TransactionType.expense),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final TransactionType type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = provider.getCategoriesByType(type);

        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories yet'),
          );
        }

        return ListView.builder(
          itemCount: categories.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: type == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                  child: Icon(
                    Icons.category,
                    color: Colors.white,
                  ),
                ),
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryFormScreen(
                          category: category,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
