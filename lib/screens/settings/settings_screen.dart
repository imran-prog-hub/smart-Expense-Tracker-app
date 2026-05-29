import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/expense_provider.dart';
import '../../services/csv_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/monthly_budget_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currency = '₹ INR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    const Text('Settings',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _section('Account', [
                      _tile(
                          Icons.person_rounded,
                          'Profile',
                          'Personal account',
                          AppTheme.primary,
                          () => Navigator.pushNamed(context, AppRoutes.profile)),
                      _divider(),
                      _tile(
                          Icons.account_balance_wallet_rounded,
                          'Payment Methods',
                          'Manage cards & wallets',
                          AppTheme.transportColor, () {}),
                    ]),
                    const SizedBox(height: 16),
                    _section('Preferences', [
                      _tileCurrency(),
                      _divider(),
                      _tile(
                          Icons.savings_rounded,
                          'Monthly Budget',
                          'Set budget limits per month',
                          AppTheme.primary,
                          () => showMonthlyBudgetDialog(context)),
                      _divider(),
                      _tileToggle(
                        Icons.notifications_rounded,
                        'Notifications',
                        'Budget alerts & reminders',
                        AppTheme.foodColor,
                        _notificationsEnabled,
                        (v) => setState(() => _notificationsEnabled = v),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _section('Data', [
                      _tile(Icons.download_rounded, 'Export Data',
                          'Download as CSV', AppTheme.income, () async {
                        final expenseProvider = context.read<ExpenseProvider>();
                        final expenses = expenseProvider.expenses;
                        final month = expenseProvider.selectedMonth;
                        
                        final filePath = await CsvService.exportExpensesToCsv(expenses, month);
                        if (!context.mounted) return;
                        if (filePath != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('CSV saved successfully to:\n$filePath'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to export CSV file.'),
                              backgroundColor: AppTheme.expense,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }),
                      _divider(),
                      _tile(Icons.backup_rounded, 'Backup',
                          'Cloud backup', AppTheme.travelColor, () {}),
                    ]),
                    const SizedBox(height: 16),
                    _section('About', [
                      _tile(Icons.info_rounded, 'Version', '1.0.0',
                          AppTheme.textMuted, () {}),
                      _divider(),
                      _tile(Icons.privacy_tip_rounded, 'Privacy Policy',
                          '', AppTheme.textMuted, () {}),
                    ]),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                letterSpacing: 1.0),
          ),
        ),
        Material(
          color: AppTheme.cardColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 14)),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textMuted, size: 18),
      onTap: onTap,
    );
  }

  Widget _tileCurrency() {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.currency_rupee_rounded,
            size: 18, color: AppTheme.primary),
      ),
      title: const Text('Currency',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      trailing: DropdownButton<String>(
        value: _currency,
        dropdownColor: AppTheme.surface,
        underline: const SizedBox(),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        items: ['₹ INR', '\$ USD', '€ EUR', '£ GBP']
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => _currency = v!),
      ),
    );
  }

  Widget _tileToggle(IconData icon, String title, String subtitle,
      Color color, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _divider() {
    return const Divider(
        height: 1, indent: 56, color: AppTheme.border);
  }
}
