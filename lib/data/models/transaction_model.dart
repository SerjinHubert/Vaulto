class TransactionModel {
  final String id;
  final double amount;
  final bool isExpense;
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'isExpense': isExpense,
    'category': category,
    'note': note,
    'date': date.millisecondsSinceEpoch,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'] ?? '',
    amount: ((json['amount'] ?? 0) as num).toDouble(),
    isExpense: json['isExpense'] ?? true,
    category: json['category'] ?? 'Other',
    note: json['note'] ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? DateTime.now().millisecondsSinceEpoch),
  );
}
