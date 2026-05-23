import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/core/utils/currency_formatter.dart';
import 'package:vaulto/data/models/subscription_model.dart';
import 'package:vaulto/providers/finance_provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final subs = provider.subscriptions;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMI', style: AppTextStyles.h1),
                    Text('& Subscriptions', style: AppTextStyles.label),
                  ],
                ),
                Row(
                  children: [
                    _buildAddBtn('+ EMI', () => _showAddDialog(context, true)),
                    const SizedBox(width: 8),
                    _buildAddBtn('+ Sub', () => _showAddDialog(context, false)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('MONTHLY EMI', provider.totalEmi, provider.subscriptions.where((s) => s.isEmi).length, 'EMIs active', isBlue: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('MONTHLY SUBS', provider.totalSub, provider.subscriptions.where((s) => !s.isEmi).length, 'subscriptions')),
              ],
            ),
            if (subs.any((s) => s.remainingDays <= (s.reminderDays ?? 3))) ...[
              const SizedBox(height: 16),
              _buildWarningBox(subs),
            ],
            const SizedBox(height: 24),
            Text('Active Dues', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              itemBuilder: (context, index) {
                return _buildSubCard(context, subs[index]);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label, style: AppTextStyles.label.copyWith(color: AppColors.goldAccent)),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, int count, String countLabel, {bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isBlue ? Colors.blue.withOpacity(0.3) : AppColors.goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: isBlue ? Colors.blue : AppColors.goldAccent, fontSize: 10)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.format(amount), style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('$count $countLabel', style: AppTextStyles.label),
        ],
      ),
    );
  }

  Widget _buildWarningBox(List<SubscriptionModel> subs) {
    final dueSubs = subs.where((s) => s.remainingDays <= (s.reminderDays ?? 3)).toList();
    if (dueSubs.isEmpty) return const SizedBox.shrink();

    final names = dueSubs.map((s) => s.name).join(', ');
    final message = '$names due soon';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.neonRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySecondary.copyWith(color: AppColors.neonRed)),
          ),
        ],
      ),
    );
  }

  IconData _getIconForName(String name, bool isEmi) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('iphone') || lowerName.contains('phone')) return LucideIcons.smartphone;
    if (lowerName.contains('car')) return LucideIcons.car;
    if (lowerName.contains('bike')) return Icons.motorcycle_outlined;
    if (lowerName.contains('home')) return LucideIcons.home;
    return isEmi ? LucideIcons.creditCard : LucideIcons.playCircle;
  }

  Widget _buildSubCard(BuildContext context, SubscriptionModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: sub.isEmi ? Colors.blue.withOpacity(0.3) : AppColors.goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(_getIconForName(sub.name, sub.isEmi), color: sub.isEmi ? Colors.blue : AppColors.goldAccent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.name, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(sub.durationMonths != null ? 'Monthly • ${sub.durationMonths} Months' : 'Monthly', style: AppTextStyles.label),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.format(sub.amount), style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sub.remainingDays == 1 ? 'Due tomorrow' : (sub.remainingDays == 0 ? 'Due today' : 'Due in ${sub.remainingDays}d'),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.neonRed,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.bell, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(sub.reminderDays != null ? 'Remind ${sub.reminderDays}d before' : 'Reminder', style: AppTextStyles.label),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 24,
                    child: Switch(
                      value: sub.reminderDays != null,
                      onChanged: (val) async {
                        if (val) {
                          final days = await showDialog<int>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.cardDark,
                              title: Text('Remind me before', style: AppTextStyles.h3),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [10, 7, 3, 1].map((d) => ListTile(
                                  title: Text('$d days', style: AppTextStyles.bodyPrimary),
                                  onTap: () => Navigator.pop(context, d),
                                )).toList(),
                              ),
                            ),
                          );
                          if (days != null && context.mounted) {
                            final updatedSub = SubscriptionModel(
                              id: sub.id,
                              name: sub.name,
                              amount: sub.amount,
                              dueDate: sub.dueDate,
                              isEmi: sub.isEmi,
                              reminderDays: days,
                            );
                            await context.read<FinanceProvider>().updateSubscription(updatedSub);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reminder set for $days days before', style: AppTextStyles.bodyPrimary), backgroundColor: AppColors.neonGreen),
                              );
                            }
                          }
                        } else {
                          final updatedSub = SubscriptionModel(
                            id: sub.id,
                            name: sub.name,
                            amount: sub.amount,
                            dueDate: sub.dueDate,
                            isEmi: sub.isEmi,
                            reminderDays: null,
                          );
                          await context.read<FinanceProvider>().updateSubscription(updatedSub);
                        }
                      },
                      activeColor: AppColors.neonGreen,
                      activeTrackColor: AppColors.neonGreen.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditDialog(context, sub),
                    child: const Icon(LucideIcons.edit2, size: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardDark,
                          title: Text('Delete ${sub.name}?', style: AppTextStyles.h3),
                          content: Text('Are you sure you want to delete this ${sub.isEmi ? 'EMI' : 'Subscription'}?', style: AppTextStyles.bodySecondary),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel', style: AppTextStyles.bodySecondary),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete', style: AppTextStyles.bodySecondary.copyWith(color: AppColors.neonRed)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<FinanceProvider>().deleteSubscription(sub.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted successfully', style: AppTextStyles.bodyPrimary), backgroundColor: AppColors.neonRed),
                          );
                        }
                      }
                    },
                    child: const Icon(LucideIcons.trash2, size: 18, color: AppColors.neonRed),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, bool isEmi) {
    String name = '';
    String amountStr = '';
    String durationStr = '';
    DateTime dueDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEmi ? 'Add EMI' : 'Add Subscription', style: AppTextStyles.h2),
                  const SizedBox(height: 24),
                  TextField(
                    style: AppTextStyles.bodyPrimary,
                    decoration: InputDecoration(
                      labelText: 'Name (e.g. Netflix, Car Loan)',
                      labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyPrimary,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                    ),
                    onChanged: (val) => amountStr = val,
                  ),
                  if (isEmi) ...[
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyPrimary,
                      decoration: InputDecoration(
                        labelText: 'Duration (Months)',
                        labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                      ),
                      onChanged: (val) => durationStr = val,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Due Date: ', style: AppTextStyles.bodyPrimary),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.goldAccent,
                                  onPrimary: AppColors.background,
                                  surface: AppColors.cardDark,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) {
                            setState(() => dueDate = date);
                          }
                        },
                        child: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}', style: AppTextStyles.bodySecondary.copyWith(color: AppColors.goldAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amt = double.tryParse(amountStr) ?? 0.0;
                        if (name.isEmpty || amt <= 0) return;
                        
                        final duration = int.tryParse(durationStr);
                        final sub = SubscriptionModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          amount: amt,
                          dueDate: dueDate,
                          isEmi: isEmi,
                          durationMonths: duration,
                        );
                        await context.read<FinanceProvider>().addSubscription(sub);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Save', style: AppTextStyles.h3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, SubscriptionModel sub) {
    String name = sub.name;
    String amountStr = sub.amount.toString();
    String durationStr = sub.durationMonths?.toString() ?? '';
    DateTime dueDate = sub.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit ${sub.isEmi ? 'EMI' : 'Subscription'}', style: AppTextStyles.h2),
                  const SizedBox(height: 24),
                  TextField(
                    controller: TextEditingController(text: name)..selection = TextSelection.collapsed(offset: name.length),
                    style: AppTextStyles.bodyPrimary,
                    decoration: InputDecoration(
                      labelText: 'Name (e.g. Netflix, Car Loan)',
                      labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: amountStr)..selection = TextSelection.collapsed(offset: amountStr.length),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyPrimary,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                    ),
                    onChanged: (val) => amountStr = val,
                  ),
                  if (sub.isEmi) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: durationStr)..selection = TextSelection.collapsed(offset: durationStr.length),
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyPrimary,
                      decoration: InputDecoration(
                        labelText: 'Duration (Months)',
                        labelStyle: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent)),
                      ),
                      onChanged: (val) => durationStr = val,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Due Date: ', style: AppTextStyles.bodyPrimary),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.goldAccent,
                                  onPrimary: AppColors.background,
                                  surface: AppColors.cardDark,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) {
                            setState(() => dueDate = date);
                          }
                        },
                        child: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}', style: AppTextStyles.bodySecondary.copyWith(color: AppColors.goldAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amt = double.tryParse(amountStr) ?? 0.0;
                        if (name.isEmpty || amt <= 0) return;
                        
                        final duration = int.tryParse(durationStr);
                        final updatedSub = SubscriptionModel(
                          id: sub.id,
                          name: name,
                          amount: amt,
                          dueDate: dueDate,
                          isEmi: sub.isEmi,
                          reminderDays: sub.reminderDays,
                          durationMonths: duration,
                        );
                        await context.read<FinanceProvider>().updateSubscription(updatedSub);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Updated successfully', style: AppTextStyles.bodyPrimary), backgroundColor: AppColors.neonGreen),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Save', style: AppTextStyles.h3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
