class BudgetModel {
  final String id;
  final String categoryId;
  final double limitAmount;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      categoryId: map['category_id'],
      limitAmount: map['limit_amount'],
      month: map['month'],
      year: map['year'],
    );
  }
}

class MonthlyBudgetModel {
  final String id;
  final double limitAmount;
  final int month;
  final int year;

  MonthlyBudgetModel({
    required this.id,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
    };
  }

  factory MonthlyBudgetModel.fromMap(Map<String, dynamic> map) {
    return MonthlyBudgetModel(
      id: map['id'],
      limitAmount: map['limit_amount'],
      month: map['month'],
      year: map['year'],
    );
  }
}
