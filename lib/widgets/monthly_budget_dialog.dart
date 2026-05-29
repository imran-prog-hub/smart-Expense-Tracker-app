import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';
import '../providers/budget_provider.dart';
import '../services/database_service.dart';

void showMonthlyBudgetDialog(BuildContext context) {
  final provider = context.read<BudgetProvider>();
  
  // Generate a list of months: selected month, and next 11 months.
  final List<DateTime> months = List.generate(12, (index) {
    final now = DateTime.now();
    return DateTime(now.year, now.month + index - 2, 1); // From 2 months ago to 9 months in future
  });

  DateTime selectedMonth = provider.selectedMonth;
  final controller = TextEditingController(
      text: provider.totalMonthlyLimit.toStringAsFixed(0));

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Set Budget per Month',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select the month and specify its budget limit below.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DateTime>(
                  dropdownColor: AppTheme.surface,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  value: months.firstWhere(
                      (m) => m.year == selectedMonth.year && m.month == selectedMonth.month,
                      orElse: () => months[2]),
                  decoration: const InputDecoration(
                    labelText: 'Select Month',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: months.map((date) {
                    final label = AppUtils.formatMonthYear(date);
                    return DropdownMenuItem<DateTime>(
                      value: date,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (newVal) async {
                    if (newVal != null) {
                      setState(() {
                        selectedMonth = newVal;
                      });
                      final db = DatabaseService.instance;
                      final mb = await db.getMonthlyBudget(newVal.month, newVal.year);
                      final val = mb?.limitAmount ?? 1500.0;
                      controller.text = val.toStringAsFixed(0);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Budget Limit',
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
                  if (amount != null) {
                    provider.setMonthlyLimitForMonth(selectedMonth, amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Budget for ${AppUtils.formatMonthYear(selectedMonth)} updated successfully!'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
