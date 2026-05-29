class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final String paymentMethod;
  final DateTime date;
  final String? note;
  final bool isIncome;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.paymentMethod,
    required this.date,
    this.note,
    this.isIncome = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'payment_method': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
      'is_income': isIncome ? 1 : 0,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      categoryId: map['category_id'],
      paymentMethod: map['payment_method'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      isIncome: map['is_income'] == 1,
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    String? paymentMethod,
    DateTime? date,
    String? note,
    bool? isIncome,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
