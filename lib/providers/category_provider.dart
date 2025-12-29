import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/database/tables.dart';

class CategoryProvider extends ChangeNotifier {
  final AppDatabase _database;
  List<Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this._database) {
    _loadCategories();
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<Category> getCategoriesByType(TransactionType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();
    
    _categories = await _database.getAllCategories();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required TransactionType type,
  }) async {
    await _database.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        type: type,
      ),
    );
    await _loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _database.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _database.deleteCategory(id);
    await _loadCategories();
  }
}
