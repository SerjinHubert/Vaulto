class SubscriptionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isEmi; // false for Sub, true for EMI
  final int? reminderDays;
  final int? durationMonths;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.isEmi,
    this.reminderDays,
    this.durationMonths,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'dueDate': dueDate.millisecondsSinceEpoch,
    'isEmi': isEmi,
    if (reminderDays != null) 'reminderDays': reminderDays,
    if (durationMonths != null) 'durationMonths': durationMonths,
  };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => SubscriptionModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    amount: ((json['amount'] ?? 0) as num).toDouble(),
    dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate'] ?? DateTime.now().millisecondsSinceEpoch),
    isEmi: json['isEmi'] ?? false,
    reminderDays: json['reminderDays'] as int?,
    durationMonths: json['durationMonths'] as int?,
  );

  int get remainingDays {
    final now = DateTime.now();
    final nextDueDate = DateTime(now.year, now.month, dueDate.day);
    
    if (nextDueDate.isBefore(now)) {
      // Due date passed this month, so it's due next month
      return DateTime(now.year, now.month + 1, dueDate.day).difference(now).inDays;
    } else {
      return nextDueDate.difference(now).inDays;
    }
  }
}
