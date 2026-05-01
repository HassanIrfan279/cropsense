import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/stats_utils.dart';
import 'package:cropsense/data/models/yield_data.dart';
import 'package:cropsense/providers/yield_provider.dart';

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, interpretation, unit;
  final double value;
  final Color color;
  final int delay;
  final int decimals;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.interpretation = '',
    this.unit = '',
    this.delay = 0,
    this.decimals = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('chip-$label-${value.toStringAsFixed(3)}'),
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOut,
      builder: (_, v, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.28)),
          boxShadow: AppShadows.card,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            '${v.toStringAsFixed(decimals)}$unit',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.label),
          if (interpretation.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(interpretation,
                style: AppTextStyles.bodySmall
                    .copyWith(fontSize: 9.5, color: AppColors.grey600),
                textAlign: TextAlign.center),
          ],
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.12, end: 0);
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<List<String>>? csvData;

  const _ChartCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.csvData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headingSmall),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.grey600)),
                  ]),
            ),
            if (csvData != null)
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 18),
                color: AppColors.grey400,
                tooltip: 'Copy CSV',
                onPressed: () {
                  final csv = csvData!.map((r) => r.join(',')).join('\n');
                  Clipboard.setData(ClipboardData(text: csv));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('CSV copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ));
                },
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
          child: child,
        ),
      ]),
    );
  }
}

class _BoxPlotPainter extends CustomPainter {
  final BoxPlotStats stats;
  final Color color;
  final double minY, maxY;

  const _BoxPlotPainter(
      {required this.stats,
      required this.color,
      required this.minY,
      required this.maxY});

  double _py(double v, double h) {
    final range = maxY - minY;
    if (range == 0) return h / 2;
    return h - ((v - minY) / range) * h * 0.9 - h * 0.05;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2, bw = w * 0.32;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final med = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final q1y = _py(stats.q1, h);
    final q3y = _py(stats.q3, h);
    final medy = _py(stats.median, h);
    final miny = _py(stats.min, h);
    final maxy = _py(stats.max, h);

    canvas.drawRect(Rect.fromLTRB(cx - bw, q3y, cx + bw, q1y), fill);
    canvas.drawRect(Rect.fromLTRB(cx - bw, q3y, cx + bw, q1y), line);
    canvas.drawLine(Offset(cx - bw, medy), Offset(cx + bw, medy), med);
    canvas.drawLine(Offset(cx, q3y), Offset(cx, maxy), line);
    canvas.drawLine(Offset(cx, q1y), Offset(cx, miny), line);
    final capW = bw * 0.45;
    canvas.drawLine(Offset(cx - capW, maxy), Offset(cx + capW, maxy), line);
    canvas.drawLine(Offset(cx - capW, miny), Offset(cx + capW, miny), line);

    for (final o in stats.outliers) {
      canvas.drawCircle(
          Offset(cx, _py(o, h)),
          3.5,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_BoxPlotPainter o) =>
      o.stats != stats || o.minY != minY || o.maxY != maxY;
}

class _NormDistPainter extends CustomPainter {
  final double mu, sigma, droughtLine;

  const _NormDistPainter(
      {required this.mu, required this.sigma, this.droughtLine = 1.2});

  static const double _xMin = 0.0, _xMax = 6.0;

  double _px(double x, double w) => (x - _xMin) / (_xMax - _xMin) * w;
  double _py(double pdf, double maxPdf, double h) =>
      h - (maxPdf == 0 ? 0 : pdf / maxPdf * h * 0.82) - h * 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    if (sigma <= 0) return;
    final w = size.width, h = size.height;
    final maxPdf = StatsUtils.normalPDF(mu, mu, sigma);

    void fillBand(double x1, double x2, Color c) {
      final path = Path();
      const steps = 150;
      final dx = (x2 - x1) / steps;
      path.moveTo(_px(x1, w), h);
      for (int i = 0; i <= steps; i++) {
        final x = x1 + i * dx;
        path.lineTo(_px(x, w),
            _py(StatsUtils.normalPDF(x, mu, sigma), maxPdf, h));
      }
      path.lineTo(_px(x2, w), h);
      path.close();
      canvas.drawPath(path, Paint()..color = c..style = PaintingStyle.fill);
    }

    fillBand(mu - 2 * sigma, mu + 2 * sigma, const Color(0xFFDCEDC8));
    fillBand(
        mu - sigma,
        mu + sigma,
        AppColors.limeGreen.withValues(alpha: 0.45));

    final curvePath = Path();
    const steps = 280;
    for (int i = 0; i <= steps; i++) {
      final x = _xMin + (_xMax - _xMin) * i / steps;
      final px = _px(x, w);
      final py = _py(StatsUtils.normalPDF(x, mu, sigma), maxPdf, h);
      i == 0 ? curvePath.moveTo(px, py) : curvePath.lineTo(px, py);
    }
    canvas.drawPath(
        curvePath,
        Paint()
          ..color = AppColors.deepGreen
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke);

    if (droughtLine >= _xMin && droughtLine <= _xMax) {
      canvas.drawLine(
          Offset(_px(droughtLine, w), 0),
          Offset(_px(droughtLine, w), h),
          Paint()
            ..color = AppColors.burntOrange
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }

    // Mean dashed line
    final mx = _px(mu, w);
    final dp = Paint()
      ..color = AppColors.deepGreen.withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    for (double y = 0; y < h; y += 10) {
      canvas.drawLine(Offset(mx, y), Offset(mx, math.min(y + 5, h)), dp);
    }
  }

  @override
  bool shouldRepaint(_NormDistPainter o) =>
      o.mu != mu || o.sigma != sigma || o.droughtLine != droughtLine;
}

// ─── Main screen ──────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  String _district = 'faisalabad';
  String _crop = 'wheat';
  String _district2 = '';
  RangeValues _yearRange = const RangeValues(2005, 2023);
  late final TabController _tabCtrl;

  // Probability tab sliders
  double _droughtNdvi = 0.50;
  double _droughtRain = 250;
  double _excThreshold = 2.0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<YieldData> _filter(List<YieldData> data) => (data
        .where((d) =>
            d.year >= _yearRange.start.round() &&
            d.year <= _yearRange.end.round())
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year)));

  String _districtLabel(String id) =>
      AppDistricts.all.firstWhere((d) => d['id'] == id,
          orElse: () => {'label': id})['label']!;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 1200;
    final yieldAsync = ref.watch(cropYieldProvider((_district, _crop)));
    final d2 = _district2.isEmpty ? _district : _district2;
    final yield2Async = ref.watch(cropYieldProvider((d2, _crop)));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _buildToolbar(isWide),
        Container(
          color: AppColors.cardSurface,
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: w < 700,
            labelColor: AppColors.deepGreen,
            unselectedLabelColor: AppColors.grey600,
            indicatorColor: AppColors.deepGreen,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.label
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Probability'),
              Tab(text: 'Hypothesis'),
              Tab(text: 'Comparison'),
              Tab(text: 'Regression'),
            ],
          ),
        ),
        Expanded(
          child: yieldAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.deepGreen)),
            error: (e, _) =>
                Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
            data: (resp) {
              final data = _filter(resp.data);
              final data2 = _district2.isNotEmpty
                  ? yield2Async.value?.let((r) => _filter(r.data))
                  : null;
              if (data.isEmpty) {
                return const Center(child: Text('No data in selected range'));
              }
              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _OverviewTab(data: data, isWide: isWide),
                  _ProbabilityTab(
                    data: data,
                    isWide: isWide,
                    droughtNdvi: _droughtNdvi,
                    droughtRain: _droughtRain,
                    excThreshold: _excThreshold,
                    onDroughtNdvi: (v) => setState(() => _droughtNdvi = v),
                    onDroughtRain: (v) => setState(() => _droughtRain = v),
                    onExcThreshold: (v) => setState(() => _excThreshold = v),
                  ),
                  _HypothesisTab(
                    data: data,
                    data2: data2,
                    district1: _districtLabel(_district),
                    district2: _district2.isEmpty ? '' : _districtLabel(_district2),
                  ),
                  _ComparisonTab(
                    data1: data,
                    data2: data2,
                    district1: _districtLabel(_district),
                    district2: _district2,
                    crop: _crop,
                    isWide: isWide,
                    onDistrict2Change: (v) => setState(() => _district2 = v),
                  ),
                  _RegressionTab(data: data, isWide: isWide),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildToolbar(bool isWide) {
    final districts = AppDistricts.all;
    final crops = AppCrops.all;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _dropdown(
            value: _district,
            items: districts
                .map((d) => DropdownMenuItem(value: d['id'], child: Text(d['label']!)))
                .toList(),
            onChanged: (v) => setState(() => _district = v!),
            icon: Icons.location_on_rounded,
          ),
          _dropdown(
            value: _crop,
            items: crops
                .map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!)))
                .toList(),
            onChanged: (v) => setState(() => _crop = v!),
            icon: Icons.grass_rounded,
          ),
          if (isWide) ...[
            const SizedBox(width: 8),
            const Text('Year range:', style: TextStyle(fontSize: 12, color: AppColors.grey600)),
            SizedBox(
              width: 280,
              child: RangeSlider(
                values: _yearRange,
                min: 2005,
                max: 2023,
                divisions: 18,
                labels: RangeLabels(
                    '${_yearRange.start.round()}', '${_yearRange.end.round()}'),
                activeColor: AppColors.deepGreen,
                inactiveColor: AppColors.grey200,
                onChanged: (v) => setState(() => _yearRange = v),
              ),
            ),
            Text(
              '${_yearRange.start.round()} – ${_yearRange.end.round()}',
              style: AppTextStyles.label,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.deepGreen),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText),
            isDense: true,
          ),
        ),
      ]),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

// ─── Tab 1: Overview ──────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final List<YieldData> data;
  final bool isWide;
  const _OverviewTab({required this.data, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final yields = data.map((d) => d.yieldTAcre).toList();
    final ndvis = data.map((d) => d.ndvi).toList();
    final years = data.map((d) => d.year.toDouble()).toList();

    final mn = StatsUtils.mean(yields);
    final med = StatsUtils.median(yields);
    final sd = StatsUtils.standardDeviation(yields);
    final cv = StatsUtils.coefficientOfVariation(yields);
    final iq = StatsUtils.iqr(yields);
    final sk = StatsUtils.skewness(yields);
    final ku = StatsUtils.kurtosis(yields);
    final reg = StatsUtils.linearRegression(years, yields);

    String cvInterp = cv < 15 ? 'Low variability' : cv < 30 ? 'Moderate' : 'High variability';
    String skInterp = sk.abs() < 0.5 ? 'Approx. normal' : sk > 0 ? 'Right-skewed' : 'Left-skewed';
    String kuInterp = ku.abs() < 1 ? 'Mesokurtic' : ku > 0 ? 'Leptokurtic' : 'Platykurtic';

    final chips = [
      _StatChip(label: 'Mean', value: mn, color: AppColors.deepGreen, unit: ' t/a', delay: 0),
      _StatChip(label: 'Median', value: med, color: AppColors.skyBlue, unit: ' t/a', delay: 60),
      _StatChip(label: 'Std Dev', value: sd, color: AppColors.amber, unit: ' t/a', delay: 120),
      _StatChip(label: 'CV %', value: cv, color: AppColors.burntOrange,
          interpretation: cvInterp, unit: '%', delay: 180),
      _StatChip(label: 'IQR', value: iq, color: AppColors.limeGreen, unit: ' t/a', delay: 240),
      _StatChip(label: 'Skewness', value: sk, color: AppColors.grey800,
          interpretation: skInterp, delay: 300),
      _StatChip(label: 'Kurtosis', value: ku, color: AppColors.grey600,
          interpretation: kuInterp, delay: 360),
    ];

    final bestD = data.reduce((a, b) => a.yieldTAcre > b.yieldTAcre ? a : b);
    final worstD = data.reduce((a, b) => a.yieldTAcre < b.yieldTAcre ? a : b);

    final ndviSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.value.year.toDouble(), e.value.ndvi))
        .toList();
    final yieldCsvRows = [
      ['Year', 'Yield (t/a)', 'NDVI', 'Rainfall (mm)'],
      ...data.map((d) => [
            d.year.toString(),
            d.yieldTAcre.toStringAsFixed(2),
            d.ndvi.toStringAsFixed(3),
            d.rainfallMm.toStringAsFixed(0),
          ]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stat chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: chips
                  .map((c) => Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        child: c,
                      ))
                  .toList()),
        ),
        const SizedBox(height: 16),

        // Charts grid
        if (isWide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _ndviChart(ndviSpots, ndvis, years, yieldCsvRows)),
            const SizedBox(width: 14),
            Expanded(child: _yieldBarChart(data, yieldCsvRows)),
          ])
        else ...[
          _ndviChart(ndviSpots, ndvis, years, yieldCsvRows),
          const SizedBox(height: 14),
          _yieldBarChart(data, yieldCsvRows),
        ],
        const SizedBox(height: 16),

        // Insights panel
        _insightsPanel(bestD, worstD, reg, mn).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
      ]),
    );
  }

  Widget _ndviChart(List<FlSpot> spots, List<double> ndvis, List<double> years,
      List<List<String>> csv) {
    return _ChartCard(
      title: 'NDVI Timeline',
      subtitle: 'Vegetation health index (0–1)',
      csvData: csv,
      child: SizedBox(
        height: 200,
        child: LineChart(LineChartData(
          minY: 0.3,
          maxY: 0.9,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: AppColors.limeGreen,
              barWidth: 2.2,
              isCurved: true,
              curveSmoothness: 0.25,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.limeGreen.withValues(alpha: 0.35),
                    AppColors.limeGreen.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.deepGreen,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        'NDVI: ${s.y.toStringAsFixed(3)}',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ))
                  .toList(),
            ),
          ),
          gridData: const FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 0.1),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.grey600)))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 4,
                    getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.grey600)))),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )),
      ),
    );
  }

  Widget _yieldBarChart(List<YieldData> data, List<List<String>> csv) {
    final barGroups = data
        .asMap()
        .entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.yieldTAcre,
                  width: math.max(4, 300 / data.length - 3),
                  gradient: const LinearGradient(
                    colors: [AppColors.limeGreen, AppColors.deepGreen],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ))
        .toList();

    return _ChartCard(
      title: 'Annual Yield',
      subtitle: 'tonnes per acre',
      csvData: csv,
      child: SizedBox(
        height: 200,
        child: BarChart(BarChartData(
          barGroups: barGroups,
          gridData: const FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 0.5),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.deepGreen,
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                '${data[group.x].year}\n${rod.toY.toStringAsFixed(2)} t/a',
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.grey600)))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, meta) {
                      final idx = v.round();
                      if (idx < 0 || idx >= data.length) return const SizedBox();
                      final yr = data[idx].year;
                      if (yr % 4 != 1) return const SizedBox();
                      return Text('$yr',
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.grey600));
                    })),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )),
      ),
    );
  }

  Widget _insightsPanel(
      YieldData best, YieldData worst, RegressionResult reg, double mn) {
    final trendUp = reg.slope > 0;
    final trendColor = trendUp ? AppColors.limeGreen : AppColors.burntOrange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Data Insights', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _insightTile(Icons.star_rounded, AppColors.amber,
              'Best Year', '${best.year}  •  ${best.yieldTAcre.toStringAsFixed(2)} t/a')),
          const SizedBox(width: 12),
          Expanded(child: _insightTile(Icons.warning_amber_rounded, AppColors.burntOrange,
              'Worst Year', '${worst.year}  •  ${worst.yieldTAcre.toStringAsFixed(2)} t/a')),
          const SizedBox(width: 12),
          Expanded(child: _insightTile(
            trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            trendColor,
            'Trend',
            '${trendUp ? '+' : ''}${(reg.slope * 10).toStringAsFixed(2)} t/a per decade',
          )),
          const SizedBox(width: 12),
          Expanded(child: _insightTile(Icons.analytics_rounded, AppColors.skyBlue,
              'R² (Year→Yield)', reg.rSquared.toStringAsFixed(3))),
        ]),
      ]),
    );
  }

  Widget _insightTile(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkText, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── Tab 2: Probability ───────────────────────────────────────────────────────

class _ProbabilityTab extends StatelessWidget {
  final List<YieldData> data;
  final bool isWide;
  final double droughtNdvi, droughtRain, excThreshold;
  final ValueChanged<double> onDroughtNdvi, onDroughtRain, onExcThreshold;

  const _ProbabilityTab({
    required this.data,
    required this.isWide,
    required this.droughtNdvi,
    required this.droughtRain,
    required this.excThreshold,
    required this.onDroughtNdvi,
    required this.onDroughtRain,
    required this.onExcThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final yields = data.map((d) => d.yieldTAcre).toList();
    final mu = StatsUtils.mean(yields);
    final sigma = StatsUtils.standardDeviation(yields);

    final pAbove2 = StatsUtils.yieldExceedanceProbability(2.0, yields);
    final pBelow12 = 1 - StatsUtils.yieldExceedanceProbability(1.2, yields);
    final pRange = StatsUtils.yieldExceedanceProbability(1.5, yields) -
        StatsUtils.yieldExceedanceProbability(3.0, yields);

    final droughtProb =
        StatsUtils.droughtProbability(droughtNdvi, droughtRain, yields) * 100;
    final droughtColor = droughtProb < 30
        ? AppColors.limeGreen
        : droughtProb < 60
            ? AppColors.amber
            : AppColors.burntOrange;

    final ci90 = StatsUtils.confidenceInterval(yields, 0.90);
    final ci95 = StatsUtils.confidenceInterval(yields, 0.95);
    final ci99 = StatsUtils.confidenceInterval(yields, 0.99);

    // Exceedance curve
    final sortedY = List<double>.from(yields)..sort();
    final excSpots = sortedY
        .asMap()
        .entries
        .map((e) => FlSpot(e.value,
            1.0 - (e.key + 1) / sortedY.length))
        .toList();

    final excCsv = [
      ['Yield (t/a)', 'P(exceed)'],
      ...excSpots.map((s) => [s.x.toStringAsFixed(2), s.y.toStringAsFixed(3)]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Normal distribution
        _ChartCard(
          title: 'Yield Probability Distribution',
          subtitle: 'Fitted normal — green zones: ±1σ (dark), ±2σ (light)',
          child: Column(children: [
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _NormDistPainter(mu: mu, sigma: sigma),
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _probBadge('P(yield > 2.0)', pAbove2, AppColors.deepGreen),
              _probBadge('P(yield < 1.2)', pBelow12, AppColors.burntOrange),
              _probBadge('P(1.5 < y < 3.0)', pRange.clamp(0.0, 1.0), AppColors.skyBlue),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        if (isWide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _exceedanceChart(excSpots, excCsv)),
            const SizedBox(width: 14),
            Expanded(child: _droughtCalc(droughtProb, droughtColor, context)),
          ])
        else ...[
          _exceedanceChart(excSpots, excCsv),
          const SizedBox(height: 14),
          _droughtCalc(droughtProb, droughtColor, context),
        ],
        const SizedBox(height: 14),
        _confidenceIntervalCard(ci90, ci95, ci99, mu),
      ]),
    );
  }

  Widget _probBadge(String label, double p, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Text('${(p * 100).toStringAsFixed(1)}%',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 9.5, color: AppColors.grey600)),
      ]),
    );
  }

  Widget _exceedanceChart(List<FlSpot> spots, List<List<String>> csv) {
    final minX = spots.isEmpty ? 0.0 : spots.first.x;
    final maxX = spots.isEmpty ? 5.0 : spots.last.x;
    return _ChartCard(
      title: 'Exceedance Probability',
      subtitle: 'P(yield > x) — drag threshold below',
      csvData: csv,
      child: Column(children: [
        SizedBox(
          height: 160,
          child: LineChart(LineChartData(
            minX: minX,
            maxX: maxX,
            minY: 0,
            maxY: 1,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: AppColors.skyBlue,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                isCurved: false,
              ),
              // Threshold vertical indicator
              LineChartBarData(
                spots: [FlSpot(excThreshold, 0), FlSpot(excThreshold, 1)],
                color: AppColors.burntOrange.withValues(alpha: 0.7),
                barWidth: 1.5,
                dotData: const FlDotData(show: false),
                dashArray: [4, 4],
              ),
            ],
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.deepGreen,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          '${(s.y * 100).toStringAsFixed(1)}%',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        ))
                    .toList(),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                          '${(v * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.grey600)))),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.grey600)))),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          )),
        ),
        Row(children: [
          const Icon(Icons.linear_scale_rounded, size: 14, color: AppColors.grey400),
          const SizedBox(width: 6),
          Text('Threshold: ${excThreshold.toStringAsFixed(1)} t/a',
              style: AppTextStyles.label),
          const Spacer(),
          Text(
            'P(exceed) = ${(StatsUtils.yieldExceedanceProbability(excThreshold, spots.map((s) => s.x).toList()) * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.skyBlue, fontWeight: FontWeight.w700),
          ),
        ]),
        Slider(
          value: excThreshold,
          min: 0.5,
          max: 4.5,
          divisions: 40,
          activeColor: AppColors.burntOrange,
          inactiveColor: AppColors.grey200,
          onChanged: onExcThreshold,
        ),
      ]),
    );
  }

  Widget _droughtCalc(double droughtProb, Color droughtColor, BuildContext ctx) {
    return _ChartCard(
      title: 'Drought Risk Calculator',
      subtitle: 'Bayesian P(drought | NDVI, rainfall)',
      child: Column(children: [
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          key: ValueKey(droughtProb.toStringAsFixed(1)),
          tween: Tween(begin: 0.0, end: droughtProb / 100),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => SizedBox(
            width: 90, height: 90,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: v,
                strokeWidth: 9,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(droughtColor),
                strokeCap: StrokeCap.round,
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${droughtProb.toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: droughtColor)),
                Text('drought',
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.grey600)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        _sliderRow('NDVI', droughtNdvi, 0.0, 1.0, 20, onDroughtNdvi,
            droughtNdvi.toStringAsFixed(2), AppColors.limeGreen),
        _sliderRow('Rainfall', droughtRain, 0, 500, 50, onDroughtRain,
            '${droughtRain.toStringAsFixed(0)} mm', AppColors.skyBlue),
      ]),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max,
      int div, ValueChanged<double> onChanged, String display, Color color) {
    return Row(children: [
      SizedBox(
          width: 64,
          child: Text(label,
              style: AppTextStyles.label.copyWith(color: AppColors.grey600))),
      Expanded(
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: AppColors.grey200,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
              value: value, min: min, max: max, divisions: div, onChanged: onChanged),
        ),
      ),
      SizedBox(
          width: 58,
          child: Text(display,
              style: AppTextStyles.bodySmall.copyWith(
                  color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right)),
    ]);
  }

  Widget _confidenceIntervalCard(ConfidenceInterval ci90, ConfidenceInterval ci95,
      ConfidenceInterval ci99, double mu) {
    final overallRange = ci99.upper - ci99.lower;
    return _ChartCard(
      title: 'Confidence Intervals',
      subtitle: 'Mean yield estimates',
      child: Column(children: [
        const SizedBox(height: 8),
        _ciRow('90% CI', ci90, overallRange, AppColors.limeGreen),
        const SizedBox(height: 10),
        _ciRow('95% CI', ci95, overallRange, AppColors.amber),
        const SizedBox(height: 10),
        _ciRow('99% CI', ci99, overallRange, AppColors.burntOrange),
        const SizedBox(height: 12),
        Text(
          '95% CI: we are 95% confident the true mean lies in [${ci95.lower.toStringAsFixed(2)}, ${ci95.upper.toStringAsFixed(2)}] t/a',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
      ]),
    );
  }

  Widget _ciRow(String label, ConfidenceInterval ci, double range, Color color) {
    final barMax = range == 0 ? 1.0 : range;
    final barWidth = (ci.upper - ci.lower) / barMax;
    final barOffset = range == 0 ? 0.0 : (ci.lower - (ci.mean - range / 2)) / barMax;

    return Row(children: [
      SizedBox(
          width: 52,
          child: Text(label, style: AppTextStyles.label.copyWith(color: AppColors.grey800))),
      Expanded(
        child: Container(
          height: 18,
          decoration: BoxDecoration(
              color: AppColors.grey200, borderRadius: BorderRadius.circular(4)),
          child: LayoutBuilder(builder: (_, constraints) {
            return Stack(children: [
              Positioned(
                left: (barOffset.clamp(0.0, 1.0)) * constraints.maxWidth,
                child: Container(
                  width: (barWidth.clamp(0.0, 1.0)) * constraints.maxWidth,
                  height: 18,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ]);
          }),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '[${ci.lower.toStringAsFixed(2)}, ${ci.upper.toStringAsFixed(2)}]',
        style: AppTextStyles.bodySmall
            .copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 10.5),
      ),
    ]);
  }
}

// ─── Tab 3: Hypothesis Testing ────────────────────────────────────────────────

class _HypothesisTab extends StatelessWidget {
  final List<YieldData> data;
  final List<YieldData>? data2;
  final String district1, district2;

  const _HypothesisTab({
    required this.data,
    this.data2,
    required this.district1,
    this.district2 = '',
  });

  @override
  Widget build(BuildContext context) {
    final yields = data.map((d) => d.yieldTAcre).toList();
    final tt = StatsUtils.tTest(yields, 2.1);

    // Chi-square: high yield vs high rainfall
    final medY = StatsUtils.median(yields);
    final rains = data.map((d) => d.rainfallMm).toList();
    final medR = StatsUtils.median(rains);
    int hh = 0, hl = 0, lh = 0, ll = 0;
    for (final d in data) {
      final hy = d.yieldTAcre >= medY, hr = d.rainfallMm >= medR;
      if (hy && hr) hh++;
      else if (hy && !hr) hl++;
      else if (!hy && hr) lh++;
      else ll++;
    }
    final chi2 = StatsUtils.chiSquare2x2(hh, hl, lh, ll);
    final chiP = StatsUtils.chiSquarePValueDf1(chi2);

    // Mann-Whitney
    double? u, uP;
    if (data2 != null && data2!.isNotEmpty) {
      final y2 = data2!.map((d) => d.yieldTAcre).toList();
      u = StatsUtils.mannWhitneyU(yields, y2);
      final n1 = yields.length, n2 = y2.length;
      final mu = n1 * n2 / 2;
      final sigma = math.sqrt(n1 * n2 * (n1 + n2 + 1) / 12);
      final z = sigma == 0 ? 0.0 : (u - mu) / sigma;
      uP = (2 * (1 - StatsUtils.normalCDF(z.abs(), 0, 1))).clamp(0.0, 1.0);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // T-test card
        _testCard(
          title: 'One-Sample T-Test',
          subtitle: '$district1  vs  Pakistan avg (2.1 t/a)',
          icon: Icons.science_rounded,
          color: AppColors.skyBlue,
          stats: [
            _stat('t-statistic', tt.tStat.toStringAsFixed(3)),
            _stat('p-value', tt.pValue < 0.001 ? '<0.001' : tt.pValue.toStringAsFixed(3)),
            _stat('df', tt.df.toStringAsFixed(0)),
            _stat("Cohen's d", tt.cohensD.toStringAsFixed(3)),
          ],
          interpretation: _tTestInterp(tt),
          significant: tt.pValue < 0.05,
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 14),

        // Chi-square card
        _testCard(
          title: 'Chi-Square Test',
          subtitle: 'High yield × High rainfall correlation',
          icon: Icons.table_chart_rounded,
          color: AppColors.amber,
          stats: [
            _stat('χ² statistic', chi2.toStringAsFixed(3)),
            _stat('p-value', chiP < 0.001 ? '<0.001' : chiP.toStringAsFixed(3)),
            _stat('df', '1'),
            _stat('', ''),
          ],
          interpretation: chiP < 0.05
              ? 'Significant association between high yield and high rainfall (p < 0.05).'
              : 'No significant association detected (p ≥ 0.05).',
          significant: chiP < 0.05,
          extra: _contingencyTable(hh, hl, lh, ll, medY, medR),
        ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 14),

        // Mann-Whitney card
        _testCard(
          title: 'Mann-Whitney U Test',
          subtitle: data2 != null
              ? '$district1  vs  $district2'
              : 'Select a second district in the Comparison tab',
          icon: Icons.compare_arrows_rounded,
          color: AppColors.limeGreen,
          stats: u != null
              ? [
                  _stat('U statistic', u.toStringAsFixed(0)),
                  _stat('p-value',
                      uP! < 0.001 ? '<0.001' : uP.toStringAsFixed(3)),
                  _stat('n₁', data.length.toString()),
                  _stat('n₂', data2!.length.toString()),
                ]
              : [_stat('Status', 'Awaiting district 2 selection'), _stat('', ''), _stat('', ''), _stat('', '')],
          interpretation: u != null
              ? (uP! < 0.05
                  ? 'Significant difference in yield distributions (p < 0.05).'
                  : 'No significant difference in yield distributions (p ≥ 0.05).')
              : 'Select a second district in the Comparison tab to enable this test.',
          significant: uP != null && uP! < 0.05,
        ).animate(delay: 160.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
      ]),
    );
  }

  Map<String, String> _stat(String k, String v) => {'k': k, 'v': v};

  Widget _testCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> stats,
    required String interpretation,
    required bool significant,
    Widget? extra,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(13)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headingSmall),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey600)),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: significant ? AppColors.limeGreen : AppColors.grey400,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(significant ? 'Significant' : 'Not Significant',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: stats
                  .where((s) => s['k']!.isNotEmpty)
                  .map((s) => Expanded(
                        child: Column(children: [
                          Text(s['v']!,
                              style: AppTextStyles.headingSmall
                                  .copyWith(color: color, fontSize: 15)),
                          Text(s['k']!, style: AppTextStyles.label),
                        ]),
                      ))
                  .toList(),
            ),
            if (extra != null) ...[const SizedBox(height: 12), extra],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.grey600),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(interpretation,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey800))),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _contingencyTable(int hh, int hl, int lh, int ll, double medY, double medR) {
    return Table(
      border: TableBorder.all(color: AppColors.grey200, borderRadius: BorderRadius.circular(6)),
      columnWidths: const {0: FlexColumnWidth(1.8), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
      children: [
        _tableRow(['', 'Rain ≥ ${medR.toStringAsFixed(0)}', 'Rain < ${medR.toStringAsFixed(0)}'],
            isHeader: true),
        _tableRow(['Yield ≥ ${medY.toStringAsFixed(2)}', '$hh', '$hl']),
        _tableRow(['Yield < ${medY.toStringAsFixed(2)}', '$lh', '$ll']),
      ],
    );
  }

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? BoxDecoration(color: AppColors.grey200.withValues(alpha: 0.7))
          : null,
      children: cells
          .map((c) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(c,
                    style: isHeader
                        ? AppTextStyles.label
                        : AppTextStyles.bodySmall
                            .copyWith(color: AppColors.darkText),
                    textAlign: TextAlign.center),
              ))
          .toList(),
    );
  }

  String _tTestInterp(TTestResult tt) {
    final dir = tt.tStat > 0 ? 'above' : 'below';
    final sig = tt.pValue < 0.05;
    final eff = tt.cohensD.abs() < 0.2
        ? 'negligible'
        : tt.cohensD.abs() < 0.5
            ? 'small'
            : tt.cohensD.abs() < 0.8
                ? 'medium'
                : 'large';
    if (sig) {
      return '$district1 yield is significantly $dir Pakistan average (p=${tt.pValue.toStringAsFixed(3)}, ${eff} effect size).';
    }
    return 'No significant difference from Pakistan average detected (p=${tt.pValue.toStringAsFixed(3)}).';
  }
}

// ─── Tab 4: Comparison ────────────────────────────────────────────────────────

class _ComparisonTab extends StatelessWidget {
  final List<YieldData> data1;
  final List<YieldData>? data2;
  final String district1, district2, crop;
  final bool isWide;
  final ValueChanged<String> onDistrict2Change;

  const _ComparisonTab({
    required this.data1,
    this.data2,
    required this.district1,
    required this.district2,
    required this.crop,
    required this.isWide,
    required this.onDistrict2Change,
  });

  String _label(String id) =>
      AppDistricts.all.firstWhere((d) => d['id'] == id,
          orElse: () => {'label': id})['label']!;

  @override
  Widget build(BuildContext context) {
    final allDistricts = AppDistricts.all;
    final hasD2 = data2 != null && data2!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // District 2 selector
        Row(children: [
          Text('Compare with:', style: AppTextStyles.headingSmall),
          const SizedBox(width: 12),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: AppColors.skyBlue),
              const SizedBox(width: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: district2.isEmpty ? null : district2,
                  hint: const Text('Select district',
                      style: TextStyle(fontSize: 12, color: AppColors.grey600)),
                  items: allDistricts
                      .map((d) => DropdownMenuItem(
                            value: d['id'],
                            child: Text(d['label']!,
                                style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (v) => v != null ? onDistrict2Change(v) : null,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.darkText),
                  isDense: true,
                ),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 16),

        if (!hasD2)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.grey200.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('Select a second district to compare',
                    style: TextStyle(color: AppColors.grey600))),
          )
        else
          _buildComparison(context, data1, data2!),
      ]),
    );
  }

  Widget _buildComparison(
      BuildContext ctx, List<YieldData> d1, List<YieldData> d2) {
    final y1 = d1.map((d) => d.yieldTAcre).toList();
    final y2 = d2.map((d) => d.yieldTAcre).toList();
    final mn1 = StatsUtils.mean(y1), mn2 = StatsUtils.mean(y2);
    final winner = mn1 >= mn2 ? district1 : _label(district2);
    final winnerColor = mn1 >= mn2 ? AppColors.deepGreen : AppColors.skyBlue;

    // Align years
    final years1 = {for (var d in d1) d.year: d};
    final years2 = {for (var d in d2) d.year: d};
    final commonYears = years1.keys.toSet().intersection(years2.keys.toSet()).toList()..sort();
    final spots1 = commonYears
        .map((y) => FlSpot(y.toDouble(), years1[y]!.yieldTAcre))
        .toList();
    final spots2 = commonYears
        .map((y) => FlSpot(y.toDouble(), years2[y]!.yieldTAcre))
        .toList();

    final corr = StatsUtils.pearsonCorrelation(
      commonYears.map((y) => years1[y]!.yieldTAcre).toList(),
      commonYears.map((y) => years2[y]!.yieldTAcre).toList(),
    );

    final bp1 = StatsUtils.boxPlot(y1), bp2 = StatsUtils.boxPlot(y2);
    final allYields = [...y1, ...y2];
    final minY = allYields.reduce(math.min) - 0.2;
    final maxY = allYields.reduce(math.max) + 0.2;

    final csvRows = [
      ['Year', district1, _label(district2)],
      ...commonYears.map((y) => [
            y.toString(),
            years1[y]!.yieldTAcre.toStringAsFixed(2),
            years2[y]!.yieldTAcre.toStringAsFixed(2),
          ]),
    ];

    return Column(children: [
      // Winner badge
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [winnerColor.withValues(alpha: 0.12), winnerColor.withValues(alpha: 0.04)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: winnerColor.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(Icons.emoji_events_rounded, color: winnerColor, size: 24),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Better performing district',
                style: AppTextStyles.label.copyWith(color: winnerColor)),
            Text(winner,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: winnerColor)),
          ]),
          const Spacer(),
          Text(
            'r = ${corr.toStringAsFixed(3)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ]),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
      const SizedBox(height: 14),

      // Yield trend comparison
      _ChartCard(
        title: 'Yield Trend Comparison',
        subtitle: '${district1} vs ${_label(district2)}',
        csvData: csvRows,
        child: SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots1,
                color: AppColors.deepGreen,
                barWidth: 2.2,
                isCurved: true,
                curveSmoothness: 0.25,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [AppColors.deepGreen.withValues(alpha: 0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              LineChartBarData(
                spots: spots2,
                color: AppColors.skyBlue,
                barWidth: 2.2,
                isCurved: true,
                curveSmoothness: 0.25,
                dotData: const FlDotData(show: false),
                dashArray: [6, 3],
              ),
            ],
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1B2B1E),
                getTooltipItems: (spots) {
                  return spots.map((s) {
                    final label = s.barIndex == 0 ? district1 : _label(district2);
                    return LineTooltipItem(
                      '$label\n${s.y.toStringAsFixed(2)} t/a',
                      TextStyle(
                          color: s.barIndex == 0 ? AppColors.limeGreen : AppColors.skyBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, interval: 4,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          )),
        ),
      ).animate(delay: 80.ms).fadeIn(duration: 350.ms),
      const SizedBox(height: 14),

      // Box plots
      if (isWide)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _boxPlotCard(bp1, district1, minY, maxY, AppColors.deepGreen)),
          const SizedBox(width: 14),
          Expanded(child: _boxPlotCard(bp2, _label(district2), minY, maxY, AppColors.skyBlue)),
        ])
      else ...[
        _boxPlotCard(bp1, district1, minY, maxY, AppColors.deepGreen),
        const SizedBox(height: 14),
        _boxPlotCard(bp2, _label(district2), minY, maxY, AppColors.skyBlue),
      ],
      const SizedBox(height: 14),

      // Radar chart
      _radarCard(d1, d2).animate(delay: 200.ms).fadeIn(duration: 350.ms),
      const SizedBox(height: 14),

      // Stats table
      _statsTable(d1, d2, district1, _label(district2))
          .animate(delay: 260.ms)
          .fadeIn(duration: 350.ms),
    ]);
  }

  Widget _boxPlotCard(BoxPlotStats bp, String label, double minY, double maxY, Color color) {
    return _ChartCard(
      title: 'Box Plot: $label',
      subtitle: 'Yield distribution (t/a)',
      child: Column(children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _BoxPlotPainter(stats: bp, color: color, minY: minY, maxY: maxY),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _bpStat('Min', bp.min, color),
          _bpStat('Q1', bp.q1, color),
          _bpStat('Median', bp.median, color),
          _bpStat('Q3', bp.q3, color),
          _bpStat('Max', bp.max, color),
        ]),
      ]),
    ).animate(delay: 140.ms).fadeIn(duration: 350.ms);
  }

  Widget _bpStat(String label, double v, Color color) {
    return Column(children: [
      Text(v.toStringAsFixed(2),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: AppTextStyles.label.copyWith(fontSize: 9)),
    ]);
  }

  Widget _radarCard(List<YieldData> d1, List<YieldData> d2) {
    final y1 = d1.map((d) => d.yieldTAcre).toList();
    final y2 = d2.map((d) => d.yieldTAcre).toList();
    final n1 = d1.map((d) => d.ndvi).toList();
    final n2 = d2.map((d) => d.ndvi).toList();

    double norm(double v, double lo, double hi) =>
        hi == lo ? 2.5 : ((v - lo) / (hi - lo) * 4 + 0.5).clamp(0.5, 5.0);

    final mn1 = StatsUtils.mean(y1), mn2 = StatsUtils.mean(y2);
    final cv1 = StatsUtils.coefficientOfVariation(y1);
    final cv2 = StatsUtils.coefficientOfVariation(y2);
    final nd1 = StatsUtils.mean(n1), nd2 = StatsUtils.mean(n2);
    final re1 = d1.map((d) => d.yieldTAcre / (d.rainfallMm + 1) * 1000).toList();
    final re2 = d2.map((d) => d.yieldTAcre / (d.rainfallMm + 1) * 1000).toList();
    final gt1 = StatsUtils.linearRegression(
        d1.map((d) => d.year.toDouble()).toList(), y1).slope;
    final gt2 = StatsUtils.linearRegression(
        d2.map((d) => d.year.toDouble()).toList(), y2).slope;

    final vals1 = [mn1, 100 / (cv1 + 1), nd1 * 5, StatsUtils.mean(re1), gt1 + 2.5];
    final vals2 = [mn2, 100 / (cv2 + 1), nd2 * 5, StatsUtils.mean(re2), gt2 + 2.5];
    final lo = List.generate(5, (i) => math.min(vals1[i], vals2[i]));
    final hi = List.generate(5, (i) => math.max(vals1[i], vals2[i]));
    final r1 = List.generate(5, (i) => norm(vals1[i], lo[i], hi[i]));
    final r2 = List.generate(5, (i) => norm(vals2[i], lo[i], hi[i]));

    const axes = ['Mean Yield', 'Stability', 'NDVI Avg', 'Rain Eff.', 'Growth'];

    return _ChartCard(
      title: 'Radar Comparison',
      subtitle: 'Normalized performance across 5 axes',
      child: SizedBox(
        height: 260,
        child: RadarChart(RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.deepGreen.withValues(alpha: 0.18),
              borderColor: AppColors.deepGreen,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: r1.map((v) => RadarEntry(value: v)).toList(),
            ),
            RadarDataSet(
              fillColor: AppColors.skyBlue.withValues(alpha: 0.18),
              borderColor: AppColors.skyBlue,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: r2.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
          getTitle: (i, _) => RadarChartTitle(text: axes[i], angle: 0),
          titleTextStyle: const TextStyle(
              fontSize: 10, color: AppColors.darkText, fontWeight: FontWeight.w600),
          ticksTextStyle:
              const TextStyle(color: Colors.transparent, fontSize: 8),
          tickCount: 4,
          tickBorderData: const BorderSide(color: AppColors.grey200, width: 1),
          gridBorderData: const BorderSide(color: AppColors.grey200, width: 1),
          radarBorderData: const BorderSide(color: AppColors.grey400, width: 1),
        )),
      ),
    );
  }

  Widget _statsTable(List<YieldData> d1, List<YieldData> d2, String l1, String l2) {
    final y1 = d1.map((d) => d.yieldTAcre).toList();
    final y2 = d2.map((d) => d.yieldTAcre).toList();

    final rows = [
      ['Mean', StatsUtils.mean(y1), StatsUtils.mean(y2)],
      ['Median', StatsUtils.median(y1), StatsUtils.median(y2)],
      ['Std Dev', StatsUtils.standardDeviation(y1), StatsUtils.standardDeviation(y2)],
      ['CV %', StatsUtils.coefficientOfVariation(y1), StatsUtils.coefficientOfVariation(y2)],
      ['IQR', StatsUtils.iqr(y1), StatsUtils.iqr(y2)],
      ['Skewness', StatsUtils.skewness(y1), StatsUtils.skewness(y2)],
      ['P(y>2.0)',
        StatsUtils.yieldExceedanceProbability(2.0, y1) * 100,
        StatsUtils.yieldExceedanceProbability(2.0, y2) * 100],
    ];

    return _ChartCard(
      title: 'Statistics Comparison',
      subtitle: '$l1 vs $l2',
      child: Table(
        border: TableBorder.all(color: AppColors.grey200),
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration:
                const BoxDecoration(color: Color(0xFFF5F5F5)),
            children: [
              _tc('Metric', isHeader: true),
              _tc(l1, isHeader: true, color: AppColors.deepGreen),
              _tc(l2, isHeader: true, color: AppColors.skyBlue),
              _tc('Δ %', isHeader: true),
            ],
          ),
          ...rows.map((r) {
            final v1 = r[1] as double, v2 = r[2] as double;
            final diff = v1 == 0 ? 0.0 : ((v2 - v1) / v1.abs() * 100);
            final diffColor = diff > 0 ? AppColors.limeGreen : AppColors.burntOrange;
            return TableRow(children: [
              _tc(r[0] as String),
              _tc(v1.toStringAsFixed(2)),
              _tc(v2.toStringAsFixed(2)),
              _tc('${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}%', color: diffColor),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _tc(String text,
      {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        style: isHeader
            ? AppTextStyles.label.copyWith(color: color ?? AppColors.grey800)
            : AppTextStyles.bodySmall.copyWith(
                color: color ?? AppColors.darkText,
                fontWeight:
                    color != null ? FontWeight.w700 : FontWeight.w400),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Tab 5: Regression ────────────────────────────────────────────────────────

class _RegressionTab extends StatelessWidget {
  final List<YieldData> data;
  final bool isWide;

  const _RegressionTab({required this.data, required this.isWide});

  Color _eraColor(int year) {
    if (year <= 2010) return AppColors.skyBlue;
    if (year <= 2017) return AppColors.limeGreen;
    return AppColors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final yields = data.map((d) => d.yieldTAcre).toList();
    final ndvis = data.map((d) => d.ndvi).toList();
    final rains = data.map((d) => d.rainfallMm).toList();
    final temps = data.map((d) => d.tempMaxC).toList();
    final years = data.map((d) => d.year.toDouble()).toList();

    final reg = StatsUtils.linearRegression(ndvis, yields);
    final regRain = StatsUtils.linearRegression(rains, yields);
    final regTemp = StatsUtils.linearRegression(temps, yields);

    // Main scatter spots
    final scatterSpots = data
        .map((d) => ScatterSpot(
              d.ndvi,
              d.yieldTAcre,
              dotPainter: FlDotCirclePainter(
                radius: 5,
                color: _eraColor(d.year),
              ),
            ))
        .toList();

    // Regression line
    final ndviMin = ndvis.reduce(math.min);
    final ndviMax = ndvis.reduce(math.max);
    final regSpots = [
      FlSpot(ndviMin, reg.slope * ndviMin + reg.intercept),
      FlSpot(ndviMax, reg.slope * ndviMax + reg.intercept),
    ];

    // 95% Prediction interval
    final n = data.length.toDouble();
    final xMean = StatsUtils.mean(ndvis);
    final sxx = ndvis.fold(0.0, (sum, x) => sum + (x - xMean) * (x - xMean));
    final mse = reg.rSquared < 1 && n > 2
        ? yields.asMap().entries.fold(
                0.0,
                (s, e) =>
                    s +
                    math.pow(
                        e.value - (reg.slope * ndvis[e.key] + reg.intercept),
                        2)) /
            (n - 2)
        : 0.0;
    final seY = math.sqrt(mse);

    final piUpper = [
      FlSpot(ndviMin, reg.slope * ndviMin + reg.intercept + 2 * seY),
      FlSpot(ndviMax, reg.slope * ndviMax + reg.intercept + 2 * seY),
    ];
    final piLower = [
      FlSpot(ndviMin, reg.slope * ndviMin + reg.intercept - 2 * seY),
      FlSpot(ndviMax, reg.slope * ndviMax + reg.intercept - 2 * seY),
    ];

    // Residuals
    final residuals = data
        .asMap()
        .entries
        .map((e) =>
            e.value.yieldTAcre -
            (reg.slope * e.value.ndvi + reg.intercept))
        .toList();

    // DW statistic
    double dw = 2.0;
    if (residuals.length > 1) {
      double num = 0, den = 0;
      for (int i = 1; i < residuals.length; i++) {
        num += math.pow(residuals[i] - residuals[i - 1], 2);
      }
      for (final r in residuals) den += r * r;
      dw = den == 0 ? 2.0 : num / den;
    }

    // Q-Q plot
    final sortedRes = List<double>.from(residuals)..sort();
    final resMu = StatsUtils.mean(residuals);
    final resSd = StatsUtils.standardDeviation(residuals);
    final qqSpots = List.generate(sortedRes.length, (i) {
      final p = (i + 0.5) / sortedRes.length;
      final theoretical = StatsUtils.inverseCDF(p);
      final actual = resSd == 0 ? 0.0 : (sortedRes[i] - resMu) / resSd;
      return ScatterSpot(theoretical, actual,
          dotPainter: FlDotCirclePainter(radius: 4, color: AppColors.skyBlue));
    });

    // Standardized betas (via Pearson r with z-scored vars)
    final beta1 = StatsUtils.pearsonCorrelation(ndvis, yields);
    final beta2 = StatsUtils.pearsonCorrelation(rains, yields);
    final beta3 = StatsUtils.pearsonCorrelation(temps, yields);

    // Decomposition
    final window = math.min(5, yields.length ~/ 2);
    final trend = _movingAvg(yields, window);
    final trendResidual =
        List.generate(yields.length, (i) => yields[i] - trend[i]);

    final scatterCsv = [
      ['NDVI', 'Yield (t/a)', 'Year'],
      ...data.map((d) => [
            d.ndvi.toStringAsFixed(3),
            d.yieldTAcre.toStringAsFixed(2),
            d.year.toString(),
          ]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Main scatter + regression
        _ChartCard(
          title: 'NDVI vs Yield — Regression',
          subtitle:
              'y = ${reg.slope.toStringAsFixed(3)}x + ${reg.intercept.toStringAsFixed(3)}  •  R² = ${reg.rSquared.toStringAsFixed(3)}  •  p = ${reg.pValue < 0.001 ? '<0.001' : reg.pValue.toStringAsFixed(3)}',
          csvData: scatterCsv,
          child: Column(children: [
            SizedBox(
              height: 240,
              child: Stack(children: [
                LineChart(LineChartData(
                  lineBarsData: [
                    // Regression line
                    LineChartBarData(
                      spots: regSpots,
                      color: AppColors.deepGreen,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    // PI upper
                    LineChartBarData(
                      spots: piUpper,
                      color: AppColors.deepGreen.withValues(alpha: 0.35),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 4],
                    ),
                    // PI lower
                    LineChartBarData(
                      spots: piLower,
                      color: AppColors.deepGreen.withValues(alpha: 0.35),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 4],
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                        getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: const LineTouchData(enabled: false),
                )),
                // Scatter overlay
                Positioned.fill(
                  child: ScatterChart(ScatterChartData(
                    scatterSpots: scatterSpots,
                    minX: ndviMin - 0.02,
                    maxX: ndviMax + 0.02,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    scatterTouchData: ScatterTouchData(
                      touchTooltipData: ScatterTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF1B2B1E),
                        getTooltipItems: (spot) => ScatterTooltipItem(
                          'NDVI: ${spot.x.toStringAsFixed(3)}\nYield: ${spot.y.toStringAsFixed(2)} t/a',
                          textStyle: const TextStyle(color: Colors.white, fontSize: 10),
                          bottomMargin: 4,
                        ),
                      ),
                    ),
                  )),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _eraLegend(AppColors.skyBlue, '2005–2010'),
              const SizedBox(width: 16),
              _eraLegend(AppColors.limeGreen, '2011–2017'),
              const SizedBox(width: 16),
              _eraLegend(AppColors.amber, '2018–2023'),
              const SizedBox(width: 16),
              _eraLegend(AppColors.deepGreen, 'Regression line'),
            ]),
          ]),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 14),

        // Partial regressions
        if (isWide)
          Row(children: [
            Expanded(child: _miniScatter('NDVI → Yield', ndvis, yields, regSpots, AppColors.limeGreen)),
            const SizedBox(width: 10),
            Expanded(child: _miniScatter('Rainfall → Yield', rains, yields,
                _regLine(rains, regRain), AppColors.skyBlue)),
            const SizedBox(width: 10),
            Expanded(child: _miniScatter('Temp → Yield', temps, yields,
                _regLine(temps, regTemp), AppColors.amber)),
          ])
        else
          Column(children: [
            _miniScatter('NDVI → Yield', ndvis, yields, regSpots, AppColors.limeGreen),
            const SizedBox(height: 10),
            _miniScatter('Rainfall → Yield', rains, yields, _regLine(rains, regRain), AppColors.skyBlue),
            const SizedBox(height: 10),
            _miniScatter('Temp → Yield', temps, yields, _regLine(temps, regTemp), AppColors.amber),
          ]),
        const SizedBox(height: 14),

        // Standardized coefficients
        _ChartCard(
          title: 'Standardized Coefficients (β)',
          subtitle: 'Relative importance of predictors (Pearson r)',
          child: SizedBox(
            height: 140,
            child: BarChart(BarChartData(
              barGroups: [
                _hBar(0, beta1, 'NDVI', AppColors.limeGreen),
                _hBar(1, beta2, 'Rainfall', AppColors.skyBlue),
                _hBar(2, beta3, 'Temp', AppColors.amber),
              ],
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.deepGreen,
                  getTooltipItem: (g, gi, rod, ri) {
                    final labels = ['NDVI', 'Rainfall', 'Temp'];
                    return BarTooltipItem(
                      '${labels[g.x]}: ${rod.toY.toStringAsFixed(3)}',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                    getTitlesWidget: (v, meta) {
                      const labels = ['NDVI', 'Rain', 'Temp'];
                      final i = v.round();
                      if (i < 0 || i >= labels.length) return const SizedBox();
                      return Text(labels[i],
                          style: const TextStyle(fontSize: 9, color: AppColors.grey600));
                    })),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            )),
          ),
        ).animate(delay: 120.ms).fadeIn(duration: 350.ms),
        const SizedBox(height: 14),

        // Residuals + Q-Q
        if (isWide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _residualsChart(data, residuals, dw)),
            const SizedBox(width: 14),
            Expanded(child: _qqChart(qqSpots)),
          ])
        else ...[
          _residualsChart(data, residuals, dw),
          const SizedBox(height: 14),
          _qqChart(qqSpots),
        ],
        const SizedBox(height: 14),

        // Decomposition
        _decompositionCard(data, yields, trend, trendResidual, years)
            .animate(delay: 200.ms)
            .fadeIn(duration: 350.ms),
      ]),
    );
  }

  Widget _eraLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.grey600)),
    ]);
  }

  List<FlSpot> _regLine(List<double> x, RegressionResult r) {
    final xMin = x.reduce(math.min), xMax = x.reduce(math.max);
    return [
      FlSpot(xMin, r.slope * xMin + r.intercept),
      FlSpot(xMax, r.slope * xMax + r.intercept),
    ];
  }

  BarChartGroupData _hBar(int x, double y, String label, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        width: 36,
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    ]);
  }

  Widget _miniScatter(
      String title, List<double> xData, List<double> yData, List<FlSpot> line, Color color) {
    final spots = List.generate(
        xData.length,
        (i) => ScatterSpot(xData[i], yData[i],
            dotPainter: FlDotCirclePainter(radius: 3.5, color: color.withValues(alpha: 0.7))));
    final r = StatsUtils.linearRegression(xData, yData);
    return _ChartCard(
      title: title,
      subtitle: 'r = ${StatsUtils.pearsonCorrelation(xData, yData).toStringAsFixed(3)}',
      child: SizedBox(
        height: 130,
        child: Stack(children: [
          LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: line,
                color: color,
                barWidth: 1.5,
                dotData: const FlDotData(show: false),
              ),
            ],
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 8, color: AppColors.grey600)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 18,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 8, color: AppColors.grey600)))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: const LineTouchData(enabled: false),
          )),
          Positioned.fill(
            child: ScatterChart(ScatterChartData(
              scatterSpots: spots,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              scatterTouchData: ScatterTouchData(enabled: false),
            )),
          ),
        ]),
      ),
    );
  }

  Widget _residualsChart(List<YieldData> data, List<double> residuals, double dw) {
    final maxAbs =
        residuals.map((r) => r.abs()).fold(0.0, math.max) + 0.1;
    final resSpotsColor = residuals.asMap().entries.map((e) {
      final absR = e.value.abs();
      final color = absR < 0.2
          ? AppColors.limeGreen
          : absR < 0.4
              ? AppColors.amber
              : AppColors.burntOrange;
      return ScatterSpot(data[e.key].year.toDouble(), e.value,
          dotPainter: FlDotCirclePainter(radius: 4, color: color));
    }).toList();

    final resCsv = [
      ['Year', 'Residual'],
      ...data
          .asMap()
          .entries
          .map((e) => [e.value.year.toString(), residuals[e.key].toStringAsFixed(4)]),
    ];

    return _ChartCard(
      title: 'Residuals',
      subtitle: 'Durbin-Watson: ${dw.toStringAsFixed(3)}',
      csvData: resCsv,
      child: SizedBox(
        height: 200,
        child: ScatterChart(ScatterChartData(
          scatterSpots: resSpotsColor,
          minY: -maxAbs,
          maxY: maxAbs,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: v == 0 ? AppColors.deepGreen.withValues(alpha: 0.5) : AppColors.grey200,
                    strokeWidth: v == 0 ? 1.5 : 0.5),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                interval: 4,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1B2B1E),
              getTooltipItems: (spot) => ScatterTooltipItem(
                'Year ${spot.x.toStringAsFixed(0)}\nResidual: ${spot.y.toStringAsFixed(3)}',
                textStyle: const TextStyle(color: Colors.white, fontSize: 10),
                bottomMargin: 4,
              ),
            ),
          ),
        )),
      ),
    ).animate(delay: 160.ms).fadeIn(duration: 350.ms);
  }

  Widget _qqChart(List<ScatterSpot> spots) {
    final diag = spots.isEmpty
        ? <FlSpot>[]
        : [
            FlSpot(spots.first.x, spots.first.x),
            FlSpot(spots.last.x, spots.last.x),
          ];
    return _ChartCard(
      title: 'Q-Q Plot',
      subtitle: 'Theoretical vs actual residual quantiles',
      child: SizedBox(
        height: 200,
        child: Stack(children: [
          LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: diag,
                color: AppColors.grey400,
                barWidth: 1,
                dotData: const FlDotData(show: false),
                dashArray: [4, 4],
              ),
            ],
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 9, color: AppColors.grey600)))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: const LineTouchData(enabled: false),
          )),
          Positioned.fill(
            child: ScatterChart(ScatterChartData(
              scatterSpots: spots,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              scatterTouchData: ScatterTouchData(enabled: false),
            )),
          ),
        ]),
      ),
    ).animate(delay: 180.ms).fadeIn(duration: 350.ms);
  }

  Widget _decompositionCard(List<YieldData> data, List<double> yields,
      List<double> trend, List<double> residual, List<double> years) {
    final trendSpots =
        List.generate(data.length, (i) => FlSpot(years[i], trend[i]));
    final resSpots = List.generate(
        data.length, (i) => FlSpot(years[i], residual[i]));
    final origSpots =
        List.generate(data.length, (i) => FlSpot(years[i], yields[i]));

    final decCsv = [
      ['Year', 'Original', 'Trend', 'Residual'],
      ...List.generate(data.length, (i) => [
            years[i].toStringAsFixed(0),
            yields[i].toStringAsFixed(2),
            trend[i].toStringAsFixed(2),
            residual[i].toStringAsFixed(3),
          ]),
    ];

    return _ChartCard(
      title: 'Time Series Decomposition',
      subtitle: 'Original + trend (moving avg) + residual',
      csvData: decCsv,
      child: Column(children: [
        _decompLine('Original', origSpots, AppColors.grey600, 200),
        const SizedBox(height: 10),
        _decompLine('Trend', trendSpots, AppColors.deepGreen, 160),
        const SizedBox(height: 10),
        _decompLine('Residual', resSpots, AppColors.burntOrange, 140),
      ]),
    );
  }

  Widget _decompLine(
      String label, List<FlSpot> spots, Color color, double height) {
    if (spots.isEmpty) return const SizedBox();
    final yVals = spots.map((s) => s.y).toList();
    final minY = yVals.reduce(math.min) - 0.1;
    final maxY = yVals.reduce(math.max) + 0.1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ),
      SizedBox(
        height: height,
        child: LineChart(LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: color,
              barWidth: 1.8,
              isCurved: true,
              curveSmoothness: 0.2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.deepGreen,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        s.y.toStringAsFixed(3),
                        const TextStyle(color: Colors.white, fontSize: 11),
                      ))
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 8, color: AppColors.grey600)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 4,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 8, color: AppColors.grey600)))),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )),
      ),
    ]);
  }

  List<double> _movingAvg(List<double> data, int window) {
    return List.generate(data.length, (i) {
      final start = math.max(0, i - window ~/ 2);
      final end = math.min(data.length - 1, i + window ~/ 2);
      return StatsUtils.mean(data.sublist(start, end + 1));
    });
  }
}
