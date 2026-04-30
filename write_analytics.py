content = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/providers/crop_yield_provider.dart';
import 'package:cropsense/screens/analytics/widgets/ndvi_chart.dart';
import 'package:cropsense/screens/analytics/widgets/yield_bar_chart.dart';
import 'package:cropsense/screens/analytics/widgets/scatter_chart.dart';
import 'package:cropsense/screens/analytics/widgets/correlation_heatmap.dart';
import 'package:cropsense/screens/analytics/widgets/probability_curve.dart';
import 'package:cropsense/screens/analytics/widgets/residuals_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _district = 'faisalabad';
  String _crop = 'wheat';

  static const _provinceYields = {
    'Punjab': 2.4,
    'Sindh': 1.9,
    'KPK': 2.1,
    'Balochistan': 1.2,
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    final isWide = width >= 1200;
    final yieldAsync = ref.watch(cropYieldProvider((_district, _crop)));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: yieldAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.deepGreen),
              ),
              error: (e, _) => _buildChartGrid(
                _mockChartData(), _provinceYields, isCompact, isWide,
              ),
              data: (response) => _buildChartGrid(
                response.data.map((d) => d.toJson()).toList(),
                _provinceYields, isCompact, isWide,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Text('Analytics', style: AppTextStyles.headingMedium),
          const SizedBox(width: 24),
          const Text('District:',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _district,
            underline: const SizedBox.shrink(),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
            items: AppDistricts.all.take(12).map((d) => DropdownMenuItem(
              value: d['id'],
              child: Text(d['label']!),
            )).toList(),
            onChanged: (v) => setState(() => _district = v!),
          ),
          const SizedBox(width: 20),
          const Text('Crop:',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _crop,
            underline: const SizedBox.shrink(),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
            items: AppCrops.all.map((c) => DropdownMenuItem(
              value: c['id'],
              child: Text(c['label']!),
            )).toList(),
            onChanged: (v) => setState(() => _crop = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildChartGrid(
    List<Map<String, dynamic>> data,
    Map<String, double> provinceYields,
    bool isCompact,
    bool isWide,
  ) {
    final charts = [
      NdviChart(data: data),
      YieldBarChart(provinceYields: provinceYields),
      NdviYieldScatter(data: data),
      const CorrelationHeatmap(),
      const ProbabilityCurve(),
      ResidualsChart(data: data),
    ];

    if (isCompact) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: charts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => SizedBox(height: 280, child: charts[i]),
      );
    }

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: isWide ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isWide ? 1.4 : 1.3,
      children: charts,
    );
  }
}

List<Map<String, dynamic>> _mockChartData() {
  return List.generate(19, (i) {
    final p = i / 18.0;
    final base = 1.8 + p * 0.6;
    final v = 0.3 * (i % 3 == 0 ? -1 : 1);
    return {
      'year': 2005 + i,
      'ndvi': (0.45 + p * 0.25 + (i % 4 == 0 ? -0.1 : 0.05)).clamp(0.2, 0.9),
      'yieldTAcre': (base + v).clamp(0.8, 3.5),
      'predictedYield': base + v * 0.8,
      'rainfallMm': 180.0 + (i % 5) * 40.0,
    };
  });
}
"""

with open('lib/screens/analytics/analytics_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('analytics_screen.dart written successfully!')