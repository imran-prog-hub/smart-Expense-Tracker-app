import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppConstants {
  // Categories
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'food',
      'name': 'Food',
      'icon': '🍽️',
      'color': AppTheme.foodColor,
    },
    {
      'id': 'transport',
      'name': 'Transport',
      'icon': '🚗',
      'color': AppTheme.transportColor,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': '🛍️',
      'color': AppTheme.shoppingColor,
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'icon': '🎬',
      'color': AppTheme.entertainColor,
    },
    {
      'id': 'health',
      'name': 'Health',
      'icon': '❤️',
      'color': AppTheme.healthColor,
    },
    {
      'id': 'bills',
      'name': 'Bills',
      'icon': '🧾',
      'color': AppTheme.billsColor,
    },
    {
      'id': 'travel',
      'name': 'Travel',
      'icon': '✈️',
      'color': AppTheme.travelColor,
    },
    {
      'id': 'other',
      'name': 'Other',
      'icon': '📦',
      'color': AppTheme.otherColor,
    },
  ];

  // Payment methods
  static const List<Map<String, dynamic>> paymentMethods = [
    {'id': 'cash', 'name': 'Cash', 'icon': '💵'},
    {'id': 'digital', 'name': 'Digital', 'icon': '📱'},
    {'id': 'card', 'name': 'Card', 'icon': '💳'},
    {'id': 'upi', 'name': 'UPI', 'icon': '📲'},
  ];

  static Map<String, dynamic>? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c['id'] == id);
    } catch (_) {
      return categories.last;
    }
  }

  static Color getCategoryColor(String categoryId) {
    final cat = getCategoryById(categoryId);
    return cat?['color'] ?? AppTheme.otherColor;
  }

  static String getCategoryEmoji(String categoryId) {
    final cat = getCategoryById(categoryId);
    return cat?['icon'] ?? '📦';
  }

  static String getCategoryName(String categoryId) {
    final cat = getCategoryById(categoryId);
    return cat?['name'] ?? 'Other';
  }
}
