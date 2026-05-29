import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  int _filterIndex = 0; // 0=All, 1=Income, 2=Expense

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadAllExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: TextStyle(color: AppTheme.textMuted),
            border: InputBorder.none,
            prefixIcon:
                Icon(Icons.search_rounded, color: AppTheme.textMuted),
          ),
          onChanged: (q) {
            context.read<ExpenseProvider>().searchExpenses(q);
          },
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          final all = provider.filteredExpenses;
          double totalIncome = 0;
          double totalExpense = 0;
          for (final e in all) {
            if (e.isIncome) {
              totalIncome += e.amount;
            } else {
              totalExpense += e.amount;
            }
          }

          List filteredList = all;
          if (_filterIndex == 1) {
            filteredList = all.where((e) => e.isIncome).toList();
          } else if (_filterIndex == 2) {
            filteredList = all.where((e) => !e.isIncome).toList();
          }

          return Column(
            children: [
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _filterChip('All', 0),
                    const SizedBox(width: 8),
                    _filterChip('Income', 1),
                    const SizedBox(width: 8),
                    _filterChip('Expense', 2),
                  ],
                ),
              ),

              // Summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.trending_up_rounded,
                                size: 14, color: AppTheme.income),
                            SizedBox(width: 4),
                            Text('INCOME',
                                style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                    letterSpacing: 0.8)),
                          ]),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatCurrency(totalIncome),
                            style: const TextStyle(
                                color: AppTheme.income,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        width: 1, height: 40, color: AppTheme.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.trending_down_rounded,
                                  size: 14, color: AppTheme.expense),
                              SizedBox(width: 4),
                              Text('EXPENSE',
                                  style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 10,
                                      letterSpacing: 0.8)),
                            ]),
                            const SizedBox(height: 4),
                            Text(
                              AppUtils.formatCurrency(totalExpense),
                              style: const TextStyle(
                                  color: AppTheme.expense,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: Text('No transactions',
                            style: TextStyle(
                                color: AppTheme.textMuted)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: filteredList.length,
                        itemBuilder: (_, i) =>
                            ExpenseCard(expense: filteredList[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
