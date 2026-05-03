import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class ProbabilityCurve extends StatelessWidget {
  final double mean;
  final double std;
  final double threshold;

  const ProbabilityCurve({
    super.key,
    this.mean = 2.1,
    this.std = 0.4,
    this.threshold = 1.2,
  });

  double _normal(double x) {
    final exponent = -0.5 * pow((x - mean) / std, 2);
    return (1 / (std * sqrt(2 * pi))) * exp(exponent);
  }

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    final droughtSpots = <FlSpot>[];

    for (double x = mean - 3 * std; x <= mean + 3 * std; x += 0.05) {
      final y = _normal(x);
      spots.add(FlSpot(x, y));
      if (x <= threshold) droughtSpots.add(FlSpot(x, y));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppColors.burntOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.show_chart_rounded,
                  color: AppColors.burntOrange, size: 18),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Drought Probability',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
              Text(
                  'P(yield < ${threshold}t/ac) = ${_calcProb().toStringAsFixed(1)}%',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                          '${v.toStringAsFixed(1)}t',
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.skyBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.skyBlue.withValues(alpha: 0.08)),
                  ),
                  LineChartBarData(
                    spots: droughtSpots,
                    isCurved: true,
                    color: AppColors.burntOrange,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.burntOrange.withValues(alpha: 0.25)),
                  ),
                ],
                extraLinesData: ExtraLinesData(verticalLines: [
                  VerticalLine(
                    x: threshold,
                    color: AppColors.burntOrange,
                    strokeWidth: 2,
                    dashArray: [6, 4],
                    label: VerticalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Drought\nThreshold',
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.burntOrange),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calcProb() {
    double area = 0;
    for (double x = mean - 4 * std; x <= threshold; x += 0.01) {
      area += _normal(x) * 0.01;
    }
    return area * 100;
  }
}
