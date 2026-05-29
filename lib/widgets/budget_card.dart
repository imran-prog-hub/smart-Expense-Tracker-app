import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';
import '../models/budget_model.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final VoidCallback? onEdit;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final left = budget.limitAmount - spent;
    final percent = budget.limitAmount > 0
        ? (spent / budget.limitAmount).clamp(0.0, 1.0)
        : 0.0;
    final color = AppConstants.getCategoryColor(budget.categoryId);
    final isOverBudget = spent > budget.limitAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget ? AppTheme.expense.withOpacity(0.5) : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppConstants.getCategoryEmoji(budget.categoryId),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.getCategoryName(budget.categoryId),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isOverBudget
                          ? 'Over by ${AppUtils.formatCurrency(spent - budget.limitAmount)}'
                          : '${AppUtils.formatCurrency(left)} left',
                      style: TextStyle(
                        color: isOverBudget ? AppTheme.expense : AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatCurrency(budget.limitAmount),
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    AppUtils.formatCurrency(spent),
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_rounded,
                      size: 16, color: AppTheme.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppTheme.expense : color,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
