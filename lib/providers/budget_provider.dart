import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../services/database_service.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  MonthlyBudgetModel? _monthlyBudget;
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<BudgetModel> get budgets => _budgets;
  MonthlyBudgetModel? get monthlyBudget => _monthlyBudget;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  double get totalMonthlyLimit => _monthlyBudget?.limitAmount ?? 1500.0;

  double get totalAllocated =>
      _budgets.fold(0.0, (sum, b) => sum + b.limitAmount);

  double get unallocated => totalMonthlyLimit - totalAllocated;

  BudgetModel? getBudgetForCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    _budgets = await _db.getBudgetsByMonth(
        _selectedMonth.month, _selectedMonth.year);
    _monthlyBudget = await _db.getMonthlyBudget(
        _selectedMonth.month, _selectedMonth.year);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setBudgetForCategory(String categoryId, double amount) async {
    final existing = getBudgetForCategory(categoryId);

    final budget = BudgetModel(
      id: existing?.id ?? _uuid.v4(),
      categoryId: categoryId,
      limitAmount: amount,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );

    await _db.upsertBudget(budget);

    if (existing != null) {
      final idx = _budgets.indexWhere((b) => b.categoryId == categoryId);
      _budgets[idx] = budget;
    } else {
      _budgets.add(budget);
    }

    notifyListeners();
  }

  Future<void> setMonthlyLimit(double amount) async {
    final budget = MonthlyBudgetModel(
      id: _monthlyBudget?.id ?? _uuid.v4(),
      limitAmount: amount,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );

    await _db.upsertMonthlyBudget(budget);
    _monthlyBudget = budget;
    notifyListeners();
  }

  Future<void> setMonthlyLimitForMonth(DateTime date, double amount) async {
    final existing = await _db.getMonthlyBudget(date.month, date.year);
    final budget = MonthlyBudgetModel(
      id: existing?.id ?? _uuid.v4(),
      limitAmount: amount,
      month: date.month,
      year: date.year,
    );

    await _db.upsertMonthlyBudget(budget);
    if (date.month == _selectedMonth.month && date.year == _selectedMonth.year) {
      _monthlyBudget = budget;
    }
    notifyListeners();
  }

  Future<void> deleteBudget(String categoryId) async {
    final budget = getBudgetForCategory(categoryId);
    if (budget == null) return;

    await _db.deleteBudget(budget.id);
    _budgets.removeWhere((b) => b.categoryId == categoryId);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    loadBudgets();
  }

  void nextMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    loadBudgets();
  }

  void setMonth(DateTime month) {
    _selectedMonth = month;
    loadBudgets();
  }
}
