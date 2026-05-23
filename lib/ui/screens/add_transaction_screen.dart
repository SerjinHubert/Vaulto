import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/data/models/transaction_model.dart';
import 'package:vaulto/providers/finance_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;
  
  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String amountStr = '0';
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  final noteController = TextEditingController();
  final expenseCategories = ['Food', 'Travel', 'Shopping', 'Bills', 'EMI', 'Entertainment', 'Health', 'Education', 'Lented'];
  final incomeCategories = ['Salary', 'Pocket Money', 'Repayment', 'Gift', 'Investment', 'Other'];

  List<String> get currentCategories => isExpense ? expenseCategories : incomeCategories;

  void _setExpense(bool expense) {
    if (isExpense != expense) {
      setState(() {
        isExpense = expense;
        selectedCategory = expense ? expenseCategories.first : incomeCategories.first;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final t = widget.existingTransaction!;
      isExpense = t.isExpense;
      amountStr = t.amount == t.amount.toInt() ? t.amount.toInt().toString() : t.amount.toString();
      selectedCategory = t.category;
      selectedDate = t.date;
      noteController.text = t.note;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'delete') {
        if (amountStr.length > 1) {
          amountStr = amountStr.substring(0, amountStr.length - 1);
        } else {
          amountStr = '0';
        }
      } else if (key == '.') {
        if (!amountStr.contains('.')) {
          amountStr += '.';
        }
      } else {
        if (amountStr == '0') {
          amountStr = key;
        } else {
          if (amountStr.length < 9) {
            amountStr += key;
          }
        }
      }
    });
  }

  void _onSave() async {
    final double amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) return;

    final provider = context.read<FinanceProvider>();
    final transaction = TransactionModel(
      id: widget.existingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      isExpense: isExpense,
      category: selectedCategory,
      note: noteController.text.trim(),
      date: selectedDate,
    );

    try {
      await provider.addTransaction(transaction);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(widget.existingTransaction != null ? 'Edit Transaction' : 'Add Transaction', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          _buildToggle(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          '₹$amountStr',
                          style: AppTextStyles.amountLarge.copyWith(
                            color: isExpense ? AppColors.neonRed : AppColors.neonGreen,
                            fontSize: 56,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCategories(),
                        const SizedBox(height: 24),
                        _buildDateAndNote(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildKeypad(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldAccent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.save, size: 20),
                    const SizedBox(width: 8),
                    Text('Save Transaction', style: AppTextStyles.h3),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateAndNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.goldAccent,
                          onPrimary: AppColors.background,
                          surface: AppColors.cardDark,
                          onSurface: AppColors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.calendar, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: noteController,
                style: AppTextStyles.bodySecondary,
                decoration: InputDecoration(
                  hintText: 'Add note (optional)',
                  hintStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(LucideIcons.fileText, color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _setExpense(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.neonRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Expense',
                    style: AppTextStyles.bodyPrimary.copyWith(
                      color: isExpense ? AppColors.background : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _setExpense(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Income',
                    style: AppTextStyles.bodyPrimary.copyWith(
                      color: !isExpense ? AppColors.background : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: currentCategories.length,
        itemBuilder: (context, index) {
          final cat = currentCategories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cardLight : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? (isExpense ? AppColors.neonRed : AppColors.neonGreen) : AppColors.divider,
                ),
              ),
              child: Text(
                cat,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: isSelected ? (isExpense ? AppColors.neonRed : AppColors.neonGreen) : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1'), _buildKey('2'), _buildKey('3'),
            ],
          ),
          Row(
            children: [
              _buildKey('4'), _buildKey('5'), _buildKey('6'),
            ],
          ),
          Row(
            children: [
              _buildKey('7'), _buildKey('8'), _buildKey('9'),
            ],
          ),
          Row(
            children: [
              _buildKey('.'), _buildKey('0'), _buildKey('delete', icon: LucideIcons.delete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, {IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _onKeyPress(value),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 60,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: AppColors.textPrimary)
                    : Text(value, style: AppTextStyles.h2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
