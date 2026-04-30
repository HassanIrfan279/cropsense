import os

os.makedirs('lib/screens/analytics/widgets', exist_ok=True)

# ── Chart 1: NDVI Timeline ────────────────────────────────────────────
ndvi_chart = """import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class NdviChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const NdviChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      final ndvi = (e.value['ndvi'] as num).toDouble();
      return FlSpot(e.key.toDouble(), ndvi);
    }).toList();

    return _ChartCard(
      title: 'NDVI Trend (2005–2023)',
      subtitle: 'Vegetation health over time',
      color: AppColors.limeGreen,
      icon: Icons.satellite_alt_rounded,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.grey200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (v, _) {
                  final yr = 2005 + v.toInt();
                  return Text(
                    '\$yr',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.limeGreen,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.limeGreen,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.limeGreen.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                'NDVI: \${s.y.toStringAsFixed(3)}\\n\${2005 + s.x.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 12),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    )),
                    Text(subtitle, style: const TextStyle(
                      fontSize: 11, color: Color(0xFF757575),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
"""

# ── Chart 2: Yield Bar Chart ──────────────────────────────────────────
yield_bar = """import 'package:fl_chart/fl_chart.dart';
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
                      '\${provinces[group.x]}\\n\${rod.toY.toStringAsFixed(2)} t/acre',
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
"""

# ── Chart 3: Scatter Chart ────────────────────────────────────────────
scatter = """import 'package:fl_chart/fl_chart.dart';
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
                      'NDVI: \${spot.x.toStringAsFixed(2)}\\nYield: \${spot.y.toStringAsFixed(2)} t/ac',
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
"""

# ── Chart 4: Correlation Heatmap ──────────────────────────────────────
heatmap = """import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class CorrelationHeatmap extends StatefulWidget {
  const CorrelationHeatmap({super.key});
  @override
  State<CorrelationHeatmap> createState() => _CorrelationHeatmapState();
}

class _CorrelationHeatmapState extends State<CorrelationHeatmap> {
  int? _hoveredRow;
  int? _hoveredCol;

  final _labels = ['Yield', 'NDVI', 'Rain', 'TempMax', 'TempMin', 'Soil'];

  final _matrix = const [
    [1.00,  0.82,  0.54, -0.61,  0.23,  0.71],
    [0.82,  1.00,  0.48, -0.53,  0.19,  0.65],
    [0.54,  0.48,  1.00, -0.31,  0.42,  0.58],
    [-0.61,-0.53, -0.31,  1.00, -0.28, -0.44],
    [0.23,  0.19,  0.42, -0.28,  1.00,  0.31],
    [0.71,  0.65,  0.58, -0.44,  0.31,  1.00],
  ];

  Color _cellColor(double v) {
    if (v > 0) return Color.lerp(Colors.white, AppColors.limeGreen, v)!;
    return Color.lerp(Colors.white, AppColors.burntOrange, -v)!;
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.grid_on_rounded, color: AppColors.skyBlue, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Correlation Matrix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('Tap a cell to see correlation', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = (constraints.maxWidth - 48) / _labels.length;
                return Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _labels.map((l) => SizedBox(
                        width: 44,
                        child: Text(l, style: const TextStyle(fontSize: 9, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis),
                      )).toList(),
                    ),
                    Expanded(
                      child: Column(
                        children: List.generate(_matrix.length, (row) => Expanded(
                          child: Row(
                            children: List.generate(_matrix[row].length, (col) {
                              final v = _matrix[row][col];
                              final isHovered = _hoveredRow == row && _hoveredCol == col;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _hoveredRow = row;
                                    _hoveredCol = col;
                                  }),
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() { _hoveredRow = row; _hoveredCol = col; }),
                                    onExit: (_) => setState(() { _hoveredRow = null; _hoveredCol = null; }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: _cellColor(v),
                                        borderRadius: BorderRadius.circular(3),
                                        border: isHovered ? Border.all(color: AppColors.deepGreen, width: 2) : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          v.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: v.abs() > 0.5 ? Colors.white : const Color(0xFF424242),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_hoveredRow != null && _hoveredCol != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.deepGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '\${_labels[_hoveredRow!]} ↔ \${_labels[_hoveredCol!]}: \${_matrix[_hoveredRow!][_hoveredCol!].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepGreen),
              ),
            ),
        ],
      ),
    );
  }
}
"""

# ── Chart 5: Probability Curve ────────────────────────────────────────
probability = """import 'dart:math';
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
              decoration: BoxDecoration(color: AppColors.burntOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.show_chart_rounded, color: AppColors.burntOrange, size: 18),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Drought Probability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('P(yield < \${threshold}t/ac) = \${_calcProb().toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text('\${v.toStringAsFixed(1)}t', style: const TextStyle(fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.skyBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.skyBlue.withValues(alpha: 0.08)),
                  ),
                  LineChartBarData(
                    spots: droughtSpots,
                    isCurved: true,
                    color: AppColors.burntOrange,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.burntOrange.withValues(alpha: 0.25)),
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
                      labelResolver: (_) => 'Drought\\nThreshold',
                      style: const TextStyle(fontSize: 9, color: AppColors.burntOrange),
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
"""

# ── Chart 6: Residuals Chart ──────────────────────────────────────────
residuals = """import 'package:fl_chart/fl_chart.dart';
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
              decoration: BoxDecoration(color: AppColors.deepGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.analytics_rounded, color: AppColors.deepGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Model Residuals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              Text('Predicted vs actual deviation', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ]),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minY: -1.0, maxY: 1.0,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: v == 0 ? AppColors.deepGreen.withValues(alpha: 0.4) : const Color(0xFFEEEEEE),
                    strokeWidth: v == 0 ? 2 : 1,
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Predicted yield', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 9, color: Color(0xFF757575))),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Residual', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
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
                    getTooltipItems: (s) => ScatterTooltipItem(
                      'Pred: \${s.x.toStringAsFixed(2)}\\nRes: \${s.y.toStringAsFixed(3)}',
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
"""

# Write all files
files = {
    'lib/screens/analytics/widgets/ndvi_chart.dart': ndvi_chart,
    'lib/screens/analytics/widgets/yield_bar_chart.dart': yield_bar,
    'lib/screens/analytics/widgets/scatter_chart.dart': scatter,
    'lib/screens/analytics/widgets/correlation_heatmap.dart': heatmap,
    'lib/screens/analytics/widgets/probability_curve.dart': probability,
    'lib/screens/analytics/widgets/residuals_chart.dart': residuals,
}

for path, content in files.items():
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Written: {path}')

print('\nAll 6 chart widgets written successfully!')