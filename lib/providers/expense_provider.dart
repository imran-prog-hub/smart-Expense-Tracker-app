import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';
import '../core/utils/app_utils.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  String _searchQuery = '';

  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get filteredExpenses =>
      _searchQuery.isEmpty ? _expenses : _filteredExpenses;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  // ─── STATS ──────────────────────────────────────────────────

  double get totalExpensesThisMonth {
    return _expenses
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalIncomeThisMonth {
    return _expenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get balance => totalIncomeThisMonth - totalExpensesThisMonth;

  double get todayExpenses {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
            !e.isIncome &&
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get thisWeekExpenses {
    final start = AppUtils.startOfWeek(DateTime.now());
    return _expenses
        .where((e) => !e.isIncome && e.date.isAfter(start))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final e in _expenses.where((e) => !e.isIncome)) {
      result[e.categoryId] = (result[e.categoryId] ?? 0) + e.amount;
    }
    return result;
  }

  List<double> get last5Amounts {
    return _expenses
        .where((e) => !e.isIncome)
        .take(5)
        .map((e) => e.amount)
        .toList();
  }

  // ─── GROUPED BY DATE ─────────────────────────────────────────

  Map<String, List<ExpenseModel>> get groupedExpenses {
    final Map<String, List<ExpenseModel>> grouped = {};
    final list = _searchQuery.isEmpty ? _expenses : _filteredExpenses;

    for (final expense in list) {
      final key = AppUtils.formatDate(expense.date);
      grouped.putIfAbsent(key, () => []).add(expense);
    }
    return grouped;
  }

  // ─── LOAD ────────────────────────────────────────────────────

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _db.getExpensesByMonth(
        _selectedMonth.month, _selectedMonth.year);

    _isLoading = false;
    notifyListeners();
  }

  Future<List<ExpenseModel>> loadAllExpenses() async {
    return await _db.getAllExpenses();
  }

  // ─── ADD ─────────────────────────────────────────────────────

  Future<void> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required String paymentMethod,
    required DateTime date,
    String? note,
    bool isIncome = false,
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      categoryId: categoryId,
      paymentMethod: paymentMethod,
      date: date,
      note: note,
      isIncome: isIncome,
    );

    await _db.insertExpense(expense);

    if (date.month == _selectedMonth.month &&
        date.year == _selectedMonth.year) {
      _expenses.insert(0, expense);
    }

    notifyListeners();
  }

  // ─── DELETE ──────────────────────────────────────────────────

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ─── SEARCH ──────────────────────────────────────────────────

  Future<void> searchExpenses(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredExpenses = [];
    } else {
      _filteredExpenses = await _db.searchExpenses(query);
    }
    notifyListeners();
  }

  // ─── MONTH NAV ───────────────────────────────────────────────

  void previousMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    loadExpenses();
  }

  void nextMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    loadExpenses();
  }

  void setMonth(DateTime month) {
    _selectedMonth = month;
    loadExpenses();
  }
}
