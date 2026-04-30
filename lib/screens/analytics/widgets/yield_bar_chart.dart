import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class YieldBarChart extends StatelessWidget {
  final Map<String, double> provinceYields;
  const YieldBarChart({super.key, required this.provinceYields});

  @override
  Widget build(BuildContext context) {
    final provinces = provinceYields.keys.toList();
    final values = provinceYields.values.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.skyBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bar_chart_rounded, color: AppColors.skyBlue, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Yield by Province', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('Average tonnes/acre', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final labels = ['Punjab', 'Sindh', 'KPK', 'Baloch'];
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Color(0xFF757575))),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Color(0xFF757575))),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(values.length, (i) => BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(
                    toY: values[i],
                    color: AppColors.cropColors[i % AppColors.cropColors.length],
                    width: 32,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  )],
                )),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '\${provinces[group.x]}\n\${rod.toY.toStringAsFixed(2)} t/acre',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
