import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _district = 'faisalabad';
  String _crop = 'all';
  String _season = 'all';
  String _soilType = 'loam';
  double _farmAcres = 5.0;
  RangeValues _yearRange = const RangeValues(2005, 2023);
  int _selectedSection = 0;

  AnalyticsFilters get _filters => AnalyticsFilters(
        district: _district,
        crop: _crop,
        season: _season,
        startYear: _yearRange.start.round(),
        endYear: _yearRange.end.round(),
        soilType: _soilType,
        farmAcres: _farmAcres,
      );

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider(_filters));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _Header(
            district: _district,
            crop: _crop,
            season: _season,
            soilType: _soilType,
            farmAcres: _farmAcres,
            yearRange: _yearRange,
            onDistrictChanged: (value) => setState(() => _district = value),
            onCropChanged: (value) => setState(() => _crop = value),
            onSeasonChanged: (value) => setState(() => _season = value),
            onSoilChanged: (value) => setState(() => _soilType = value),
            onFarmAcresChanged: (value) => setState(() => _farmAcres = value),
            onYearRangeChanged: (value) => setState(() => _yearRange = value),
          ),
          Expanded(
            child: analytics.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.deepGreen),
              ),
              error: (error, _) => _ErrorState(message: error.toString()),
              data: (data) => _AnalyticsBody(
                data: data,
                selectedSection: _selectedSection,
                onSectionChanged: (index) =>
                    setState(() => _selectedSection = index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String district;
  final String crop;
  final String season;
  final String soilType;
  final double farmAcres;
  final RangeValues yearRange;
  final ValueChanged<String> onDistrictChanged;
  final ValueChanged<String> onCropChanged;
  final ValueChanged<String> onSeasonChanged;
  final ValueChanged<String> onSoilChanged;
  final ValueChanged<double> onFarmAcresChanged;
  final ValueChanged<RangeValues> onYearRangeChanged;

  const _Header({
    required this.district,
    required this.crop,
    required this.season,
    required this.soilType,
    required this.farmAcres,
    required this.yearRange,
    required this.onDistrictChanged,
    required this.onCropChanged,
    required this.onSeasonChanged,
    required this.onSoilChanged,
    required this.onFarmAcresChanged,
    required this.onYearRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 900;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 24,
              14,
              compact ? 16 : 24,
              6,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.deepGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analytics', style: AppTextStyles.headingMedium),
                      Text(
                        'Split-view crop intelligence with statistical testing',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 24,
              8,
              compact ? 16 : 24,
              12,
            ),
            child: Row(
              children: [
                _FilterDropdown(
                  label: 'Location',
                  value: district,
                  width: 190,
                  icon: Icons.location_on_rounded,
                  items: AppDistricts.all
                      .map((d) => DropdownMenuItem(
                            value: d['id'],
                            child: Text(d['label']!),
                          ))
                      .toList(),
                  onChanged: onDistrictChanged,
                ),
                _FilterDropdown(
                  label: 'Crop',
                  value: crop,
                  width: 155,
                  icon: Icons.agriculture_rounded,
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All crops'),
                    ),
                    ...AppCrops.all.map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text(c['label']!),
                      ),
                    ),
                  ],
                  onChanged: onCropChanged,
                ),
                _FilterDropdown(
                  label: 'Season',
                  value: season,
                  width: 135,
                  icon: Icons.calendar_month_rounded,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'Rabi', child: Text('Rabi')),
                    DropdownMenuItem(value: 'Kharif', child: Text('Kharif')),
                    DropdownMenuItem(value: 'Annual', child: Text('Annual')),
                  ],
                  onChanged: onSeasonChanged,
                ),
                _FilterDropdown(
                  label: 'Soil',
                  value: soilType,
                  width: 135,
                  icon: Icons.terrain_rounded,
                  items: const [
                    DropdownMenuItem(value: 'loam', child: Text('Loam')),
                    DropdownMenuItem(value: 'clay', child: Text('Clay')),
                    DropdownMenuItem(value: 'sandy', child: Text('Sandy')),
                    DropdownMenuItem(value: 'saline', child: Text('Saline')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                  ],
                  onChanged: onSoilChanged,
                ),
                _RangeFilter(
                  value: yearRange,
                  onChanged: onYearRangeChanged,
                ),
                _FarmAreaFilter(
                  value: farmAcres,
                  onChanged: onFarmAcresChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final int selectedSection;
  final ValueChanged<int> onSectionChanged;

  const _AnalyticsBody({
    required this.data,
    required this.selectedSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _map(data['summary']);
    final demo = data['isDemoData'] == true;

    return Column(
      children: [
        _TopSummaryPanel(summary: summary),
        if (demo)
          _NoticeBanner(
            icon: Icons.info_rounded,
            color: AppColors.amber,
            text: _str(
              data['dataSource'],
              'Some analytics use transparent demo assumptions where field-level records are missing.',
            ),
          ),
        Expanded(
          child: _AnalyticsWorkspace(
            data: data,
            selectedSection: selectedSection,
            onSectionChanged: onSectionChanged,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsWorkspace extends StatelessWidget {
  final Map<String, dynamic> data;
  final int selectedSection;
  final ValueChanged<int> onSectionChanged;

  const _AnalyticsWorkspace({
    required this.data,
    required this.selectedSection,
    required this.onSectionChanged,
  });

  static const menu = [
    _AnalyticsMenuItem('Summary', Icons.summarize_rounded),
    _AnalyticsMenuItem('Trend', Icons.trending_up_rounded),
    _AnalyticsMenuItem('Profit', Icons.payments_rounded),
    _AnalyticsMenuItem('Weather', Icons.cloud_rounded),
    _AnalyticsMenuItem('Risk', Icons.warning_rounded),
    _AnalyticsMenuItem('Testing', Icons.science_rounded),
    _AnalyticsMenuItem('AI Insights', Icons.psychology_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        final page = _selectedPage();

        if (compact) {
          return Column(
            children: [
              _HorizontalAnalyticsMenu(
                items: menu,
                selectedIndex: selectedSection,
                onSelected: onSectionChanged,
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.offWhite),
                  child: page,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 220,
              child: _VerticalAnalyticsMenu(
                items: menu,
                selectedIndex: selectedSection,
                onSelected: onSectionChanged,
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.grey200),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.offWhite),
                child: page,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selectedPage() {
    switch (selectedSection) {
      case 0:
        return _SummaryPage(data: data);
      case 1:
        return _TrendPage(data: data);
      case 2:
        return _ProfitPage(data: data);
      case 3:
        return _WeatherPage(data: data);
      case 4:
        return _RiskPage(data: data);
      case 5:
        return _TestingPage(data: data);
      case 6:
        return _AiInsightsPage(data: data);
      default:
        return _SummaryPage(data: data);
    }
  }
}

class _AnalyticsMenuItem {
  final String label;
  final IconData icon;
  const _AnalyticsMenuItem(this.label, this.icon);
}

class _VerticalAnalyticsMenu extends StatelessWidget {
  final List<_AnalyticsMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _VerticalAnalyticsMenu({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardSurface,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Text(
              'Analytics Menu',
              style: AppTextStyles.label.copyWith(letterSpacing: 0),
            ),
          ),
          ...List.generate(
            items.length,
            (index) => _MenuButton(
              item: items[index],
              selected: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalAnalyticsMenu extends StatelessWidget {
  final List<_AnalyticsMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _HorizontalAnalyticsMenu({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return ChoiceChip(
            selected: selected,
            avatar: Icon(
              items[index].icon,
              size: 17,
              color: selected ? Colors.white : AppColors.deepGreen,
            ),
            label: Text(items[index].label),
            selectedColor: AppColors.deepGreen,
            backgroundColor: AppColors.grey100,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.darkText,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: BorderSide(
              color: selected ? AppColors.deepGreen : AppColors.grey200,
            ),
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final _AnalyticsMenuItem item;
  final bool selected;
  final VoidCallback onTap;

  const _MenuButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? AppColors.deepGreen.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: selected
                    ? AppColors.deepGreen.withValues(alpha: 0.28)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: selected ? AppColors.deepGreen : AppColors.grey600,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? AppColors.deepGreen : AppColors.grey800,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.deepGreen,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopSummaryPanel extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _TopSummaryPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        label: 'Best crop',
        value: _cropLabel(_str(summary['bestPerformingCrop'], '-')),
        icon: Icons.emoji_events_rounded,
        color: AppColors.limeGreen,
      ),
      _SummaryItem(
        label: 'Most profitable',
        value: _cropLabel(_str(summary['mostProfitableCrop'], '-')),
        icon: Icons.payments_rounded,
        color: AppColors.deepGreen,
      ),
      _SummaryItem(
        label: 'Highest risk',
        value: _cropLabel(_str(summary['highestRiskCrop'], '-')),
        icon: Icons.warning_rounded,
        color: AppColors.burntOrange,
      ),
      _SummaryItem(
        label: 'Avg yield',
        value: '${_num(summary['averageYield']).toStringAsFixed(2)} t/ac',
        icon: Icons.grass_rounded,
        color: AppColors.skyBlue,
      ),
      _SummaryItem(
        label: 'Expected profit',
        value: formatPKR(_num(summary['expectedProfitPerAcre']), compact: true),
        icon: Icons.trending_up_rounded,
        color: AppColors.deepGreen,
      ),
      _SummaryItem(
        label: 'Loss chance',
        value: _pct(_num(summary['probabilityOfLoss'])),
        icon: Icons.price_change_rounded,
        color: AppColors.amber,
      ),
      _SummaryItem(
        label: 'Weather risk',
        value: _titleCase(_str(summary['mainWeatherRisk'], 'normal')),
        icon: Icons.cloud_rounded,
        color: AppColors.skyBlue,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _MetricTile(item: item),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.psychology_rounded,
                size: 18,
                color: AppColors.deepGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _str(
                    summary['aiRecommendation'],
                    'No recommendation available.',
                  ),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SummaryPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = _map(data['summary']);
    final cropRows = _rows(_map(data['cropPerformance'])['rows']);

    return _PageScaffold(
      title: 'Summary',
      subtitle: 'A quick decision view for crop performance and risk.',
      children: [
        _KpiWrap(summary: summary),
        _TwoColumn(
          left: _Panel(
            title: 'Crop comparison',
            subtitle: 'Average yield by crop',
            child: Column(
              children: [
                _CropBarChart(
                  rows: cropRows,
                  valueKeyName: 'meanYield',
                  valueSuffix: ' t/ac',
                ),
                const _GraphNote(
                  text:
                      'Higher bars mean better average yield in the selected district and year range.',
                ),
              ],
            ),
          ),
          right: _Panel(
            title: 'Crop yield share',
            subtitle: 'Share of total average yield',
            child: Column(
              children: [
                _DonutChart(
                  slices: _slicesFromRows(
                    cropRows,
                    valueKey: 'meanYield',
                    labelKey: 'crop',
                  ),
                  centerLabel: 'Yield share',
                ),
                const _GraphNote(
                  text:
                      'This donut shows which crops contribute most to the combined average yield.',
                ),
              ],
            ),
          ),
        ),
        _Panel(
          title: 'Crop comparison table',
          subtitle: 'Yield, profit, risk, and loss probability in one table',
          child: _CropPerformanceTable(rows: cropRows),
        ),
      ],
    );
  }
}

class _TrendPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TrendPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final trend = _map(data['yieldTrend']);
    final rows = _rows(trend['yearly']);
    final stats = _map(trend['descriptiveStats']);
    final regression = _map(trend['regression']);
    final multi = _map(trend['multiFactorRegression']);
    final interval = _map(trend['confidenceInterval']);
    final crops = _map(data['crops']);

    return _PageScaffold(
      title: 'Yield Trend Analysis',
      subtitle: 'Historical yield movement from 2005 to 2023 where selected.',
      children: [
        _StatsGrid(stats: stats),
        _Panel(
          title: 'Yield trend line',
          subtitle: 'Yearly yield for the selected crop',
          child: Column(
            children: [
              _LineSeriesChart(
                rows: rows,
                yKey: 'yieldTAcre',
                yLabel: 'Yield t/acre',
                color: AppColors.deepGreen,
              ),
              const _GraphNote(
                text:
                    'A rising line means productivity is improving. Dips often match drought, flood, or heat years.',
              ),
            ],
          ),
        ),
        _Panel(
          title: 'Year-over-year growth',
          subtitle: 'How much yield changed compared with the previous year',
          child: Column(
            children: [
              _GrowthBarChart(rows: rows),
              const _GraphNote(
                text:
                    'Positive bars show growth from last year. Negative bars warn that yield fell.',
              ),
            ],
          ),
        ),
        _Panel(
          title: 'Crop-wise trend comparison',
          subtitle: 'Trend lines for all crops returned by the API',
          child: Column(
            children: [
              _MultiCropTrendChart(crops: crops),
              const _GraphNote(
                text:
                    'Use this to compare whether one crop is improving faster than another.',
              ),
            ],
          ),
        ),
        _TwoColumn(
          left: _RegressionPanel(regression: regression),
          right: _RegressionPanel(
            regression: multi,
            title: 'Multi-factor model',
          ),
        ),
        _ConfidencePanel(
          title: 'Expected yield confidence interval',
          interval: interval,
          unit: 't/acre',
        ),
      ],
    );
  }
}

class _ProfitPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ProfitPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final costProfit = _map(data['costProfit']);
    final cropRows = _rows(costProfit['cropRows']);
    final yearly = _rows(costProfit['yearly']);
    final interval = _map(costProfit['confidenceInterval']);

    return _PageScaffold(
      title: 'Cost and Profit Analysis',
      subtitle: 'Profit is revenue minus estimated farming cost per acre.',
      children: [
        _Panel(
          title: 'Cost vs profit',
          subtitle: 'Yearly cost and profit for the selected crop',
          child: Column(
            children: [
              _CostProfitChart(rows: yearly),
              const _GraphNote(
                text:
                    'If profit bars fall below zero, the crop did not cover its estimated cost that year.',
              ),
            ],
          ),
        ),
        _TwoColumn(
          left: _Panel(
            title: 'Profit share',
            subtitle: 'Which crop contributes the most profit',
            child: Column(
              children: [
                _DonutChart(
                  slices: _slicesFromRows(
                    cropRows,
                    valueKey: 'expectedProfitPerAcre',
                    labelKey: 'crop',
                    positiveOnly: true,
                  ),
                  centerLabel: 'Profit',
                ),
                const _GraphNote(
                  text:
                      'Only positive expected profits are counted in this share.',
                ),
              ],
            ),
          ),
          right: _Panel(
            title: 'Cost breakdown',
            subtitle: 'Latest available cost components',
            child: Column(
              children: [
                _DonutChart(
                  slices: _costBreakdownSlices(yearly),
                  centerLabel: 'Cost',
                ),
                const _GraphNote(
                  text:
                      'This breaks estimated cost into fertilizer, irrigation, and other field costs.',
                ),
              ],
            ),
          ),
        ),
        _Panel(
          title: 'Profit comparison table',
          subtitle: 'Expected profit, ROI, loss probability, and risk',
          child: _ProfitTable(rows: cropRows),
        ),
        _ConfidencePanel(
          title: 'Expected profit confidence interval',
          interval: interval,
          unit: 'PKR per acre',
          isMoney: true,
        ),
      ],
    );
  }
}

class _WeatherPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _WeatherPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final section = _map(data['weatherImpact']);
    final rows = _rows(section['yearly']);
    final correlations = _map(section['correlations']);

    return _PageScaffold(
      title: 'Weather Impact Analysis',
      subtitle: 'Rainfall and temperature relationships with yield.',
      children: [
        _WeatherRiskCards(rows: rows),
        _TwoColumn(
          left: _Panel(
            title: 'Rainfall vs yield',
            subtitle: 'Each dot is one year',
            child: Column(
              children: [
                _ScatterMetricChart(
                  rows: rows,
                  xKey: 'rainfallMm',
                  yKey: 'yieldTAcre',
                  xLabel: 'Rainfall mm',
                  yLabel: 'Yield t/acre',
                  color: AppColors.skyBlue,
                ),
                const _GraphNote(
                  text:
                      'A clear pattern means rainfall is strongly linked with yield in this district.',
                ),
              ],
            ),
          ),
          right: _Panel(
            title: 'Temperature vs yield',
            subtitle: 'High heat can reduce crop performance',
            child: Column(
              children: [
                _ScatterMetricChart(
                  rows: rows,
                  xKey: 'tempMaxC',
                  yKey: 'yieldTAcre',
                  xLabel: 'Max temp C',
                  yLabel: 'Yield t/acre',
                  color: AppColors.burntOrange,
                ),
                const _GraphNote(
                  text:
                      'If yield falls as temperature rises, heat stress management should be a priority.',
                ),
              ],
            ),
          ),
        ),
        _TwoColumn(
          left: _CorrelationPanel(
            title: 'Rainfall correlation',
            correlation: _map(correlations['rainfallYield']),
          ),
          right: _CorrelationPanel(
            title: 'Temperature correlation',
            correlation: _map(correlations['temperatureYield']),
          ),
        ),
      ],
    );
  }
}

class _RiskPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RiskPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final section = _map(data['riskProbability']);
    final probabilities = _map(section['probabilities']);
    final thresholds = _map(section['thresholds']);
    final cropRows = _rows(_map(data['cropPerformance'])['rows']);

    return _PageScaffold(
      title: 'Risk and Probability Analysis',
      subtitle: 'Empirical risk probabilities from selected historical years.',
      children: [
        _RiskProbabilityCards(probabilities: probabilities),
        _TwoColumn(
          left: _Panel(
            title: 'Risk probability chart',
            subtitle: 'Low yield, crop failure, weather, price, and loss risks',
            child: Column(
              children: [
                _ProbabilityChart(probabilities: probabilities),
                const _GraphNote(
                  text:
                      'These probabilities are historical frequencies, not guaranteed future outcomes.',
                ),
              ],
            ),
          ),
          right: _Panel(
            title: 'Risk distribution',
            subtitle: 'Risk levels across available crops',
            child: Column(
              children: [
                _DonutChart(
                  slices: _riskDistributionSlices(cropRows),
                  centerLabel: 'Risk',
                ),
                const _GraphNote(
                  text:
                      'This shows how many crops fall into low, medium, or high risk categories.',
                ),
              ],
            ),
          ),
        ),
        _Panel(
          title: 'Risk thresholds',
          subtitle: 'Rules used by the probability model',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SmallFact(
                label: 'Overall level',
                value: _titleCase(_str(section['riskLevel'], 'unknown')),
                color: _riskColor(_str(section['riskLevel'], 'medium')),
              ),
              _SmallFact(
                label: 'Risk score',
                value: '${_num(section['riskScore']).toStringAsFixed(1)}/100',
                color: AppColors.amber,
              ),
              _SmallFact(
                label: 'Low yield below',
                value:
                    '${_num(thresholds['lowYieldTAcre']).toStringAsFixed(2)} t/ac',
                color: AppColors.burntOrange,
              ),
              _SmallFact(
                label: 'Failure yield below',
                value:
                    '${_num(thresholds['failureYieldTAcre']).toStringAsFixed(2)} t/ac',
                color: AppColors.riskCritical,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestingPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TestingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final tests = _map(data['statisticalTesting']);
    final selected = _map(data['selectedCrop']);
    final correlations = _map(selected['correlations']);
    final yieldCi = _map(_map(data['yieldTrend'])['confidenceInterval']);
    final profitCi = _map(_map(data['costProfit'])['confidenceInterval']);
    final regression = _map(_map(data['yieldTrend'])['regression']);
    final multi = _map(_map(data['yieldTrend'])['multiFactorRegression']);

    return _PageScaffold(
      title: 'Statistical Testing Panel',
      subtitle: 'Academic tests explained in simple English.',
      children: [
        _Panel(
          title: 'Hypothesis tests',
          subtitle: 't-test, ANOVA, and chi-square where data allows',
          child: Column(
            children: [
              _TestResultTile(test: _map(tests['tTestYield'])),
              _TestResultTile(test: _map(tests['tTestProfit'])),
              _TestResultTile(test: _map(tests['anovaYield'])),
              _TestResultTile(test: _map(tests['anovaProfit'])),
              _TestResultTile(test: _map(tests['chiSquareWeatherRisk'])),
              _UnavailableTile(test: _map(tests['seasonTest'])),
            ],
          ),
        ),
        _TwoColumn(
          left: _ConfidencePanel(
            title: 'Yield confidence interval',
            interval: yieldCi,
            unit: 't/acre',
          ),
          right: _ConfidencePanel(
            title: 'Profit confidence interval',
            interval: profitCi,
            unit: 'PKR per acre',
            isMoney: true,
          ),
        ),
        _TwoColumn(
          left: _RegressionPanel(regression: regression),
          right: _RegressionPanel(
            regression: multi,
            title: 'Multi-factor regression',
          ),
        ),
        _TwoColumn(
          left: _CorrelationPanel(
            title: 'Fertilizer cost vs profit',
            correlation: _map(correlations['fertilizerProfit']),
          ),
          right: _CorrelationPanel(
            title: 'Market price vs profit',
            correlation: _map(correlations['marketPriceProfit']),
          ),
        ),
      ],
    );
  }
}

class _AiInsightsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AiInsightsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final insights = _map(data['aiInsights']);
    final quality = _map(data['dataQuality']);
    final bullets = _stringList(insights['bullets']);

    return _PageScaffold(
      title: 'AI Insights',
      subtitle: 'Farmer-friendly recommendations based on analytics.',
      children: [
        _Panel(
          title: 'Plain-language summary',
          subtitle: 'What the numbers mean for the farmer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _str(insights['farmerSummary'], 'No summary available.'),
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 12),
              ...bullets.map((item) => _InsightBullet(text: item)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.deepGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.deepGreen.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  _str(
                    insights['recommendation'],
                    'No recommendation available.',
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        _Panel(
          title: 'Data notes',
          subtitle: 'How to read demo or missing-data messages',
          child: Column(
            children: quality.entries
                .map(
                  (entry) => _DataQualityRow(
                    label: entry.key,
                    value: entry.value.toString(),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _PageScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headingSmall),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: subtitle,
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: AppColors.grey400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.015, end: 0);
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.width,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            items: items,
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ),
      ),
    );
  }
}

class _RangeFilter extends StatelessWidget {
  final RangeValues value;
  final ValueChanged<RangeValues> onChanged;

  const _RangeFilter({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Year ${value.start.round()}-${value.end.round()}',
            style: AppTextStyles.label.copyWith(letterSpacing: 0),
          ),
          RangeSlider(
            values: value,
            min: 2005,
            max: 2023,
            divisions: 18,
            labels: RangeLabels(
              value.start.round().toString(),
              value.end.round().toString(),
            ),
            onChanged: (next) {
              if (next.end - next.start >= 2) onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _FarmAreaFilter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _FarmAreaFilter({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farming area ${value.toStringAsFixed(1)} acres',
            style: AppTextStyles.label.copyWith(letterSpacing: 0),
          ),
          Slider(
            value: value.clamp(0.5, 100.0).toDouble(),
            min: 0.5,
            max: 100,
            divisions: 199,
            label: '${value.toStringAsFixed(1)} acres',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _KpiWrap extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _KpiWrap({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        label: 'Best crop',
        value: _cropLabel(_str(summary['bestPerformingCrop'], '-')),
        icon: Icons.emoji_events_rounded,
        color: AppColors.limeGreen,
      ),
      _SummaryItem(
        label: 'Highest risk',
        value: _cropLabel(_str(summary['highestRiskCrop'], '-')),
        icon: Icons.warning_rounded,
        color: AppColors.burntOrange,
      ),
      _SummaryItem(
        label: 'Average yield',
        value: '${_num(summary['averageYield']).toStringAsFixed(2)} t/ac',
        icon: Icons.grass_rounded,
        color: AppColors.skyBlue,
      ),
      _SummaryItem(
        label: 'Expected profit',
        value: formatPKR(_num(summary['expectedProfitPerAcre']), compact: true),
        icon: Icons.payments_rounded,
        color: AppColors.deepGreen,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _MetricTile(item: item)).toList(),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        label: 'Mean',
        value: _fixed(stats['mean']),
        icon: Icons.functions_rounded,
        color: AppColors.deepGreen,
      ),
      _SummaryItem(
        label: 'Median',
        value: _fixed(stats['median']),
        icon: Icons.align_horizontal_center_rounded,
        color: AppColors.skyBlue,
      ),
      _SummaryItem(
        label: 'Min',
        value: _fixed(stats['min']),
        icon: Icons.south_rounded,
        color: AppColors.burntOrange,
      ),
      _SummaryItem(
        label: 'Max',
        value: _fixed(stats['max']),
        icon: Icons.north_rounded,
        color: AppColors.limeGreen,
      ),
      _SummaryItem(
        label: 'Std dev',
        value: _fixed(stats['stdDev']),
        icon: Icons.show_chart_rounded,
        color: AppColors.amber,
      ),
      _SummaryItem(
        label: 'Variance',
        value: _fixed(stats['variance']),
        icon: Icons.scatter_plot_rounded,
        color: AppColors.skyBlue,
      ),
      _SummaryItem(
        label: 'Range',
        value: _fixed(stats['range']),
        icon: Icons.swap_vert_rounded,
        color: AppColors.grey600,
      ),
      _SummaryItem(
        label: 'Change',
        value: '${_num(stats['percentChange']).toStringAsFixed(1)}%',
        icon: Icons.percent_rounded,
        color: AppColors.deepGreen,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _MetricTile(item: item)).toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _SummaryItem item;

  const _MetricTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: item.color.withValues(alpha: 0.22)),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                  ),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _CropBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final String valueKeyName;
  final String valueSuffix;

  const _CropBarChart({
    required this.rows,
    required this.valueKeyName,
    required this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();
    final maxY = rows.map((r) => _num(r[valueKeyName])).reduce(math.max);

    return SizedBox(
      height: 270,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY * 1.22,
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int i = 0; i < rows.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: _num(rows[i][valueKeyName]),
                    width: 28,
                    color:
                        AppColors.cropColors[i % AppColors.cropColors.length],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
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
                reservedSize: 36,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= rows.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _cropShort(_str(rows[i]['crop'])),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey600,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1B2B1E),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final crop = _cropLabel(_str(rows[group.x.toInt()]['crop']));
                return BarTooltipItem(
                  '$crop\n${rod.toY.toStringAsFixed(2)}$valueSuffix',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LineSeriesChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final String yKey;
  final String yLabel;
  final Color color;

  const _LineSeriesChart({
    required this.rows,
    required this.yKey,
    required this.yLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spots = rows
        .where((row) => row.containsKey('year'))
        .map((row) => FlSpot(_num(row['year']), _num(row[yKey])))
        .where((spot) => spot.x > 0)
        .toList();

    if (spots.isEmpty) return const _EmptyChart();

    final minX = spots.map((s) => s.x).reduce(math.min);
    final maxX = spots.map((s) => s.x).reduce(math.max);
    final ys = spots.map((s) => s.y).toList();
    final minYRaw = ys.reduce(math.min);
    final maxYRaw = ys.reduce(math.max);
    final pad = math.max(
      (maxYRaw - minYRaw).abs() * 0.15,
      0.12,
    );

    return SizedBox(
      height: 285,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minYRaw - pad,
          maxY: maxYRaw + pad,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: color,
              barWidth: 2.8,
              isCurved: true,
              curveSmoothness: 0.18,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1B2B1E),
              getTooltipItems: (items) => items.map((item) {
                final value = item.y.toStringAsFixed(2);
                return LineTooltipItem(
                  'Year ${item.x.toInt()}\n$yLabel: $value',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 54,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
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
                reservedSize: 28,
                interval: 3,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 8),
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
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

class _GrowthBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _GrowthBarChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final validRows = rows.where((r) => r['yoyGrowthPct'] != null).toList();
    if (validRows.isEmpty) return const _EmptyChart();
    final values = validRows.map((r) => _num(r['yoyGrowthPct'])).toList();
    final minY = math.min(0, values.reduce(math.min)) - 6;
    final maxY = math.max(0, values.reduce(math.max)) + 6;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          minY: minY.toDouble(),
          maxY: maxY.toDouble(),
          barGroups: [
            for (int i = 0; i < validRows.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: _num(validRows[i]['yoyGrowthPct']),
                    width: 18,
                    color: _num(validRows[i]['yoyGrowthPct']) >= 0
                        ? AppColors.limeGreen
                        : AppColors.burntOrange,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                ],
              ),
          ],
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, _) => Text(
                  '${value.toStringAsFixed(0)}%',
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
                reservedSize: 28,
                interval: 3,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= validRows.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _num(validRows[i]['year']).toInt().toString(),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.grey600,
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

class _MultiCropTrendChart extends StatelessWidget {
  final Map<String, dynamic> crops;

  const _MultiCropTrendChart({required this.crops});

  @override
  Widget build(BuildContext context) {
    final cropEntries = crops.entries.toList();
    if (cropEntries.isEmpty) return const _EmptyChart();

    final bars = <LineChartBarData>[];
    final allSpots = <FlSpot>[];

    for (int i = 0; i < cropEntries.length; i++) {
      final rows = _rows(_map(cropEntries[i].value)['yearly']);
      final spots = rows
          .map((row) => FlSpot(_num(row['year']), _num(row['yieldTAcre'])))
          .where((spot) => spot.x > 0)
          .toList();
      if (spots.isEmpty) continue;
      allSpots.addAll(spots);
      bars.add(
        LineChartBarData(
          spots: spots,
          color: AppColors.cropColors[i % AppColors.cropColors.length],
          barWidth: 2.2,
          isCurved: true,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    if (bars.isEmpty || allSpots.isEmpty) return const _EmptyChart();
    final minX = allSpots.map((s) => s.x).reduce(math.min);
    final maxX = allSpots.map((s) => s.x).reduce(math.max);
    final minY = allSpots.map((s) => s.y).reduce(math.min) - 0.2;
    final maxY = allSpots.map((s) => s.y).reduce(math.max) + 0.2;

    return Column(
      children: [
        SizedBox(
          height: 285,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: math.max(0, minY),
              maxY: maxY,
              lineBarsData: bars,
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(1),
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
                    reservedSize: 28,
                    interval: 3,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Legend(
          items: [
            for (int i = 0; i < cropEntries.length; i++)
              _LegendItem(
                label: _cropLabel(cropEntries[i].key),
                color: AppColors.cropColors[i % AppColors.cropColors.length],
              ),
          ],
        ),
      ],
    );
  }
}

class _CostProfitChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _CostProfitChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();
    final values = [
      ...rows.map((r) => _num(r['costPerAcre'])),
      ...rows.map((r) => _num(r['profitPerAcre'])),
    ];
    final minY = math.min(0, values.reduce(math.min)) * 1.15;
    final maxY = math.max(1, values.reduce(math.max)) * 1.18;

    return Column(
      children: [
        SizedBox(
          height: 285,
          child: BarChart(
            BarChartData(
              minY: minY.toDouble(),
              maxY: maxY.toDouble(),
              barGroups: [
                for (int i = 0; i < rows.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: _num(rows[i]['costPerAcre']),
                        width: 7,
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: _num(rows[i]['profitPerAcre']),
                        width: 7,
                        color: _num(rows[i]['profitPerAcre']) >= 0
                            ? AppColors.limeGreen
                            : AppColors.burntOrange,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 54,
                    getTitlesWidget: (value, _) => Text(
                      _compactMoney(value),
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
                    reservedSize: 28,
                    interval: 3,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= rows.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _num(rows[i]['year']).toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.grey600,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _Legend(
          items: [
            _LegendItem(label: 'Cost', color: AppColors.amber),
            _LegendItem(label: 'Profit', color: AppColors.limeGreen),
            _LegendItem(label: 'Loss year', color: AppColors.burntOrange),
          ],
        ),
      ],
    );
  }
}

class _ScatterMetricChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final String xKey;
  final String yKey;
  final String xLabel;
  final String yLabel;
  final Color color;

  const _ScatterMetricChart({
    required this.rows,
    required this.xKey,
    required this.yKey,
    required this.xLabel,
    required this.yLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spots = rows
        .map(
          (row) => ScatterSpot(
            _num(row[xKey]),
            _num(row[yKey]),
            dotPainter: FlDotCirclePainter(
              radius: 4.4,
              color:
                  row['weatherStress'] == true ? AppColors.burntOrange : color,
              strokeColor: Colors.white,
              strokeWidth: 1,
            ),
          ),
        )
        .where((spot) => spot.x > 0 && spot.y > 0)
        .toList();

    if (spots.isEmpty) return const _EmptyChart();

    final xs = spots.map((s) => s.x).toList();
    final ys = spots.map((s) => s.y).toList();
    return SizedBox(
      height: 270,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: xs.reduce(math.min) - 5,
          maxX: xs.reduce(math.max) + 5,
          minY: math.max(0, ys.reduce(math.min) - 0.25),
          maxY: ys.reduce(math.max) + 0.25,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
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
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1B2B1E),
              getTooltipItems: (spot) => ScatterTooltipItem(
                '$xLabel ${spot.x.toStringAsFixed(1)}\n'
                '$yLabel ${spot.y.toStringAsFixed(2)}',
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<_Slice> slices;
  final String centerLabel;

  const _DonutChart({
    required this.slices,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final usable = slices.where((slice) => slice.value > 0).toList();
    if (usable.isEmpty) return const _EmptyChart();
    final total = usable.fold<double>(0, (sum, slice) => sum + slice.value);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 58,
                  sections: [
                    for (final slice in usable)
                      PieChartSectionData(
                        value: slice.value,
                        title:
                            '${(slice.value / total * 100).toStringAsFixed(0)}%',
                        color: slice.color,
                        radius: 72,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                centerLabel,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(letterSpacing: 0),
              ),
            ],
          ),
        ),
        _Legend(
          items: usable
              .map((slice) =>
                  _LegendItem(label: slice.label, color: slice.color))
              .toList(),
        ),
      ],
    );
  }
}

class _ProbabilityChart extends StatelessWidget {
  final Map<String, dynamic> probabilities;

  const _ProbabilityChart({required this.probabilities});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProbabilityItem(
          'Low yield', _num(probabilities['lowYield']), AppColors.amber),
      _ProbabilityItem('High profit', _num(probabilities['highProfit']),
          AppColors.limeGreen),
      _ProbabilityItem('Crop failure', _num(probabilities['cropFailureRisk']),
          AppColors.riskCritical),
      _ProbabilityItem('Weather damage', _num(probabilities['weatherDamage']),
          AppColors.burntOrange),
      _ProbabilityItem(
          'Price drop', _num(probabilities['priceDrop']), AppColors.skyBlue),
      _ProbabilityItem('Loss', _num(probabilities['loss']), AppColors.amber),
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 132,
                child: Text(item.label, style: AppTextStyles.bodySmall),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: item.value.clamp(0.0, 1.0).toDouble(),
                    minHeight: 12,
                    color: item.color,
                    backgroundColor: item.color.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                child: Text(
                  _pct(item.value),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.label.copyWith(letterSpacing: 0),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProbabilityItem {
  final String label;
  final double value;
  final Color color;

  const _ProbabilityItem(this.label, this.value, this.color);
}

class _CropPerformanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _CropPerformanceTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle:
            AppTextStyles.label.copyWith(color: AppColors.grey800),
        columns: const [
          DataColumn(label: Text('Crop')),
          DataColumn(label: Text('Season')),
          DataColumn(label: Text('Mean yield')),
          DataColumn(label: Text('Median')),
          DataColumn(label: Text('Std dev')),
          DataColumn(label: Text('Change')),
          DataColumn(label: Text('Risk')),
        ],
        rows: rows.map((row) {
          return DataRow(
            cells: [
              DataCell(Text(_cropLabel(_str(row['crop'])))),
              DataCell(Text(_str(row['season']))),
              DataCell(
                Text('${_num(row['meanYield']).toStringAsFixed(2)} t/ac'),
              ),
              DataCell(Text(_num(row['medianYield']).toStringAsFixed(2))),
              DataCell(Text(_num(row['stdDev']).toStringAsFixed(2))),
              DataCell(
                Text('${_num(row['percentChange']).toStringAsFixed(1)}%'),
              ),
              DataCell(_RiskPill(level: _str(row['riskLevel'], 'medium'))),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfitTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _ProfitTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle:
            AppTextStyles.label.copyWith(color: AppColors.grey800),
        columns: const [
          DataColumn(label: Text('Crop')),
          DataColumn(label: Text('Expected profit')),
          DataColumn(label: Text('ROI')),
          DataColumn(label: Text('Loss chance')),
          DataColumn(label: Text('Risk')),
        ],
        rows: rows.map((row) {
          return DataRow(
            cells: [
              DataCell(Text(_cropLabel(_str(row['crop'])))),
              DataCell(Text(formatPKR(_num(row['expectedProfitPerAcre'])))),
              DataCell(Text('${_num(row['roiPct']).toStringAsFixed(1)}%')),
              DataCell(Text(_pct(_num(row['probabilityLoss'])))),
              DataCell(_RiskPill(level: _str(row['riskLevel'], 'medium'))),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _RegressionPanel extends StatelessWidget {
  final Map<String, dynamic> regression;
  final String title;

  const _RegressionPanel({
    required this.regression,
    this.title = 'Linear regression',
  });

  @override
  Widget build(BuildContext context) {
    final available = regression['available'] == true;
    return _Panel(
      title: title,
      subtitle: available ? 'Prediction model output' : 'Model not available',
      child: available
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmallFact(
                  label: 'Equation',
                  value: _str(regression['equation'], 'See coefficients'),
                  color: AppColors.deepGreen,
                  wide: true,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SmallFact(
                      label: 'Predicted value',
                      value: _fixed(regression['predictedValue']),
                      color: AppColors.limeGreen,
                    ),
                    _SmallFact(
                      label: 'Reliability',
                      value:
                          '${_num(regression['modelReliabilityPct']).toStringAsFixed(1)}%',
                      color: AppColors.skyBlue,
                    ),
                    _SmallFact(
                      label: 'R squared',
                      value: _fixed(regression['rSquared']),
                      color: AppColors.deepGreen,
                    ),
                    _SmallFact(
                      label: 'p-value',
                      value: _pValue(regression['pValue']),
                      color: AppColors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _str(regression['explanation']),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            )
          : Text(
              _str(regression['message'], 'Not enough data for this model.'),
              style: AppTextStyles.bodySmall,
            ),
    );
  }
}

class _ConfidencePanel extends StatelessWidget {
  final String title;
  final Map<String, dynamic> interval;
  final String unit;
  final bool isMoney;

  const _ConfidencePanel({
    required this.title,
    required this.interval,
    required this.unit,
    this.isMoney = false,
  });

  @override
  Widget build(BuildContext context) {
    final available = interval['available'] == true;
    return _Panel(
      title: title,
      subtitle: 'Shows the likely range around the expected value',
      child: available
          ? Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SmallFact(
                  label: 'Mean',
                  value: _intervalValue(interval['mean']),
                  color: AppColors.deepGreen,
                ),
                _SmallFact(
                  label: 'Lower',
                  value: _intervalValue(interval['lower']),
                  color: AppColors.amber,
                ),
                _SmallFact(
                  label: 'Upper',
                  value: _intervalValue(interval['upper']),
                  color: AppColors.limeGreen,
                ),
                _SmallFact(
                  label: 'Confidence',
                  value:
                      '${_num(interval['confidencePct']).toStringAsFixed(0)}%',
                  color: AppColors.skyBlue,
                ),
                _SmallFact(
                  label: 'Meaning',
                  value: _str(interval['explanation']),
                  color: AppColors.grey600,
                  wide: true,
                ),
              ],
            )
          : Text(
              _str(
                interval['message'],
                'Not enough data for a confidence interval.',
              ),
              style: AppTextStyles.bodySmall,
            ),
    );
  }

  String _intervalValue(dynamic value) {
    if (isMoney) return formatPKR(_num(value), compact: true);
    return '${_num(value).toStringAsFixed(2)} $unit';
  }
}

class _CorrelationPanel extends StatelessWidget {
  final String title;
  final Map<String, dynamic> correlation;

  const _CorrelationPanel({
    required this.title,
    required this.correlation,
  });

  @override
  Widget build(BuildContext context) {
    final available = correlation['available'] == true;
    return _Panel(
      title: title,
      subtitle: 'Pearson correlation with p-value',
      child: available
          ? Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SmallFact(
                  label: 'Correlation',
                  value: _fixed(correlation['pearsonR']),
                  color: AppColors.deepGreen,
                ),
                _SmallFact(
                  label: 'Strength',
                  value: _str(correlation['strength']),
                  color: AppColors.skyBlue,
                ),
                _SmallFact(
                  label: 'Direction',
                  value: _str(correlation['direction']),
                  color: AppColors.limeGreen,
                ),
                _SmallFact(
                  label: 'p-value',
                  value: _pValue(correlation['pValue']),
                  color: AppColors.amber,
                ),
                _SmallFact(
                  label: 'Meaning',
                  value: _str(correlation['explanation']),
                  color: AppColors.grey600,
                  wide: true,
                ),
              ],
            )
          : Text(
              _str(correlation['message'], 'Correlation cannot be calculated.'),
              style: AppTextStyles.bodySmall,
            ),
    );
  }
}

class _WeatherRiskCards extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _WeatherRiskCards({required this.rows});

  @override
  Widget build(BuildContext context) {
    final stressYears = rows.where((r) => r['weatherStress'] == true).length;
    final avgRain = _average(rows.map((r) => _num(r['rainfallMm'])));
    final avgTemp = _average(rows.map((r) => _num(r['tempMaxC'])));

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SmallFact(
          label: 'Weather stress years',
          value: '$stressYears of ${rows.length}',
          color: AppColors.burntOrange,
        ),
        _SmallFact(
          label: 'Avg rainfall',
          value: '${avgRain.toStringAsFixed(0)} mm',
          color: AppColors.skyBlue,
        ),
        _SmallFact(
          label: 'Avg max temp',
          value: '${avgTemp.toStringAsFixed(1)} C',
          color: AppColors.amber,
        ),
      ],
    );
  }
}

class _RiskProbabilityCards extends StatelessWidget {
  final Map<String, dynamic> probabilities;

  const _RiskProbabilityCards({required this.probabilities});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SmallFact(
          label: 'Crop failure',
          value: _pct(_num(probabilities['cropFailureRisk'])),
          color: AppColors.riskCritical,
        ),
        _SmallFact(
          label: 'Weather damage',
          value: _pct(_num(probabilities['weatherDamage'])),
          color: AppColors.burntOrange,
        ),
        _SmallFact(
          label: 'Price drop',
          value: _pct(_num(probabilities['priceDrop'])),
          color: AppColors.skyBlue,
        ),
        _SmallFact(
          label: 'Low yield',
          value: _pct(_num(probabilities['lowYield'])),
          color: AppColors.amber,
        ),
      ],
    );
  }
}

class _TestResultTile extends StatelessWidget {
  final Map<String, dynamic> test;

  const _TestResultTile({required this.test});

  @override
  Widget build(BuildContext context) {
    if (test.isEmpty) return const SizedBox.shrink();
    if (test['available'] != true) return _UnavailableTile(test: test);
    final significant = test['significant'] == true;
    final color = significant ? AppColors.deepGreen : AppColors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            significant ? Icons.check_circle_rounded : Icons.info_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_str(test['test'], 'Statistical test')} - ${_str(test['metric'], 'metric')}',
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'p-value ${_pValue(test['pValue'])}. ${_str(test['explanation'])}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableTile extends StatelessWidget {
  final Map<String, dynamic> test;

  const _UnavailableTile({required this.test});

  @override
  Widget build(BuildContext context) {
    if (test.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.grey600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _str(
                test['message'],
                'This test cannot be applied to the selected data.',
              ),
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoColumn extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoColumn({
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 1050;
    if (!wide) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _SmallFact extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool wide;

  const _SmallFact({
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 420 : 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label.copyWith(letterSpacing: 0)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color == AppColors.grey600 ? AppColors.darkText : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskPill extends StatelessWidget {
  final String level;

  const _RiskPill({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        _titleCase(level),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _NoticeBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      color: color.withValues(alpha: 0.10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphNote extends StatelessWidget {
  final String text;

  const _GraphNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 16,
            color: AppColors.amber,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;

  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(item.label, style: AppTextStyles.bodySmall),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});
}

class _InsightBullet extends StatelessWidget {
  final String text;

  const _InsightBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.deepGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _DataQualityRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataQualityRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              _titleCase(label),
              style: AppTextStyles.label.copyWith(letterSpacing: 0),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'No data available for this selection.',
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.burntOrange,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text('Analytics could not load', style: AppTextStyles.headingSmall),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Slice {
  final String label;
  final double value;
  final Color color;

  const _Slice({
    required this.label,
    required this.value,
    required this.color,
  });
}

List<_Slice> _slicesFromRows(
  List<Map<String, dynamic>> rows, {
  required String valueKey,
  required String labelKey,
  bool positiveOnly = false,
}) {
  final slices = <_Slice>[];
  for (int i = 0; i < rows.length; i++) {
    final raw = _num(rows[i][valueKey]);
    final value = positiveOnly ? math.max(0.0, raw) : raw.abs();
    slices.add(
      _Slice(
        label: labelKey == 'crop'
            ? _cropLabel(_str(rows[i][labelKey]))
            : _str(rows[i][labelKey]),
        value: value,
        color: AppColors.cropColors[i % AppColors.cropColors.length],
      ),
    );
  }
  return slices;
}

List<_Slice> _costBreakdownSlices(List<Map<String, dynamic>> rows) {
  if (rows.isEmpty) return const [];
  final latest = rows.last;
  final total = _num(latest['costPerAcre']);
  final fertilizer = _num(latest['fertilizerCostPerAcre']);
  final irrigation = _num(latest['irrigationCostPerAcre']);
  final other = math.max(0.0, total - fertilizer - irrigation);
  return [
    const _Slice(
      label: 'Fertilizer',
      value: 0,
      color: AppColors.deepGreen,
    ).copyWithValue(fertilizer),
    const _Slice(
      label: 'Irrigation',
      value: 0,
      color: AppColors.skyBlue,
    ).copyWithValue(irrigation),
    const _Slice(
      label: 'Other',
      value: 0,
      color: AppColors.amber,
    ).copyWithValue(other),
  ];
}

extension _SliceCopy on _Slice {
  _Slice copyWithValue(double nextValue) {
    return _Slice(label: label, value: nextValue, color: color);
  }
}

List<_Slice> _riskDistributionSlices(List<Map<String, dynamic>> rows) {
  final counts = <String, int>{};
  for (final row in rows) {
    final level = _str(row['riskLevel'], 'unknown').toLowerCase();
    counts[level] = (counts[level] ?? 0) + 1;
  }
  return counts.entries.map((entry) {
    return _Slice(
      label: _titleCase(entry.key),
      value: entry.value.toDouble(),
      color: _riskColor(entry.key),
    );
  }).toList();
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _rows(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value.map(_map).where((row) => row.isNotEmpty).toList();
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.map((item) => item.toString()).toList();
}

double _num(dynamic value, [double fallback = 0.0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double _average(Iterable<double> values) {
  final data = values.where((v) => v.isFinite).toList();
  if (data.isEmpty) return 0;
  return data.reduce((a, b) => a + b) / data.length;
}

String _str(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String _fixed(dynamic value, [int digits = 2]) =>
    _num(value).toStringAsFixed(digits);

String _pct(double value) => '${(value * 100).toStringAsFixed(0)}%';

String _pValue(dynamic value) {
  final v = _num(value, double.nan);
  if (v.isNaN) return 'n/a';
  if (v < 0.0001) return '<0.0001';
  return v.toStringAsFixed(4);
}

String _cropLabel(String id) {
  if (id == 'all') return 'All crops';
  return AppCrops.all.firstWhere(
    (crop) => crop['id'] == id,
    orElse: () => {'label': _titleCase(id)},
  )['label']!;
}

String _cropShort(String id) {
  switch (id) {
    case 'sugarcane':
      return 'Sugar';
    default:
      return _cropLabel(id);
  }
}

String _titleCase(String value) {
  return value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

Color _riskColor(String level) {
  switch (level.toLowerCase()) {
    case 'low':
    case 'good':
      return AppColors.riskGood;
    case 'medium':
    case 'watch':
      return AppColors.riskWatch;
    case 'high':
    case 'critical':
      return AppColors.riskCritical;
    default:
      return AppColors.grey600;
  }
}

String _compactMoney(double value) {
  final abs = value.abs();
  if (abs >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  return value.toStringAsFixed(0);
}
