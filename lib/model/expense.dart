class Expense {
  final int? id;
  final String title;
  final double amount;
  final String date;
  final String category;
  final String description;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
      description: map['description'] ?? '',
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? date,
    String? category,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
