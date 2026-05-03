import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class ResidualsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const ResidualsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.where((d) => d['predictedYield'] != null).map((d) {
      final actual = (d['yieldTAcre'] as num).toDouble();
      final predicted = (d['predictedYield'] as num).toDouble();
      return ScatterSpot(predicted, actual - predicted);
    }).toList();

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
                  color: AppColors.deepGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.analytics_rounded,
                  color: AppColors.deepGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model Residuals',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                  Text('Predicted vs actual deviation',
                      style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minY: -1.0,
                maxY: 1.0,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: v == 0
                        ? AppColors.deepGreen.withValues(alpha: 0.4)
                        : const Color(0xFFEEEEEE),
                    strokeWidth: v == 0 ? 2 : 1,
                  ),
                  getDrawingVerticalLine: (_) =>
                      const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Predicted yield',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Residual',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (s) => ScatterTooltipItem(
                      'Pred: \${s.x.toStringAsFixed(2)}\nRes: \${s.y.toStringAsFixed(3)}',
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 11),
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
