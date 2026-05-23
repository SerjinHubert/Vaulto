import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/core/utils/currency_formatter.dart';
import 'package:vaulto/providers/finance_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildBalanceCard(context),
              const SizedBox(height: 16),
              _buildMiniStatsRow(context),
              const SizedBox(height: 16),
              _buildMonthlyBudget(context),
              const SizedBox(height: 16),
              _buildWeeklySpendingChart(context),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    Widget avatarChild;
    if (provider.profileImageBase64 != null && provider.profileImageBase64!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.memory(
          base64Decode(provider.profileImageBase64!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatarChild = Center(
        child: Text(
          provider.firstName.isNotEmpty ? provider.firstName[0].toUpperCase() : 'V', 
          style: AppTextStyles.h2.copyWith(color: AppColors.goldAccent)
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${provider.firstName} ${provider.lastName}'.trim(), style: AppTextStyles.h2),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
          ),
          child: avatarChild,
        )
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.goldAccent.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('TOTAL BALANCE', style: AppTextStyles.label.copyWith(color: AppColors.goldAccent)),
              const SizedBox(width: 8),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  CurrencyFormatter.format(provider.totalBalance),
                  style: AppTextStyles.amountLarge.copyWith(
                    color: provider.totalBalance < 0 ? AppColors.neonRed : AppColors.textPrimary,
                  ),
                ),
              ),
              if (provider.totalBalance < 0)
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.goldAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.goldAccent.withOpacity(0.1),
                    ),
                    child: Text(
                      'Note : You are spending more than your income! SPENDTHRIFT!!!',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.neonRed,
                        fontSize: 9,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceStat('Income', provider.totalIncome, AppColors.neonGreen, LucideIcons.arrowDownCircle),
              _buildBalanceStat('Expenses', provider.totalExpenses, AppColors.neonRed, LucideIcons.arrowUpCircle),
              _buildBalanceStat('Saved', provider.totalSaved, AppColors.goldAccent, LucideIcons.trendingUp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.formatCompact(amount), style: AppTextStyles.bodyPrimary.copyWith(color: color)),
      ],
    );
  }

  Widget _buildMiniStatsRow(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    return Row(
      children: [
        Expanded(child: _buildMiniCard('Subscriptions', CurrencyFormatter.formatCompact(provider.totalSub), LucideIcons.refreshCw, Colors.purpleAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniCard('EMIs', CurrencyFormatter.formatCompact(provider.totalEmi), LucideIcons.creditCard, Colors.blueAccent)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.neonGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.percent, color: AppColors.neonGreen, size: 16),
                ),
                const SizedBox(height: 12),
                Text('${provider.savingsRate}%', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('Savings Rate', style: AppTextStyles.label.copyWith(fontSize: 10)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, color: AppColors.neonGreen, size: 12),
                    const SizedBox(width: 4),
                    Text('Good', style: AppTextStyles.label.copyWith(color: AppColors.neonGreen, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMonthlyBudget(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final spent = provider.monthlySpent;
    final budget = provider.monthlyBudget;
    final percent = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 1.0;
    final isExceeded = spent > budget;
    final exceededAmount = spent - budget;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Monthly Budget', style: AppTextStyles.h3),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showBudgetDialog(context, budget),
                    child: const Icon(LucideIcons.edit2, color: AppColors.goldAccent, size: 16),
                  ),
                ],
              ),
              Text('${(percent * 100).toInt()}% used', style: AppTextStyles.label.copyWith(
                color: isExceeded ? AppColors.neonRed : AppColors.textSecondary,
              )),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.background,
              color: isExceeded ? AppColors.neonRed : AppColors.neonGreen,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent ${CurrencyFormatter.formatCompact(spent)}', style: AppTextStyles.label),
              if (isExceeded)
                Text('Exceeded by ${CurrencyFormatter.formatCompact(exceededAmount)}', style: AppTextStyles.label.copyWith(color: AppColors.neonRed))
              else
                Text('Budget ${CurrencyFormatter.formatCompact(budget)}', style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(text: currentBudget.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text('Set Monthly Budget', style: AppTextStyles.h2),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyPrimary,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: AppTextStyles.bodySecondary,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.bodySecondary),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final val = double.tryParse(controller.text.replaceAll(',', ''));
                if (val != null && val > 0) {
                  context.read<FinanceProvider>().updateMonthlyBudget(val);
                }
                Navigator.pop(context);
              },
              child: Text('Save', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.background)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklySpendingChart(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Spending', style: AppTextStyles.h3),
              Text('Last 7 days', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: provider.weeklySpending.reduce((curr, next) => curr > next ? curr : next) > 0 
                      ? provider.weeklySpending.reduce((curr, next) => curr > next ? curr : next) * 1.2 
                      : 100, // Dynamically set max Y based on spending, or default 100
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(days[value.toInt()], style: AppTextStyles.label),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarData(0, provider.weeklySpending[0]),
                  _makeBarData(1, provider.weeklySpending[1]),
                  _makeBarData(2, provider.weeklySpending[2]),
                  _makeBarData(3, provider.weeklySpending[3]),
                  _makeBarData(4, provider.weeklySpending[4]),
                  _makeBarData(5, provider.weeklySpending[5]),
                  _makeBarData(6, provider.weeklySpending[6], isToday: DateTime.now().weekday == 6), // 6 = Saturday in 0-indexed Sun-Sat array
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y, {bool isToday = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isToday ? AppColors.goldAccent : AppColors.background.withOpacity(0.5),
          width: 24,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
