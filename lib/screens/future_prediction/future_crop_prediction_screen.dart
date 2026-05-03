import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/providers/future_prediction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FutureCropPredictionScreen extends ConsumerWidget {
  const FutureCropPredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(futurePredictionFormProvider);
    final prediction = ref.watch(futurePredictionProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _Header(form: form),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PredictionFormPanel(form: form),
                      const SizedBox(height: 18),
                      prediction.when(
                        data: (data) => data == null
                            ? const _EmptyPredictionState()
                            : _PredictionReport(
                                data: data,
                                onDownload: () => _downloadPdf(data),
                              ),
                        loading: () => const _LoadingReport(),
                        error: (error, _) =>
                            _ErrorReport(message: error.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(Map<String, dynamic> data) async {
    final filters = _map(data['filters']);
    final comparison = _rows(data['comparison']);
    final crops = _rows(data['crops']);
    final district = _title(filters['district']?.toString() ?? 'district');

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        build: (context) => [
          pw.Text(
            'Future Crop Prediction Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Location: $district'),
          pw.Text(
            'Range: ${filters['predictionYears']} years | Area: ${_num(filters['farmAcres']).toStringAsFixed(1)} acres | Soil: ${filters['soilType']} | Water: ${filters['waterAvailability']}',
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('FFF8E1'),
              border: pw.Border.all(color: PdfColor.fromHex('FFB300')),
            ),
            child: pw.Text(data['warning']?.toString() ?? ''),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Final Recommendation',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(data['finalAIRecommendation']?.toString() ?? ''),
          pw.SizedBox(height: 16),
          pw.Text(
            'Crop Comparison',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Crop',
              'Avg Production',
              'Avg Profit',
              'Risk',
              'Confidence',
            ],
            data: comparison
                .map(
                  (row) => [
                    row['cropLabel']?.toString() ?? '',
                    '${_num(row['averageProductionTons']).toStringAsFixed(1)} t',
                    _money(_num(row['averageProfitPkr'])),
                    row['riskLevel']?.toString() ?? '',
                    '${_num(row['confidenceScore']).toStringAsFixed(0)}%',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 16),
          ...crops.map((crop) {
            final summary = _map(crop['summary']);
            final yearly = _rows(crop['yearly']);
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  crop['cropLabel']?.toString() ?? '',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(crop['finalAIRecommendation']?.toString() ?? ''),
                pw.Text(
                  'Average profit: ${_money(_num(summary['averageProfitPkr']))}, risk: ${summary['riskLevel']}, confidence: ${summary['confidenceScore']}%',
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: const [
                    'Year',
                    'Production',
                    'Cost',
                    'Profit',
                    'Risk'
                  ],
                  data: yearly
                      .map(
                        (row) => [
                          row['year'].toString(),
                          '${_num(row['estimatedProductionTons']).toStringAsFixed(1)} t',
                          _money(_num(row['expectedTotalCostPkr'])),
                          _money(_num(row['expectedProfitPkr'])),
                          row['riskLevel'].toString(),
                        ],
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 14),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'Future_Crop_Prediction_$district.pdf',
    );
  }
}

class _Header extends StatelessWidget {
  final FuturePredictionForm form;

  const _Header({required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: const BoxDecoration(gradient: AppGradients.heroGreen),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: AppColors.limeGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Future Crop Prediction',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Forecast production, cost, profit, market demand, water needs, and risk for ${form.predictionYears} years.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width >= 760)
            _HeaderBadge(
              label:
                  '${districtLabel(form.district)} / ${form.crops.length} crops',
            ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;

  const _HeaderBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.place_rounded, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}

class _PredictionFormPanel extends ConsumerWidget {
  final FuturePredictionForm form;

  const _PredictionFormPanel({required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(futurePredictionFormProvider.notifier);
    final busy = ref.watch(futurePredictionProvider) is AsyncLoading;

    return _Panel(
      title: 'Prediction inputs',
      subtitle:
          'Choose one or more crops to compare under the same farm scenario.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crops', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppCrops.all.map((crop) {
              final cropId = crop['id']!;
              final selected = form.crops.contains(cropId);
              return FilterChip(
                label: Text(crop['label']!),
                selected: selected,
                onSelected: (_) => notifier.toggleCrop(cropId),
                avatar: Icon(
                  selected ? Icons.check_circle_rounded : Icons.grass_rounded,
                  size: 15,
                ),
                selectedColor: AppColors.deepGreen.withValues(alpha: 0.14),
                side: BorderSide(
                  color: selected ? AppColors.deepGreen : AppColors.grey200,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final firstRow = [
                _DropdownField<String>(
                  label: 'Farmer location',
                  value: form.district,
                  items: AppDistricts.all
                      .map(
                        (district) => DropdownMenuItem(
                          value: district['id'],
                          child: Text(district['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: notifier.setDistrict,
                ),
                _DropdownField<String>(
                  label: 'Soil type',
                  value: form.soilType,
                  items: const ['loam', 'clay', 'sandy', 'saline', 'mixed']
                      .map(
                        (soil) => DropdownMenuItem(
                          value: soil,
                          child: Text(_title(soil)),
                        ),
                      )
                      .toList(),
                  onChanged: notifier.setSoilType,
                ),
                _DropdownField<String>(
                  label: 'Water availability',
                  value: form.waterAvailability,
                  items: const ['low', 'medium', 'high']
                      .map(
                        (water) => DropdownMenuItem(
                          value: water,
                          child: Text(_title(water)),
                        ),
                      )
                      .toList(),
                  onChanged: notifier.setWaterAvailability,
                ),
              ];
              final secondRow = [
                _SliderField(
                  label: 'Farming area',
                  value: form.farmAcres,
                  min: 1,
                  max: 250,
                  suffix: ' acres',
                  onChanged: notifier.setFarmAcres,
                ),
                _SliderField(
                  label: 'Budget',
                  value: form.budgetPkr,
                  min: 25000,
                  max: 3000000,
                  money: true,
                  onChanged: notifier.setBudget,
                ),
                _RangeSelector(
                  value: form.predictionYears,
                  onChanged: notifier.setPredictionYears,
                ),
              ];

              return Column(
                children: [
                  _ResponsiveFields(compact: compact, children: firstRow),
                  const SizedBox(height: 12),
                  _ResponsiveFields(compact: compact, children: secondRow),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () =>
                          ref.read(futurePredictionProvider.notifier).predict(),
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_graph_rounded),
                  label: Text(busy ? 'Predicting...' : 'Generate Prediction'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(futurePredictionProvider.notifier).clear(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PredictionReport extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDownload;

  const _PredictionReport({required this.data, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final filters = _map(data['filters']);
    final comparison = _rows(data['comparison']);
    final bestCrop = data['bestCrop']?.toString() ?? '';
    final highestRisk = data['highestRiskCrop']?.toString() ?? '';
    final avgProfit = comparison.isEmpty
        ? 0.0
        : comparison
                .map((row) => _num(row['averageProfitPkr']))
                .reduce((a, b) => a + b) /
            comparison.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WarningNotice(
          title: 'Forecast uncertainty',
          message: data['warning']?.toString() ?? '',
          source: data['dataSource']?.toString() ?? '',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Prediction report',
                style: AppTextStyles.headingMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Download PDF'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _KpiGrid(
          cards: [
            _KpiData(
              'Best crop',
              cropLabel(bestCrop),
              Icons.workspace_premium_rounded,
              AppColors.deepGreen,
            ),
            _KpiData(
              'Highest risk',
              cropLabel(highestRisk),
              Icons.warning_amber_rounded,
              AppColors.burntOrange,
            ),
            _KpiData(
              'Average profit',
              _money(avgProfit),
              Icons.payments_rounded,
              AppColors.skyBlue,
            ),
            _KpiData(
              'Forecast range',
              '${filters['predictionYears']} years',
              Icons.timeline_rounded,
              AppColors.amber,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Panel(
          title: 'Final AI recommendation',
          subtitle: 'Scenario-based recommendation from the prediction model',
          child: Text(
            data['finalAIRecommendation']?.toString() ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _ChartGrid(data: data),
        const SizedBox(height: 14),
        _ComparisonTable(rows: comparison),
        const SizedBox(height: 14),
        _CropDetailList(crops: _rows(data['crops'])),
      ],
    );
  }
}

class _ChartGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ChartGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final charts = [
          _PredictionLineChart(
            data: data,
            title: 'Year-by-year yield',
            subtitle: 'Estimated tonnes per acre',
            metricKey: 'estimatedYieldTAcre',
            yLabel: 't/acre',
          ),
          _PredictionLineChart(
            data: data,
            title: 'Expected cost',
            subtitle: 'Total cost for selected farm area',
            metricKey: 'expectedTotalCostPkr',
            yLabel: 'PKR',
            money: true,
          ),
          _PredictionLineChart(
            data: data,
            title: 'Expected profit',
            subtitle: 'Revenue minus projected input cost',
            metricKey: 'expectedProfitPkr',
            yLabel: 'PKR',
            money: true,
          ),
          _PredictionLineChart(
            data: data,
            title: 'Risk trend',
            subtitle: 'Weather, disease, market, and budget risk',
            metricKey: 'riskScore',
            yLabel: 'risk',
            percent: true,
          ),
        ];
        if (compact) {
          return Column(
            children: charts
                .map(
                  (chart) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: chart,
                  ),
                )
                .toList(),
          );
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          physics: const NeverScrollableScrollPhysics(),
          children: charts,
        );
      },
    );
  }
}

class _PredictionLineChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String subtitle;
  final String metricKey;
  final String yLabel;
  final bool money;
  final bool percent;

  const _PredictionLineChart({
    required this.data,
    required this.title,
    required this.subtitle,
    required this.metricKey,
    required this.yLabel,
    this.money = false,
    this.percent = false,
  });

  @override
  Widget build(BuildContext context) {
    final crops = _rows(data['crops']);
    final bars = <LineChartBarData>[];
    final allSpots = <FlSpot>[];

    for (var index = 0; index < crops.length; index++) {
      final yearly = _rows(crops[index]['yearly']);
      final spots = yearly
          .map((row) => FlSpot(_num(row['year']), _num(row[metricKey])))
          .where((spot) => spot.x > 0)
          .toList();
      if (spots.isEmpty) continue;
      allSpots.addAll(spots);
      final color = AppColors.cropColors[index % AppColors.cropColors.length];
      bars.add(
        LineChartBarData(
          spots: spots,
          color: color,
          barWidth: 2.5,
          isCurved: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.06),
          ),
        ),
      );
    }

    return _Panel(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            child: allSpots.isEmpty
                ? const Center(child: Text('No chart data available.'))
                : LineChart(
                    LineChartData(
                      minX: allSpots.map((spot) => spot.x).reduce(mathMin),
                      maxX: allSpots.map((spot) => spot.x).reduce(mathMax),
                      minY: _minY(allSpots),
                      maxY: _maxY(allSpots),
                      gridData:
                          const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: bars,
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 54,
                            getTitlesWidget: (value, _) => Text(
                              _axis(value, money: money, percent: percent),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, _) => Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF1B2B1E),
                          getTooltipItems: (items) => items.map((item) {
                            return LineTooltipItem(
                              '${item.x.toInt()}\n$yLabel: ${_axis(item.y, money: money, percent: percent)}',
                              const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          _Legend(crops: crops),
          const SizedBox(height: 8),
          Text(
            'Use this chart to compare direction, not as a guaranteed future value. Wider range means lower certainty.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  static double _minY(List<FlSpot> spots) {
    final min = spots.map((spot) => spot.y).reduce(mathMin);
    final max = spots.map((spot) => spot.y).reduce(mathMax);
    final pad = (max - min).abs() * 0.14;
    return min - (pad == 0 ? 1 : pad);
  }

  static double _maxY(List<FlSpot> spots) {
    final min = spots.map((spot) => spot.y).reduce(mathMin);
    final max = spots.map((spot) => spot.y).reduce(mathMax);
    final pad = (max - min).abs() * 0.14;
    return max + (pad == 0 ? 1 : pad);
  }
}

class _Legend extends StatelessWidget {
  final List<Map<String, dynamic>> crops;

  const _Legend({required this.crops});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: List.generate(crops.length, (index) {
        final color = AppColors.cropColors[index % AppColors.cropColors.length];
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            crops[index]['cropLabel']?.toString() ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.grey600),
          ),
        ]);
      }),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _ComparisonTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Crop comparison',
      subtitle: 'Average forecast values for the selected range',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.grey100),
          columns: const [
            DataColumn(label: Text('Rank')),
            DataColumn(label: Text('Crop')),
            DataColumn(label: Text('Avg production')),
            DataColumn(label: Text('Avg profit')),
            DataColumn(label: Text('Demand')),
            DataColumn(label: Text('Risk')),
            DataColumn(label: Text('Confidence')),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text('${row['recommendationRank'] ?? '-'}')),
                DataCell(Text(row['cropLabel']?.toString() ?? '')),
                DataCell(Text(
                    '${_num(row['averageProductionTons']).toStringAsFixed(1)} t')),
                DataCell(Text(_money(_num(row['averageProfitPkr'])))),
                DataCell(Text(row['marketDemandTrend']?.toString() ?? '')),
                DataCell(_RiskBadge(level: row['riskLevel']?.toString() ?? '')),
                DataCell(Text(
                    '${_num(row['confidenceScore']).toStringAsFixed(0)}%')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CropDetailList extends StatelessWidget {
  final List<Map<String, dynamic>> crops;

  const _CropDetailList({required this.crops});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: crops.map((crop) => _CropDetailCard(crop: crop)).toList(),
    );
  }
}

class _CropDetailCard extends StatelessWidget {
  final Map<String, dynamic> crop;

  const _CropDetailCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final summary = _map(crop['summary']);
    final yearly = _rows(crop['yearly']);
    final first = yearly.isNotEmpty ? yearly.first : <String, dynamic>{};
    final fertilizer = _list(first['fertilizerNeeds']);
    final weather = _list(first['weatherRisks']);
    final disease = _list(first['diseasePestRisks']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Panel(
        title: crop['cropLabel']?.toString() ?? '',
        subtitle: 'Detailed forecast, risks, water, and input needs',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniMetric(
                  label: 'Avg production',
                  value:
                      '${_num(summary['averageProductionTons']).toStringAsFixed(1)} t',
                ),
                _MiniMetric(
                  label: 'Avg profit',
                  value: _money(_num(summary['averageProfitPkr'])),
                ),
                _MiniMetric(
                  label: 'Water need',
                  value: '${first['waterRequirementMm'] ?? '-'} mm',
                ),
                _MiniMetric(
                  label: 'Confidence',
                  value: '${summary['confidenceScore'] ?? '-'}%',
                ),
                _RiskBadge(level: summary['riskLevel']?.toString() ?? ''),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              crop['finalAIRecommendation']?.toString() ?? '',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            _InfoColumns(
              columns: [
                _InfoColumnData('Fertilizer needs', fertilizer),
                _InfoColumnData('Weather risks', weather),
                _InfoColumnData('Disease/pest risks', disease),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Year')),
                  DataColumn(label: Text('Production')),
                  DataColumn(label: Text('Cost')),
                  DataColumn(label: Text('Profit')),
                  DataColumn(label: Text('Risk')),
                  DataColumn(label: Text('Confidence')),
                ],
                rows: yearly.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row['year'].toString())),
                    DataCell(Text(
                        '${_num(row['estimatedProductionTons']).toStringAsFixed(1)} t')),
                    DataCell(Text(_money(_num(row['expectedTotalCostPkr'])))),
                    DataCell(Text(_money(_num(row['expectedProfitPkr'])))),
                    DataCell(_RiskBadge(level: row['riskLevel'].toString())),
                    DataCell(Text('${row['confidenceScore']}%')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumns extends StatelessWidget {
  final List<_InfoColumnData> columns;

  const _InfoColumns({required this.columns});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 720;
      final widgets = columns
          .map((column) => Expanded(child: _InfoColumn(data: column)))
          .toList();
      if (compact) {
        return Column(
          children: columns
              .map(
                (column) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _InfoColumn(data: column),
                ),
              )
              .toList(),
        );
      }
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
    });
  }
}

class _InfoColumnData {
  final String title;
  final List<String> items;

  const _InfoColumnData(this.title, this.items);
}

class _InfoColumn extends StatelessWidget {
  final _InfoColumnData data;

  const _InfoColumn({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data.title, style: AppTextStyles.label),
        const SizedBox(height: 6),
        ...data.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('- $item', style: AppTextStyles.bodySmall),
          ),
        ),
      ]),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> cards;

  const _KpiGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = width < 680
          ? 1
          : width < 980
              ? 2
              : 4;
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 4.5 : 2.4,
        physics: const NeverScrollableScrollPhysics(),
        children: cards.map((card) => _KpiCard(data: card)).toList(),
      );
    });
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(data.icon, color: data.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 3),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingSmall,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.headingSmall),
        const SizedBox(height: 3),
        Text(subtitle, style: AppTextStyles.bodySmall),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _WarningNotice extends StatelessWidget {
  final String title;
  final String message;
  final String source;

  const _WarningNotice({
    required this.title,
    required this.message,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.30)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.amber),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.amber)),
            const SizedBox(height: 4),
            Text(message, style: AppTextStyles.bodySmall),
            if (source.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(source, style: AppTextStyles.bodySmall),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final bool compact;
  final List<Widget> children;

  const _ResponsiveFields({required this.compact, required this.children});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: child,
              ),
            )
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (child) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: child,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 6),
      DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ]);
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final bool money;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
    this.money = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.label)),
        Text(
          money ? _money(value) : '${value.toStringAsFixed(0)}$suffix',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ]),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: 100,
        onChanged: onChanged,
      ),
    ]);
  }
}

class _RangeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _RangeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Prediction range', style: AppTextStyles.label),
      const SizedBox(height: 8),
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 5, label: Text('5 years')),
          ButtonSegment(value: 10, label: Text('10 years')),
        ],
        selected: {value},
        onSelectionChanged: (selected) => onChanged(selected.first),
      ),
    ]);
  }
}

class _RiskBadge extends StatelessWidget {
  final String level;

  const _RiskBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final risk = level.toLowerCase();
    final color = switch (risk) {
      'high' => AppColors.burntOrange,
      'medium' => AppColors.amber,
      _ => AppColors.deepGreen,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        risk.isEmpty ? 'unknown' : risk,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _EmptyPredictionState extends StatelessWidget {
  const _EmptyPredictionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(children: [
        const Icon(Icons.trending_up_rounded,
            size: 44, color: AppColors.deepGreen),
        const SizedBox(height: 10),
        Text('No future prediction yet', style: AppTextStyles.headingSmall),
        const SizedBox(height: 5),
        Text(
          'Select crops and farm conditions, then generate a 5- or 10-year forecast.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _LoadingReport extends StatelessWidget {
  const _LoadingReport();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      title: 'Building prediction',
      subtitle:
          'Combining historical yield, weather, market, and risk assumptions.',
      child: LinearProgressIndicator(),
    );
  }
}

class _ErrorReport extends StatelessWidget {
  final String message;

  const _ErrorReport({required this.message});

  @override
  Widget build(BuildContext context) {
    return _WarningNotice(
      title: 'Prediction failed',
      message: message,
      source: 'Check that the FastAPI backend is running and try again.',
    );
  }
}

List<Map<String, dynamic>> _rows(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
  return const [];
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<String> _list(dynamic value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  return const [];
}

double _num(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

String _title(String value) {
  return value.replaceAll('-', ' ').split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

String _money(num value) {
  final abs = value.abs();
  if (abs >= 1000000) return 'PKR ${(value / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return 'PKR ${(value / 1000).toStringAsFixed(0)}K';
  return 'PKR ${value.toStringAsFixed(0)}';
}

String _axis(double value, {bool money = false, bool percent = false}) {
  if (percent) return '${(value * 100).toStringAsFixed(0)}%';
  if (money) return _money(value);
  return value.toStringAsFixed(1);
}

double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;
