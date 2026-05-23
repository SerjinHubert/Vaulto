import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/core/utils/currency_formatter.dart';
import 'package:vaulto/providers/finance_provider.dart';
import 'package:vaulto/data/models/transaction_model.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[month - 1];
  }

  void _showDeleteDialog(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text('Delete Transaction?', style: AppTextStyles.h2),
          content: Text(
            'Are you sure you want to delete ${transaction.category} (${CurrencyFormatter.format(transaction.amount)})? This action cannot be undone.',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.bodySecondary),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
              onPressed: () async {
                Navigator.pop(context);
                await context.read<FinanceProvider>().deleteTransaction(transaction.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transaction deleted.'),
                      backgroundColor: AppColors.neonRed,
                    ),
                  );
                }
              },
              child: Text('Delete', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.background)),
            ),
          ],
        );
      },
    );
  }

  void _showEditModal(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionScreen(existingTransaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final monthlyTransactions = provider.transactions.where((t) {
      return t.date.year == _selectedDate.year && t.date.month == _selectedDate.month;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text('History', style: AppTextStyles.h1),
                    ],
                  ),
                  Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: AppColors.goldAccent),
                      onPressed: _previousMonth,
                    ),
                    Text('${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: AppTextStyles.h3),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, color: AppColors.goldAccent),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: monthlyTransactions.isEmpty
                ? Center(
                    child: Text('No transactions found', style: AppTextStyles.bodySecondary),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                    itemCount: monthlyTransactions.length,
                    itemBuilder: (context, index) {
                      final t = monthlyTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (t.isExpense ? AppColors.neonRed : AppColors.neonGreen).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                t.isExpense ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                                color: t.isExpense ? AppColors.neonRed : AppColors.neonGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.category, style: AppTextStyles.bodyPrimary),
                                  if (t.note.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(t.note, style: AppTextStyles.label),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${t.date.day} ${_getMonthName(t.date.month)} ${t.date.year}',
                                    style: AppTextStyles.label.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${t.isExpense ? '-' : '+'}${CurrencyFormatter.format(t.amount)}',
                              style: AppTextStyles.h3.copyWith(
                                color: t.isExpense ? AppColors.textPrimary : AppColors.neonGreen,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            PopupMenuButton<String>(
                              icon: const Icon(LucideIcons.moreVertical, color: AppColors.textSecondary),
                              color: AppColors.cardDark,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditModal(t);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(t);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.edit2, size: 16, color: AppColors.textPrimary),
                                      const SizedBox(width: 8),
                                      Text('Edit', style: AppTextStyles.bodyPrimary),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.trash2, size: 16, color: AppColors.neonRed),
                                      const SizedBox(width: 8),
                                      Text('Delete', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.neonRed)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          ],
        ),
      ),
    );
  }
}
