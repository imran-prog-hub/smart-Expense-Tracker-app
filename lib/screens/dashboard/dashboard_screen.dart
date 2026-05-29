import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/expense_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/expense_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer2<ExpenseProvider, BudgetProvider>(
          builder: (context, expProvider, budgetProvider, _) {
            return RefreshIndicator(
              onRefresh: () async {
                await expProvider.loadExpenses();
                await budgetProvider.loadBudgets();
              },
              color: AppTheme.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, expProvider)),
                  SliverToBoxAdapter(
                      child: _buildBudgetCard(context, expProvider, budgetProvider)),
                  SliverToBoxAdapter(
                      child: _buildMonthlyFlow(context, expProvider)),
                  SliverToBoxAdapter(
                      child: _buildRecentTransactions(context, expProvider)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERSONAL',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMMM yyyy').format(provider.selectedMonth),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  provider.previousMonth();
                  context.read<BudgetProvider>().previousMonth();
                },
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppTheme.textSecondary),
              ),
              IconButton(
                onPressed: () {
                  provider.nextMonth();
                  context.read<BudgetProvider>().nextMonth();
                },
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded,
                    color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, ExpenseProvider expProvider,
      BudgetProvider budgetProvider) {
    final limit = budgetProvider.totalMonthlyLimit;
    final spent = expProvider.totalExpensesThisMonth;
    final left = limit - spent;
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final daysLeft = AppUtils.daysRemainingInMonth(DateTime.now());

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEFT TO SPEND',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(left.clamp(0, double.infinity)),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'OF ${AppUtils.formatCurrency(limit)} BUDGET',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10),
                  ),
                  Text(
                    '${AppUtils.formatCurrency(spent)} SPENT',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.8 ? AppTheme.expense : AppTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percent * 100).toInt()}% OF BUDGET SPENT',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '$daysLeft DAYS LEFT',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyFlow(BuildContext context, ExpenseProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MONTHLY FLOW',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.balance >= 0
                      ? AppTheme.primary.withOpacity(0.15)
                      : AppTheme.expense.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.balance >= 0 ? '+' : ''}${AppUtils.formatCurrency(provider.balance)}',
                  style: TextStyle(
                    color: provider.balance >= 0
                        ? AppTheme.primary
                        : AppTheme.expense,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _flowRow(
            icon: Icons.trending_up_rounded,
            label: 'Income',
            amount: provider.totalIncomeThisMonth,
            color: AppTheme.income,
          ),
          const SizedBox(height: 12),
          _flowRow(
            icon: Icons.trending_down_rounded,
            label: 'Expenses',
            amount: provider.totalExpensesThisMonth,
            color: AppTheme.expense,
          ),
          const Divider(color: AppTheme.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _periodStat('TODAY',
                  AppUtils.formatCurrency(provider.todayExpenses)),
              _periodStat('THIS WEEK',
                  AppUtils.formatCurrency(provider.thisWeekExpenses)),
              _periodStat('THIS MONTH',
                  AppUtils.formatCurrency(provider.totalExpensesThisMonth)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowRow({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(
          AppUtils.formatCurrency(amount),
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _periodStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 10, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildRecentTransactions(
      BuildContext context, ExpenseProvider provider) {
    final grouped = provider.groupedExpenses;
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.receipt_long_rounded,
                  size: 48, color: AppTheme.textMuted),
              SizedBox(height: 12),
              Text('No transactions yet',
                  style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.transactions),
                child: const Text('See all',
                    style: TextStyle(color: AppTheme.primary, fontSize: 13)),
              ),
            ],
          ),
        ),
        ...grouped.entries.take(3).map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              ...entry.value
                  .take(3)
                  .map((e) => ExpenseCard(expense: e))
                  .toList(),
            ],
          );
        }).toList(),
      ],
    );
  }
}
