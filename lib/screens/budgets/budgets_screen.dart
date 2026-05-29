import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/monthly_budget_dialog.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer2<ExpenseProvider, BudgetProvider>(
          builder: (context, expProvider, budgetProvider, _) {
            final byCategory = expProvider.expensesByCategory;
            final totalLimit = budgetProvider.totalMonthlyLimit;
            final totalSpent = expProvider.totalExpensesThisMonth;
            final available = totalLimit - totalSpent;
            final percent = totalLimit > 0
                ? (totalSpent / totalLimit).clamp(0.0, 1.0)
                : 0.0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHeader(context, budgetProvider)),
                SliverToBoxAdapter(
                    child: _buildMonthlySummary(
                        context, budgetProvider, expProvider, available, totalSpent,
                        totalLimit, percent)),
                SliverToBoxAdapter(
                    child: _buildCategoryBudgets(
                        context, budgetProvider, byCategory, expProvider)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BudgetProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Budgets',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          GestureDetector(
            onTap: () => _showAddBudgetDialog(context, provider),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppTheme.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(
    BuildContext context,
    BudgetProvider provider,
    ExpenseProvider expProvider,
    double available,
    double spent,
    double limit,
    double percent,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MONTHLY SUMMARY',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.8)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      provider.previousMonth();
                      expProvider.previousMonth();
                    },
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppTheme.primary, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppUtils.formatMonthYear(provider.selectedMonth)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      provider.nextMonth();
                      expProvider.nextMonth();
                    },
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.primary, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 10,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent > 0.8 ? AppTheme.expense : AppTheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(percent * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AVAILABLE TO SPEND',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(
                      AppUtils.formatCurrency(
                          available.clamp(0, double.infinity)),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up_rounded,
                              size: 12, color: AppTheme.primary),
                          SizedBox(width: 4),
                          Text('Spending Up',
                              style: TextStyle(
                                  color: AppTheme.primary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent ${AppUtils.formatCurrency(spent)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              Text(
                'of ${AppUtils.formatCurrency(limit)}',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => showMonthlyBudgetDialog(context),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded,
                    size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text('Set Budget per Month',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  AppUtils.formatCurrency(limit),
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgets(
    BuildContext context,
    BudgetProvider budgetProvider,
    Map<String, double> byCategory,
    ExpenseProvider expProvider,
  ) {
    final totalAlloc = budgetProvider.totalAllocated;
    final totalLimit = budgetProvider.totalMonthlyLimit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CATEGORIES',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),

          // Allocated overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Budget Allocated',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: AppUtils.formatCurrency(totalAlloc),
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        TextSpan(
                          text:
                              ' / ${AppUtils.formatCurrency(totalLimit)}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalLimit > 0
                        ? (totalAlloc / totalLimit).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppUtils.formatCurrency(budgetProvider.unallocated)} unallocated',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Category budget cards
          ...budgetProvider.budgets.map((budget) {
            final spent = byCategory[budget.categoryId] ?? 0.0;
            final left = budget.limitAmount - spent;
            final pct = budget.limitAmount > 0
                ? (spent / budget.limitAmount).clamp(0.0, 1.0)
                : 0.0;
            final color =
                AppConstants.getCategoryColor(budget.categoryId);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.getCategoryEmoji(
                                budget.categoryId),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.getCategoryName(
                                  budget.categoryId),
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '↑ ${AppUtils.formatCurrency(spent)} ',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11)),
                                TextSpan(
                                  text:
                                      '→ ${AppUtils.formatCurrency(left.clamp(0, double.infinity))} left',
                                  style: TextStyle(
                                      color: left < 0
                                          ? AppTheme.expense
                                          : AppTheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(budget.limitAmount),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showEditBudget(
                            context, budget.categoryId, budgetProvider),
                        child: const Icon(Icons.edit_rounded,
                            size: 16, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct > 0.8 ? AppTheme.expense : color,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, BudgetProvider provider) {
    String? selectedCategory;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add Category Budget',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              dropdownColor: AppTheme.surface,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: AppTheme.textSecondary)),
              items: AppConstants.categories
                  .map((c) => DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(
                          '${c['icon']} ${c['name']}',
                          style: const TextStyle(
                              color: AppTheme.textPrimary))))
                  .toList(),
              onChanged: (v) => selectedCategory = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (selectedCategory != null && amount != null) {
                provider.setBudgetForCategory(selectedCategory!, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }



  void _showEditBudget(
      BuildContext context, String categoryId, BudgetProvider provider) {
    final existing = provider.getBudgetForCategory(categoryId);
    final controller = TextEditingController(
        text: existing?.limitAmount.toStringAsFixed(0) ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
            'Edit ${AppConstants.getCategoryName(categoryId)} Budget',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.deleteBudget(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Remove',
                style: TextStyle(color: AppTheme.expense)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                provider.setBudgetForCategory(categoryId, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
