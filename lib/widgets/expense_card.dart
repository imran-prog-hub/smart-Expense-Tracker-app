import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getCategoryColor(expense.categoryId);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.expense.withOpacity(0.2),
        child: const Icon(Icons.delete_rounded, color: AppTheme.expense),
      ),
      onDismissed: (_) {
        context.read<ExpenseProvider>().deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.title} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primary,
              onPressed: () {},
            ),
            backgroundColor: AppTheme.surface,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppConstants.getCategoryEmoji(expense.categoryId),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppConstants.getCategoryName(expense.categoryId)} · ${AppUtils.formatTime(expense.date)}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${expense.isIncome ? '+' : '-'}${AppUtils.formatCurrency(expense.amount)}',
                  style: TextStyle(
                    color: expense.isIncome ? AppTheme.income : AppTheme.expense,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smartphone_rounded,
                          size: 10, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        expense.paymentMethod.toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
