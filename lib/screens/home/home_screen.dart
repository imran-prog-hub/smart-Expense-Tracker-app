import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../analytics/analytics_screen.dart';
import '../add_expense/add_expense_screen.dart';
import '../budgets/budgets_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    SizedBox(), // ADD placeholder
    BudgetsScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      // Open Add Expense sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddExpenseScreen(),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: [
          _screens[0],
          _screens[1],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.bar_chart_rounded, 'Analytics'),
              _addButton(),
              _navItem(3, Icons.savings_rounded, 'Budgets'),
              _navItem(4, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final actualIndex = index > 2 ? index - 1 : index;
    final isSelected = _currentIndex == actualIndex ||
        (_currentIndex == 0 && index == 0) ||
        (_currentIndex == 1 && index == 1) ||
        (_currentIndex == 3 && index == 3) ||
        (_currentIndex == 4 && index == 4);

    final selected = (index == 0 && _currentIndex == 0) ||
        (index == 1 && _currentIndex == 1) ||
        (index == 3 && _currentIndex == 2) ||
        (index == 4 && _currentIndex == 3);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) setState(() => _currentIndex = 0);
          if (index == 1) setState(() => _currentIndex = 1);
          if (index == 3) setState(() => _currentIndex = 2);
          if (index == 4) setState(() => _currentIndex = 3);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppTheme.primary : AppTheme.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppTheme.primary : AppTheme.textMuted,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
