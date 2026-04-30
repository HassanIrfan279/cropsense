import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class NdviYieldScatter extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const NdviYieldScatter({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.map((d) => ScatterSpot(
      (d['ndvi'] as num).toDouble(),
      (d['yieldTAcre'] as num).toDouble(),
    )).toList();

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
              decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.scatter_plot_rounded, color: AppColors.amber, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NDVI vs Yield', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('Correlation analysis', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minX: 0.2, maxX: 1.0,
                minY: 0.5, maxY: 4.0,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                  getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('NDVI', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Yield (t/ac)', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (spot) => ScatterTooltipItem(
                      'NDVI: \${spot.x.toStringAsFixed(2)}\nYield: \${spot.y.toStringAsFixed(2)} t/ac',
                      textStyle: const TextStyle(color: Colors.white, fontSize: 11),
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
