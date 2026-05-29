import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class DonutChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final double totalAmount;
  final double size;

  const DonutChartWidget({
    super.key,
    required this.data,
    required this.totalAmount,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text('No data',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((e) {
            final color = AppConstants.getCategoryColor(e.key);
            return PieChartSectionData(
              value: e.value,
              color: color,
              radius: size * 0.33,
              showTitle: false,
            );
          }).toList(),
          centerSpaceRadius: size * 0.28,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

class SpendingBarChart extends StatelessWidget {
  final List<double> dailyAmounts;
  final int daysInMonth;

  const SpendingBarChart({
    super.key,
    required this.dailyAmounts,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dailyAmounts.isEmpty
            ? 100
            : dailyAmounts.reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: dailyAmounts.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: AppTheme.primary,
                width: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 7 == 0) {
                  return Text(
                    '${value.toInt() + 1}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppTheme.border,
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
