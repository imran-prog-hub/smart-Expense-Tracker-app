import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/expense_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;
  int _periodIndex = 0; // 0=This Month, 1=Last Month, 2=Custom

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            final byCategory = provider.expensesByCategory;
            final total = provider.totalExpensesThisMonth;
            final sorted = byCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHeader()),
                SliverToBoxAdapter(
                    child: _buildPeriodSelector()),
                SliverToBoxAdapter(
                    child: _buildQuickHighlights(provider, total)),
                SliverToBoxAdapter(
                    child: _buildDonutChart(sorted, total)),
                SliverToBoxAdapter(
                    child: _buildCategoryList(sorted, total)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Analytics',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded,
                color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Month', 'Last Month', 'Custom'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final isSelected = _periodIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _periodIndex = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickHighlights(ExpenseProvider provider, double total) {
    final expenses = provider.expenses.where((e) => !e.isIncome).toList();
    double maxExpense = 0;
    String maxTitle = 'None';
    for (final e in expenses) {
      if (e.amount > maxExpense) {
        maxExpense = e.amount;
        maxTitle = e.title;
      }
    }

    final dailyAvg = expenses.isEmpty
        ? 0.0
        : total / DateTime.now().day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Highlights',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _highlightCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Daily Avg',
                  value: AppUtils.formatCurrency(dailyAvg),
                  sub: 'over ${DateTime.now().day} days',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _highlightCard(
                  icon: Icons.savings_rounded,
                  label: 'Saved',
                  value: AppUtils.formatCurrency(
                      provider.totalIncomeThisMonth - total),
                  sub: provider.totalIncomeThisMonth > 0
                      ? '${((provider.totalIncomeThisMonth - total) / provider.totalIncomeThisMonth * 100).toInt()}% of income'
                      : '-',
                  color: AppTheme.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _highlightCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Largest',
                  value: AppUtils.formatCurrency(maxExpense),
                  sub: maxTitle,
                  color: AppTheme.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _highlightCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDonutChart(
      List<MapEntry<String, double>> sorted, double total) {
    if (sorted.isEmpty) {
      return const SizedBox(height: 200);
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex ??
                                  -1;
                        });
                      },
                    ),
                    sections: sorted.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      final isTouched = i == _touchedIndex;
                      final color =
                          AppConstants.getCategoryColor(e.key);
                      return PieChartSectionData(
                        value: e.value,
                        color: color,
                        radius: isTouched ? 65 : 55,
                        showTitle: false,
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL SPENT',
                        style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 6),
                    Text(
                      AppUtils.formatCurrency(total),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            size: 14, color: AppTheme.expense),
                        SizedBox(width: 4),
                        Text('+141% vs last month',
                            style: TextStyle(
                                color: AppTheme.expense, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      List<MapEntry<String, double>> sorted, double total) {
    if (sorted.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppTheme.cardColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              ...sorted.map((entry) {
                final color = AppConstants.getCategoryColor(entry.key);
                final pct = total > 0 ? (entry.value / total * 100).toInt() : 0;
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        AppConstants.getCategoryEmoji(entry.key),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  title: Text(
                    AppConstants.getCategoryName(entry.key),
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.expense.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('↑ %',
                        style: TextStyle(
                            color: AppTheme.expense, fontSize: 10)),
                  ),
                  subtitleTextStyle:
                      const TextStyle(color: AppTheme.textMuted),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppUtils.formatCurrency(entry.value),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text('$pct%',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16, color: AppTheme.textMuted),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: () {},
                child: const Text('View all categories',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
