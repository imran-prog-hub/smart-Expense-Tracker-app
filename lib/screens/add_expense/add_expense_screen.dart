import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String _amount = '0';
  String _selectedCategory = 'food';
  String _selectedPayment = 'Amazon Pay ••321';
  DateTime _selectedDate = DateTime.now();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onNumPress(String value) {
    setState(() {
      if (value == 'del') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) _amount += '.';
      } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        // Operators (basic)
      } else {
        if (_amount == '0') {
          _amount = value;
        } else {
          if (_amount.length < 10) _amount += value;
        }
      }
    });
  }

  void _setSuggestedAmount(double amount) {
    setState(() => _amount = amount.toString());
  }

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) return;

    final titleStr = _titleController.text.trim();
    final noteStr = _noteController.text.trim();

    final title = titleStr.isEmpty
        ? AppConstants.getCategoryName(_selectedCategory)
        : titleStr;
        
    final note = noteStr.isEmpty ? null : noteStr;

    await context.read<ExpenseProvider>().addExpense(
          title: title,
          amount: amount,
          categoryId: _selectedCategory,
          paymentMethod: _selectedPayment,
          date: _selectedDate,
          isIncome: _isIncome,
          note: note,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = [0.61, 1.39, 0.59, 16.66, 38.89];

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textSecondary, size: 20),
                ),
                const Spacer(),
                // Date picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          AppUtils.formatDate(_selectedDate),
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isIncome = false;
                              _selectedCategory = 'food';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isIncome
                                    ? AppTheme.expense.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: !_isIncome
                                    ? Border.all(color: AppTheme.expense, width: 1)
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_down_rounded,
                                      size: 16,
                                      color: !_isIncome ? AppTheme.expense : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Expense',
                                      style: TextStyle(
                                        color: !_isIncome ? AppTheme.textPrimary : AppTheme.textMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isIncome = true;
                              _selectedCategory = 'other';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isIncome
                                    ? AppTheme.income.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: _isIncome
                                    ? Border.all(color: AppTheme.income, width: 1)
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 16,
                                      color: _isIncome ? AppTheme.income : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Income',
                                      style: TextStyle(
                                        color: _isIncome ? AppTheme.textPrimary : AppTheme.textMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Debit from / Credit to
                  Text(_isIncome ? 'Credited To' : 'Debited From',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _paymentChip('Amazon Pay ••321', true),
                      const SizedBox(width: 8),
                      _addChip(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Amount display
                  const Text('Amount',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('₹ ',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 28)),
                      Text(
                        _amount,
                        style: TextStyle(
                          color: _isIncome ? AppTheme.income : AppTheme.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(' |',
                          style: TextStyle(
                              color: AppTheme.primary, fontSize: 40)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Suggestions
                  Row(
                    children: [
                      const Text('SUGGESTED',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              letterSpacing: 0.8)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: suggestions
                                .map((s) => _suggestionChip(s))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // AI suggestion
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_fix_high_rounded,
                            size: 16, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Looks like ${AppConstants.getCategoryName(_selectedCategory)}',
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 13),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: const Text('SELECT CATEGORY',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category chips
                  const Text('Category',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = AppConstants.categories[i];
                        final isSelected = _selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (cat['color'] as Color).withOpacity(0.2)
                                  : AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: cat['color'] as Color,
                                      width: 1.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(cat['icon'],
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? cat['color'] as Color
                                        : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title / Source
                  Text(_isIncome ? 'Income Source / Title' : 'Title / Description',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _isIncome ? 'e.g. Salary, Daily work, Mom given' : 'e.g. Tea Corner, Groceries',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.title_rounded, size: 18, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Short Note / Reason
                  const Text('Short Notes / Remarks',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. mom given, extra hours work, pocket money',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.notes_rounded, size: 18, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numpad
          _buildNumpad(),

          // Add button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 8),
            child: ElevatedButton(
              onPressed: _addExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isIncome ? AppTheme.income : AppTheme.primary,
                foregroundColor: Colors.black,
              ),
              child: Text(_isIncome ? 'Add Income' : 'Add Expense',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['.', '0', 'del', '+'],
    ];

    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => _onNumPress(key),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: key == 'del'
                            ? AppTheme.expense.withOpacity(0.2)
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: key == 'del'
                            ? const Icon(Icons.backspace_outlined,
                                color: AppTheme.expense, size: 20)
                            : Text(
                                key,
                                style: TextStyle(
                                  color: ['÷', '×', '-', '+']
                                          .contains(key)
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _paymentChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withOpacity(0.15)
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: AppTheme.primary, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            const Icon(Icons.star_rounded, size: 14, color: AppTheme.primary),
          if (isSelected) const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _addChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, size: 14, color: AppTheme.textSecondary),
          SizedBox(width: 4),
          Text('Add',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _suggestionChip(double amount) {
    return GestureDetector(
      onTap: () => _setSuggestedAmount(amount),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          AppUtils.formatCurrency(amount),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children: AppConstants.categories.map((cat) {
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat['id']);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (cat['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(cat['icon'],
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(cat['name'],
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
