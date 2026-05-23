import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/core/utils/currency_formatter.dart';
import 'package:vaulto/providers/finance_provider.dart';
import 'package:vaulto/data/models/transaction_model.dart';

enum AnalyticsPeriod { Day, Week, Month, Year }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.Month;
  DateTime _currentDate = DateTime.now();

  void _nextPeriod() {
    setState(() {
      if (_selectedPeriod == AnalyticsPeriod.Day) {
        _currentDate = _currentDate.add(const Duration(days: 1));
      } else if (_selectedPeriod == AnalyticsPeriod.Week) {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else if (_selectedPeriod == AnalyticsPeriod.Month) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      } else if (_selectedPeriod == AnalyticsPeriod.Year) {
        _currentDate = DateTime(_currentDate.year + 1, 1, 1);
      }
    });
  }

  void _prevPeriod() {
    setState(() {
      if (_selectedPeriod == AnalyticsPeriod.Day) {
        _currentDate = _currentDate.subtract(const Duration(days: 1));
      } else if (_selectedPeriod == AnalyticsPeriod.Week) {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else if (_selectedPeriod == AnalyticsPeriod.Month) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      } else if (_selectedPeriod == AnalyticsPeriod.Year) {
        _currentDate = DateTime(_currentDate.year - 1, 1, 1);
      }
    });
  }

  String _getDateLabel() {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (_selectedPeriod == AnalyticsPeriod.Day) {
      return '${_currentDate.day} ${monthNames[_currentDate.month - 1]} ${_currentDate.year}';
    } else if (_selectedPeriod == AnalyticsPeriod.Week) {
      final start = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day} ${monthNames[start.month - 1]} - ${end.day} ${monthNames[end.month - 1]}';
    } else if (_selectedPeriod == AnalyticsPeriod.Month) {
      return '${monthNames[_currentDate.month - 1]} ${_currentDate.year}';
    } else if (_selectedPeriod == AnalyticsPeriod.Year) {
      return '${_currentDate.year}';
    }
    return '';
  }

  DateTime _getStartDate() {
    if (_selectedPeriod == AnalyticsPeriod.Day) {
      return DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    } else if (_selectedPeriod == AnalyticsPeriod.Week) {
      final start = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
      return DateTime(start.year, start.month, start.day);
    } else if (_selectedPeriod == AnalyticsPeriod.Month) {
      return DateTime(_currentDate.year, _currentDate.month, 1);
    } else {
      return DateTime(_currentDate.year, 1, 1);
    }
  }

  DateTime _getEndDate() {
    if (_selectedPeriod == AnalyticsPeriod.Day) {
      return _getStartDate().add(const Duration(days: 1));
    } else if (_selectedPeriod == AnalyticsPeriod.Week) {
      return _getStartDate().add(const Duration(days: 7));
    } else if (_selectedPeriod == AnalyticsPeriod.Month) {
      return DateTime(_currentDate.year, _currentDate.month + 1, 1);
    } else {
      return DateTime(_currentDate.year + 1, 1, 1);
    }
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> allTransactions) {
    final start = _getStartDate();
    final end = _getEndDate();
    return allTransactions.where((t) => (t.date.isAfter(start) || t.date.isAtSameMomentAs(start)) && t.date.isBefore(end)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final filteredTransactions = _getFilteredTransactions(provider.transactions);

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
                Text('Analytics', style: AppTextStyles.h1),
                _buildTimeToggle(),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateNavigator(),
            const SizedBox(height: 24),
            _buildStatGrid(filteredTransactions),
            const SizedBox(height: 16),
            if (_selectedPeriod != AnalyticsPeriod.Day) ...[
              _buildSpendingTrend(filteredTransactions),
              const SizedBox(height: 16),
              _buildIncomeVsExpense(filteredTransactions),
              const SizedBox(height: 16),
            ] else ...[
              _buildDailyHistory(filteredTransactions),
              const SizedBox(height: 16),
            ],
            _buildCalendar(provider.transactions),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildToggleBtn('Day', AnalyticsPeriod.Day),
          _buildToggleBtn('Week', AnalyticsPeriod.Week),
          _buildToggleBtn('Month', AnalyticsPeriod.Month),
          _buildToggleBtn('Year', AnalyticsPeriod.Year),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, AnalyticsPeriod period) {
    final isActive = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.goldAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isActive ? AppColors.background : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.goldAccent),
          onPressed: _prevPeriod,
        ),
        const SizedBox(width: 16),
        Text(_getDateLabel(), style: AppTextStyles.h3),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(LucideIcons.chevronRight, color: AppColors.goldAccent),
          onPressed: _nextPeriod,
        ),
      ],
    );
  }

  Widget _buildStatGrid(List<TransactionModel> transactions) {
    double spent = 0;
    double earned = 0;
    Map<String, double> categoryTotals = {};

    for (var t in transactions) {
      if (t.isExpense) {
        spent += t.amount;
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0.0) + t.amount;
      } else {
        earned += t.amount;
      }
    }

    double saved = earned - spent;
    int savingsRate = earned > 0 ? ((saved / earned) * 100).round() : 0;
    if (savingsRate < 0) savingsRate = 0;

    int daysInPeriod = _getEndDate().difference(_getStartDate()).inDays;
    if (daysInPeriod <= 0) daysInPeriod = 1;
    double dailyAvg = spent / daysInPeriod;

    String topCategory = 'None';
    double maxCatAmt = 0;
    categoryTotals.forEach((cat, amt) {
      if (amt > maxCatAmt) {
        maxCatAmt = amt;
        topCategory = cat;
      }
    });

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Spent', spent, AppColors.neonRed, LucideIcons.arrowUp)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Earned', earned, AppColors.neonGreen, LucideIcons.arrowDown)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Saved', saved, AppColors.goldAccent, LucideIcons.trendingUp)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextStatCard('Savings Rate', '$savingsRate%', AppColors.neonGreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextStatCard('Daily Avg', CurrencyFormatter.formatCompact(dailyAvg), AppColors.goldAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextStatCard('Top Category', topCategory, AppColors.goldAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.formatCompact(amount), style: AppTextStyles.h3),
        ],
      ),
    );
  }

  Widget _buildTextStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 10)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildSpendingTrend(List<TransactionModel> transactions) {
    List<FlSpot> spots = [];
    String subLabel = '';
    
    if (_selectedPeriod == AnalyticsPeriod.Year) {
      subLabel = 'Monthly Trend';
      List<double> monthly = List.filled(12, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          monthly[t.date.month - 1] += t.amount;
        }
      }
      for (int i = 0; i < 12; i++) {
        spots.add(FlSpot(i.toDouble(), monthly[i]));
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Month) {
      subLabel = 'Daily Trend';
      int days = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
      List<double> daily = List.filled(days, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          daily[t.date.day - 1] += t.amount;
        }
      }
      for (int i = 0; i < days; i++) {
        spots.add(FlSpot(i.toDouble(), daily[i]));
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Week) {
      subLabel = 'Daily Trend (Mon-Sun)';
      List<double> weekly = List.filled(7, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          int dayIndex = t.date.weekday - 1; // 0=Mon, 6=Sun
          weekly[dayIndex] += t.amount;
        }
      }
      for (int i = 0; i < 7; i++) {
        spots.add(FlSpot(i.toDouble(), weekly[i]));
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Day) {
      subLabel = 'Hourly Trend';
      List<double> hourly = List.filled(24, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          hourly[t.date.hour] += t.amount;
        }
      }
      for (int i = 0; i < 24; i++) {
        spots.add(FlSpot(i.toDouble(), hourly[i]));
      }
    }

    double maxAmt = 0;
    for (var spot in spots) {
      if (spot.y > maxAmt) maxAmt = spot.y;
    }
    if (maxAmt == 0) maxAmt = 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Trend', style: AppTextStyles.h3),
              Text(subLabel, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxAmt * 1.2,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.goldAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.goldAccent.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpense(List<TransactionModel> transactions) {
    List<Map<String, dynamic>> barData = [];
    
    if (_selectedPeriod == AnalyticsPeriod.Year) {
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      List<double> inc = List.filled(12, 0.0);
      List<double> exp = List.filled(12, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          exp[t.date.month - 1] += t.amount;
        } else {
          inc[t.date.month - 1] += t.amount;
        }
      }
      for (int i = 0; i < 12; i++) {
        if (inc[i] > 0 || exp[i] > 0) {
          final total = inc[i] + exp[i];
          barData.add({
            'label': monthNames[i],
            'incRatio': inc[i] / total,
            'expRatio': exp[i] / total,
          });
        }
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Month) {
      int days = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
      List<double> inc = List.filled(days, 0.0);
      List<double> exp = List.filled(days, 0.0);
      for (var t in transactions) {
        if (t.isExpense) {
          exp[t.date.day - 1] += t.amount;
        } else {
          inc[t.date.day - 1] += t.amount;
        }
      }
      List<double> weeklyInc = List.filled(5, 0.0);
      List<double> weeklyExp = List.filled(5, 0.0);
      for (int i = 0; i < days; i++) {
        int weekIdx = i ~/ 7;
        if (weekIdx > 4) weekIdx = 4;
        weeklyInc[weekIdx] += inc[i];
        weeklyExp[weekIdx] += exp[i];
      }
      for (int i = 0; i < 5; i++) {
        if (weeklyInc[i] > 0 || weeklyExp[i] > 0) {
          final total = weeklyInc[i] + weeklyExp[i];
          barData.add({
            'label': 'Week ${i + 1}',
            'incRatio': weeklyInc[i] / total,
            'expRatio': weeklyExp[i] / total,
          });
        }
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Week) {
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      List<double> inc = List.filled(7, 0.0);
      List<double> exp = List.filled(7, 0.0);
      for (var t in transactions) {
        int dayIndex = t.date.weekday - 1;
        if (t.isExpense) {
          exp[dayIndex] += t.amount;
        } else {
          inc[dayIndex] += t.amount;
        }
      }
      for (int i = 0; i < 7; i++) {
        if (inc[i] > 0 || exp[i] > 0) {
          final total = inc[i] + exp[i];
          barData.add({
            'label': dayNames[i],
            'incRatio': inc[i] / total,
            'expRatio': exp[i] / total,
          });
        }
      }
    } else if (_selectedPeriod == AnalyticsPeriod.Day) {
      double totalInc = 0;
      double totalExp = 0;
      for (var t in transactions) {
        if (t.isExpense) {
          totalExp += t.amount;
        } else {
          totalInc += t.amount;
        }
      }
      if (totalInc > 0 || totalExp > 0) {
        final total = totalInc + totalExp;
        barData.add({
          'label': 'Today',
          'incRatio': totalInc / total,
          'expRatio': totalExp / total,
        });
      }
    }

    if (barData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
        child: Center(child: Text('No data for this period', style: AppTextStyles.bodySecondary)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Income vs Expense', style: AppTextStyles.h3),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Income', style: AppTextStyles.label.copyWith(fontSize: 10)),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.neonRed, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Expense', style: AppTextStyles.label.copyWith(fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          ...barData.map((data) {
            return _buildMonthBar(data['label'] as String, data['incRatio'] as double, data['expRatio'] as double);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthBar(String label, double incRatio, double expRatio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(label, style: AppTextStyles.label.copyWith(fontSize: 11))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: incRatio,
                  child: Container(height: 6, decoration: BoxDecoration(color: AppColors.neonGreen, borderRadius: BorderRadius.circular(3))),
                ),
                const SizedBox(height: 4),
                FractionallySizedBox(
                  widthFactor: expRatio,
                  child: Container(height: 6, decoration: BoxDecoration(color: AppColors.neonRed, borderRadius: BorderRadius.circular(3))),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailyHistory(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    double totalInc = 0;
    double totalExp = 0;
    for (var t in transactions) {
      if (t.isExpense) totalExp += t.amount;
      else totalInc += t.amount;
    }
    double net = totalInc - totalExp;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily History', style: AppTextStyles.h3),
              Text(
                'Net: ${net >= 0 ? '+' : '-'}${CurrencyFormatter.format(net.abs())}', 
                style: AppTextStyles.label.copyWith(color: net >= 0 ? AppColors.neonGreen : AppColors.neonRed)
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (t.isExpense ? AppColors.neonRed : AppColors.neonGreen).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        t.isExpense ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft, 
                        color: t.isExpense ? AppColors.neonRed : AppColors.neonGreen,
                        size: 20
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
                          ]
                        ],
                      ),
                    ),
                    Text(
                      '${t.isExpense ? '-' : '+'}${CurrencyFormatter.format(t.amount)}',
                      style: AppTextStyles.h3.copyWith(
                        color: t.isExpense ? AppColors.textPrimary : AppColors.neonGreen,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCalendar(List<TransactionModel> allTransactions) {
    int year = _currentDate.year;
    int month = _currentDate.month;
    
    // In Year view, if _currentDate is just Jan 1st (default), maybe show the actual current month if it's the current year
    if (_selectedPeriod == AnalyticsPeriod.Year && _currentDate.year == DateTime.now().year) {
      month = DateTime.now().month;
    }
    
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    
    // Sunday to Saturday layout (S=0, M=1, T=2, W=3, T=4, F=5, S=6)
    // Dart DateTime.weekday: Mon=1 ... Sun=7
    int firstWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calendar', style: AppTextStyles.h3),
              Text('${monthNames[month - 1]} $year', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels.map((l) => Expanded(child: Center(child: Text(l, style: AppTextStyles.label)))).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstWeekday,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              int day = index - firstWeekday + 1;
              return _buildCalendarDay(year, month, day, allTransactions);
            },
          )
        ],
      ),
    );
  }

  Widget _buildCalendarDay(int year, int month, int day, List<TransactionModel> allTransactions) {
    double inc = 0;
    double exp = 0;
    for (var t in allTransactions) {
      if (t.date.year == year && t.date.month == month && t.date.day == day) {
        if (t.isExpense) {
          exp += t.amount;
        } else {
          inc += t.amount;
        }
      }
    }
    
    double net = inc - exp;
    bool hasData = inc > 0 || exp > 0;
    
    Color bgColor = AppColors.background;
    Color textColor = AppColors.textSecondary;
    String netText = '';
    
    if (hasData) {
      if (net > 0) {
        bgColor = AppColors.neonGreen.withOpacity(0.15);
        textColor = AppColors.neonGreen;
        netText = '+${CurrencyFormatter.formatCompact(net)}';
      } else if (net < 0) {
        bgColor = AppColors.neonRed.withOpacity(0.15);
        textColor = AppColors.neonRed;
        netText = '-${CurrencyFormatter.formatCompact(net.abs())}';
      } else {
        bgColor = AppColors.cardLight;
        textColor = AppColors.textPrimary;
        netText = '0';
      }
    }

    bool isSelected = _selectedPeriod == AnalyticsPeriod.Day && _currentDate.year == year && _currentDate.month == month && _currentDate.day == day;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = AnalyticsPeriod.Day;
          _currentDate = DateTime(year, month, day);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.goldAccent, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: AppTextStyles.bodySecondary.copyWith(color: AppColors.textPrimary, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (hasData) ...[
              const SizedBox(height: 2),
              Text(netText, 
                style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
