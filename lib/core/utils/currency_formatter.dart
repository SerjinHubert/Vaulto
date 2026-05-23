import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    // For premium feel, we might want to show like ₹1.20L or ₹84.0K
    // Standard format for exact values: ₹84,050
    final NumberFormat format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toInt()}';
    }
  }
}
