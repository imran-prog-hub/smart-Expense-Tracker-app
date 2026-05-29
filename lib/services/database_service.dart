import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // Web in-memory storage fallback
  final List<Map<String, dynamic>> _webExpenses = [];
  final List<Map<String, dynamic>> _webBudgets = [];
  final List<Map<String, dynamic>> _webMonthlyBudgets = [];

  DatabaseService._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on web. Use web fallbacks.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        is_income INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_budgets (
        id TEXT PRIMARY KEY,
        limit_amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    final now = DateTime.now();
    final expenses = _getSampleExpenses(now);

    for (final expense in expenses) {
      await db.insert('expenses', expense);
    }
  }

  List<Map<String, dynamic>> _getSampleExpenses(DateTime now) {
    return [
      {
        'id': '1',
        'title': 'Tea Corner',
        'amount': 0.22,
        'category_id': 'food',
        'payment_method': 'digital',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        'note': null,
        'is_income': 0,
      },
      {
        'id': '2',
        'title': 'Apollo Pharmacy',
        'amount': 3.56,
        'category_id': 'health',
        'payment_method': 'digital',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        'note': null,
        'is_income': 0,
      },
      {
        'id': '3',
        'title': 'Petrol Pump',
        'amount': 16.67,
        'category_id': 'transport',
        'payment_method': 'digital',
        'date': DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        'note': null,
        'is_income': 0,
      },
      {
        'id': '4',
        'title': 'Cantonese Restaurant',
        'amount': 38.89,
        'category_id': 'food',
        'payment_method': 'digital',
        'date': DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        'note': null,
        'is_income': 0,
      },
      {
        'id': '5',
        'title': 'Salary',
        'amount': 1692.0,
        'category_id': 'other',
        'payment_method': 'digital',
        'date': DateTime(now.year, now.month, 1).toIso8601String(),
        'note': 'Monthly salary',
        'is_income': 1,
      },
    ];
  }

  Future<void> initWeb() async {
    if (_webExpenses.isEmpty) {
      final now = DateTime.now();
      _webExpenses.addAll(_getSampleExpenses(now));
    }
  }

  // ─── EXPENSES ───────────────────────────────────────────────

  Future<String> insertExpense(ExpenseModel expense) async {
    if (kIsWeb) {
      _webExpenses.removeWhere((e) => e['id'] == expense.id);
      _webExpenses.add(expense.toMap());
      return expense.id;
    }
    final db = await database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return expense.id;
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    if (kIsWeb) {
      final list = List<Map<String, dynamic>>.from(_webExpenses);
      list.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return list.map((e) => ExpenseModel.fromMap(e)).toList();
    }
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByMonth(int month, int year) async {
    if (kIsWeb) {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      final result = _webExpenses.where((e) {
        final d = DateTime.parse(e['date']);
        return d.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               d.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
      result.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    }
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    if (kIsWeb) {
      final result = _webExpenses.where((e) {
        final d = DateTime.parse(e['date']);
        return d.isAfter(start.subtract(const Duration(seconds: 1))) &&
               d.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
      result.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    }
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<List<ExpenseModel>> searchExpenses(String query) async {
    if (kIsWeb) {
      final result = _webExpenses.where((e) {
        final title = (e['title'] as String).toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
      result.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    }
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<int> deleteExpense(String id) async {
    if (kIsWeb) {
      final before = _webExpenses.length;
      _webExpenses.removeWhere((e) => e['id'] == id);
      return before - _webExpenses.length;
    }
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    if (kIsWeb) {
      final idx = _webExpenses.indexWhere((e) => e['id'] == expense.id);
      if (idx != -1) {
        _webExpenses[idx] = expense.toMap();
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // ─── BUDGETS ────────────────────────────────────────────────

  Future<String> upsertBudget(BudgetModel budget) async {
    if (kIsWeb) {
      _webBudgets.removeWhere((b) => b['id'] == budget.id);
      _webBudgets.add(budget.toMap());
      return budget.id;
    }
    final db = await database;
    await db.insert('budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return budget.id;
  }

  Future<List<BudgetModel>> getBudgetsByMonth(int month, int year) async {
    if (kIsWeb) {
      final result = _webBudgets.where((b) => b['month'] == month && b['year'] == year).toList();
      return result.map((e) => BudgetModel.fromMap(e)).toList();
    }
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return result.map((e) => BudgetModel.fromMap(e)).toList();
  }

  Future<int> deleteBudget(String id) async {
    if (kIsWeb) {
      final before = _webBudgets.length;
      _webBudgets.removeWhere((b) => b['id'] == id);
      return before - _webBudgets.length;
    }
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ─── MONTHLY BUDGET ─────────────────────────────────────────

  Future<void> upsertMonthlyBudget(MonthlyBudgetModel budget) async {
    if (kIsWeb) {
      _webMonthlyBudgets.removeWhere((b) => b['id'] == budget.id);
      _webMonthlyBudgets.add(budget.toMap());
      return;
    }
    final db = await database;
    await db.insert('monthly_budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<MonthlyBudgetModel?> getMonthlyBudget(int month, int year) async {
    if (kIsWeb) {
      final result = _webMonthlyBudgets.where((b) => b['month'] == month && b['year'] == year).toList();
      if (result.isEmpty) return null;
      return MonthlyBudgetModel.fromMap(result.first);
    }
    final db = await database;
    final result = await db.query(
      'monthly_budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    if (result.isEmpty) return null;
    return MonthlyBudgetModel.fromMap(result.first);
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await database;
    db.close();
  }
}
