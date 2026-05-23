import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/transaction_model.dart';
import '../data/models/subscription_model.dart';
import '../data/services/firestore_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<TransactionModel> _transactions = [];
  List<SubscriptionModel> _subscriptions = [];
  double _monthlyBudget = 120000;

  StreamSubscription? _transactionsSub;
  StreamSubscription? _subscriptionsSub;
  StreamSubscription? _budgetSub;
  StreamSubscription? _profileSub;

  String? _profileImageBase64;
  String? get profileImageBase64 => _profileImageBase64;

  String _firstName = 'Vault';
  String _lastName = 'User';
  String _email = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;

  FinanceProvider(this._firestoreService) {
    _initStreams();
  }

  Future<void> saveProfileImage(String base64Str) async {
    _profileImageBase64 = base64Str;
    notifyListeners();
    try {
      await _firestoreService.updateProfileImage(base64Str);
    } catch (e) {
      // Handle error quietly or add logging
    }
  }

  void _initStreams() {
    _transactionsSub = _firestoreService.streamTransactions().listen((data) {
      _transactions = data;
      notifyListeners();
    });

    _subscriptionsSub = _firestoreService.streamSubscriptions().listen((data) {
      _subscriptions = data;
      notifyListeners();
    });

    _budgetSub = _firestoreService.streamBudget().listen((data) {
      _monthlyBudget = data;
      notifyListeners();
    });

    _profileSub = _firestoreService.streamUserProfile().listen((data) {
      if (data != null) {
        _firstName = data['firstName'] ?? 'Vault';
        _lastName = data['lastName'] ?? 'User';
        _email = data['email'] ?? '';
        if (data.containsKey('profileImageBase64')) {
          _profileImageBase64 = data['profileImageBase64'];
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _subscriptionsSub?.cancel();
    _budgetSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }

  List<TransactionModel> get transactions => _transactions;
  List<SubscriptionModel> get subscriptions => _subscriptions;

  // --- Transactions ---
  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestoreService.addTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _firestoreService.deleteTransaction(id);
  }

  // --- Subscriptions ---
  Future<void> addSubscription(SubscriptionModel sub) async {
    await _firestoreService.addSubscription(sub);
  }

  Future<void> deleteSubscription(String id) async {
    await _firestoreService.deleteSubscription(id);
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _firestoreService.updateSubscription(sub);
  }

  // --- Calculations ---
  double get totalBalance {
    // A simplified total balance. You might want to define an initial balance.
    // For now, let's just use: Initial balance + Income - Expenses
    // Since we don't have an initial balance, we'll just sum them up.
    return totalIncome - totalExpenses;
  }

  double get totalIncome {
    return _transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalSaved {
    // Example logical metric: Total income - total expenses. 
    // Same as balance in this basic logic.
    return totalBalance > 0 ? totalBalance : 0.0;
  }

  double get monthlyBudget => _monthlyBudget;
  
  Future<void> updateMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    notifyListeners();
    await _firestoreService.updateBudget(amount);
  }
  
  double get monthlySpent {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isExpense && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => !t.isExpense && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  int get savingsRate {
    if (monthlyIncome == 0) return 0;
    final saved = monthlyIncome - monthlySpent;
    if (saved <= 0) return 0;
    return ((saved / monthlyIncome) * 100).round();
  }

  double get totalEmi {
    return _subscriptions
        .where((s) => s.isEmi)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  double get totalSub {
    return _subscriptions
        .where((s) => !s.isEmi)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  // --- Analytics Engine ---
  List<double> get weeklySpending {
    List<double> weekData = List.filled(7, 0.0);
    final now = DateTime.now();
    // Find the most recent Sunday
    final lastSunday = now.subtract(Duration(days: now.weekday == 7 ? 0 : now.weekday));
    final startOfWeek = DateTime(lastSunday.year, lastSunday.month, lastSunday.day);

    for (var t in _transactions) {
      if (t.isExpense && !t.date.isBefore(startOfWeek)) {
        // weekday: 1=Mon, 7=Sun. We want 0=Sun, 1=Mon
        final dayIndex = t.date.weekday == 7 ? 0 : t.date.weekday;
        weekData[dayIndex] += t.amount;
      }
    }
    return weekData;
  }

  List<double> get spendingTrend {
    List<double> trend = List.filled(6, 0.0);
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final spent = _transactions
          .where((t) => t.isExpense && t.date.month == targetMonth.month && t.date.year == targetMonth.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      trend[5 - i] = spent; // Reverse so index 5 is current month
    }
    return trend;
  }

  List<Map<String, dynamic>> get incomeVsExpense {
    List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    for (int i = 0; i < 6; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final inc = _transactions
          .where((t) => !t.isExpense && t.date.month == targetMonth.month && t.date.year == targetMonth.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      final exp = _transactions
          .where((t) => t.isExpense && t.date.month == targetMonth.month && t.date.year == targetMonth.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final total = inc + exp;
      final incRatio = total == 0 ? 0.0 : inc / total;
      final expRatio = total == 0 ? 0.0 : exp / total;

      data.insert(0, {
        'month': monthNames[targetMonth.month - 1],
        'incRatio': incRatio,
        'expRatio': expRatio,
      });
    }
    return data;
  }

  String get topCategory {
    final Map<String, double> categoryTotals = {};
    for (var t in _transactions) {
      if (t.isExpense) {
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0.0) + t.amount;
      }
    }
    if (categoryTotals.isEmpty) return 'None';
    
    String topCat = categoryTotals.keys.first;
    double maxAmt = categoryTotals[topCat]!;
    
    categoryTotals.forEach((cat, amt) {
      if (amt > maxAmt) {
        maxAmt = amt;
        topCat = cat;
      }
    });
    return topCat;
  }
}
