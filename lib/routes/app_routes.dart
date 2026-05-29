import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/add_expense/add_expense_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budgets/budgets_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/settings/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String addExpense = '/add-expense';
  static const String analytics = '/analytics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';
  static const String transactions = '/transactions';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings_) {
    switch (settings_.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      case home:
        return _fadeRoute(const HomeScreen());
      case addExpense:
        return _slideUpRoute(const AddExpenseScreen());
      case analytics:
        return _fadeRoute(const AnalyticsScreen());
      case budgets:
        return _fadeRoute(const BudgetsScreen());
      case settings:
        return _fadeRoute(const SettingsScreen());
      case profile:
        return _fadeRoute(const ProfileScreen());
      case transactions:
        return _fadeRoute(const TransactionsScreen());
      default:
        return _fadeRoute(const HomeScreen());
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  static PageRouteBuilder _slideUpRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
