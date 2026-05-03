import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/screens/dashboard/widgets/kpi_card.dart';
import 'package:cropsense/screens/dashboard/widgets/alert_ticker.dart';
import 'package:cropsense/screens/dashboard/widgets/province_summary_card.dart';
import 'package:cropsense/providers/weather_provider.dart';
import 'package:cropsense/data/models/weather_data.dart';
import 'package:cropsense/shared/widgets/neon_background.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _weatherDistricts = [
    'faisalabad',
    'multan',
    'karachi',
    'quetta'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1200;
    final isCompact = width < 800;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero section (gradient + image + KPI cards) ────────
            _buildHero(isCompact),

            // ── Content below the hero ─────────────────────────────
            Padding(
              padding:
                  EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlertTicker(alerts: _mockAlerts),
                  const SizedBox(height: AppSpacing.sm),
                  _LiveWeatherStrip(districts: _weatherDistricts, ref: ref),
                  const SizedBox(height: AppSpacing.md),
                  Row(children: [
                    Text('Province Overview',
                        style: AppTextStyles.headingMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.go('/map'),
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('View Map'),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  _buildProvinceGrid(isWide, isCompact),
                  const SizedBox(height: AppSpacing.lg),
                  _buildBottomRow(context, isCompact),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero section ────────────────────────────────────────────────────────
  Widget _buildHero(bool isCompact) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF082B0B), Color(0xFF1B5E20), Color(0xFF265A23)],
        ),
      ),
      child: Stack(children: [
        // Pakistan wheat field network image at low opacity
        Positioned.fill(
          child: Opacity(
            opacity: 0.13,
            child: Image.network(
              'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b'
              '?w=1400&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        // Gradient fade at the bottom for depth
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF1B5E20).withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        // Hero content
        Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 16 : 28,
            isCompact ? 24 : 32,
            isCompact ? 16 : 28,
            isCompact ? 20 : 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(isCompact),
              SizedBox(height: isCompact ? 20 : 28),
              _buildKpiRow(isCompact),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeroHeader(bool isCompact) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Pakistan Farm Intelligence',
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontSize: isCompact ? 22 : 30,
              letterSpacing: 0,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(
              begin: -0.04, end: 0, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 6),
          Text(
            'Real-time crop monitoring across 36 districts · '
            'Updated ${DateTime.now().hour}:00 today',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ).animate(delay: 100.ms).fadeIn(duration: 600.ms),
        ]),
      ),
      const SizedBox(width: 16),

      // Pulsing "Live Data" badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: AppRadius.chipRadius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.limeGreen, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                  begin: 1, end: 1.7, duration: 900.ms, curve: Curves.easeInOut)
              .then()
              .scaleXY(begin: 1.7, end: 1, duration: 900.ms),
          const SizedBox(width: 8),
          Text('Live Data',
              style: AppTextStyles.label
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
      ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
    ]);
  }

  Widget _buildKpiRow(bool isCompact) {
    const cards = [
      KpiCard(
        label: 'DISTRICTS MONITORED',
        value: '36',
        unit: '',
        icon: Icons.location_on_rounded,
        color: AppColors.limeGreen,
        subtitle: 'Across 4 provinces',
        delay: 0,
      ),
      KpiCard(
        label: 'AVG YIELD FORECAST',
        value: '2.1',
        unit: 't/acre',
        icon: Icons.grass_rounded,
        color: AppColors.skyBlue,
        subtitle: '↑ 8% vs last season',
        delay: 100,
      ),
      KpiCard(
        label: 'ACTIVE ALERTS',
        value: '14',
        unit: '',
        icon: Icons.warning_rounded,
        color: AppColors.amber,
        subtitle: '2 critical, 5 high',
        isAlert: true,
        delay: 200,
      ),
      KpiCard(
        label: 'CROPS TRACKED',
        value: '5',
        unit: '',
        icon: Icons.agriculture_rounded,
        color: Colors.white,
        subtitle: 'Wheat · Rice · Cotton · More',
        delay: 300,
      ),
    ];

    if (isCompact) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.45,
        children: cards,
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  // ── Province grid ────────────────────────────────────────────────────────
  Widget _buildProvinceGrid(bool isWide, bool isCompact) {
    final cards = [
      const ProvinceSummaryCard(
        province: 'Punjab',
        districtCount: 14,
        avgYield: 2.4,
        dominantCrop: 'Wheat',
        riskLevel: 'watch',
        ndvi: 0.64,
        alertCount: 6,
        animationDelay: 0,
      ),
      const ProvinceSummaryCard(
        province: 'Sindh',
        districtCount: 8,
        avgYield: 1.9,
        dominantCrop: 'Rice',
        riskLevel: 'high',
        ndvi: 0.51,
        alertCount: 5,
        animationDelay: 100,
      ),
      const ProvinceSummaryCard(
        province: 'Khyber Pakhtunkhwa',
        districtCount: 6,
        avgYield: 2.1,
        dominantCrop: 'Maize',
        riskLevel: 'above',
        ndvi: 0.68,
        alertCount: 2,
        animationDelay: 200,
      ),
      const ProvinceSummaryCard(
        province: 'Balochistan',
        districtCount: 8,
        avgYield: 1.2,
        dominantCrop: 'Wheat',
        riskLevel: 'critical',
        ndvi: 0.31,
        alertCount: 7,
        animationDelay: 300,
      ),
    ];

    return GridView.count(
      crossAxisCount: isCompact ? 1 : (isWide ? 4 : 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: isCompact ? 2.2 : (isWide ? 0.95 : 1.35),
      children: cards,
    );
  }

  // ── Bottom row ───────────────────────────────────────────────────────────
  Widget _buildBottomRow(BuildContext context, bool isCompact) {
    if (isCompact) {
      return Column(children: [
        _buildQuickActions(context),
        const SizedBox(height: AppSpacing.md),
        _buildRecentQueries(),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 2, child: _buildQuickActions(context)),
      const SizedBox(width: AppSpacing.md),
      Expanded(flex: 3, child: _buildRecentQueries()),
    ]);
  }

  Widget _buildQuickActions(BuildContext context) {
    return GlassPanel(
      glowColor: AppColors.amber,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.deepGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.deepGreen, size: 16),
          ),
          const SizedBox(width: 8),
          Text('Quick Actions', style: AppTextStyles.headingSmall),
        ]),
        const SizedBox(height: AppSpacing.md),
        _ActionButton(
            icon: Icons.psychology_rounded,
            label: 'Get AI Advice',
            color: AppColors.amber,
            onTap: () => context.go('/ai-advisor')),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
            icon: Icons.map_rounded,
            label: 'View Risk Map',
            color: AppColors.skyBlue,
            onTap: () => context.go('/map')),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
            icon: Icons.bar_chart_rounded,
            label: 'Open Analytics',
            color: AppColors.limeGreen,
            onTap: () => context.go('/analytics')),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Generate Report',
            color: AppColors.burntOrange,
            onTap: () => context.go('/reports')),
      ]),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildRecentQueries() {
    return GlassPanel(
      glowColor: AppColors.skyBlue,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.deepGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.deepGreen, size: 16),
          ),
          const SizedBox(width: 8),
          Text('Recent AI Queries', style: AppTextStyles.headingSmall),
          const Spacer(),
          Text('Last 24 hours', style: AppTextStyles.bodySmall),
        ]),
        const SizedBox(height: AppSpacing.md),
        ..._mockQueries.map((q) => _QueryTile(query: q)),
      ]),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }
}

// ── Action button with hover scale + arrow slide ──────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _hovered ? 0.13 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              child: Row(children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(widget.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.color, fontWeight: FontWeight.w600)),
                const Spacer(),
                AnimatedSlide(
                  offset: _hovered ? const Offset(0.25, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 140),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: widget.color.withValues(alpha: 0.5), size: 14),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent query tile ─────────────────────────────────────────────────────────
class _QueryTile extends StatelessWidget {
  final _MockQuery query;
  const _QueryTile({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.psychology_rounded,
              color: AppColors.deepGreen, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(query.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            Text('${query.district} · ${query.crop} · ${query.time}',
                style: AppTextStyles.bodySmall),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: query.riskColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(query.risk,
              style: TextStyle(
                  color: query.riskColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── Live Weather Strip ────────────────────────────────────────────────────────
class _LiveWeatherStrip extends ConsumerStatefulWidget {
  final List<String> districts;
  final WidgetRef ref;
  const _LiveWeatherStrip({required this.districts, required this.ref});

  @override
  ConsumerState<_LiveWeatherStrip> createState() => _LiveWeatherStripState();
}

class _LiveWeatherStripState extends ConsumerState<_LiveWeatherStrip> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.districts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final district = widget.districts[index];
          final weatherAsync = ref.watch(weatherProvider(district));
          return weatherAsync.when(
            loading: () => _WeatherTile.loading(district),
            error: (_, __) => _WeatherTile.error(district),
            data: (w) => _WeatherTile(weather: w),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }
}

class _WeatherTile extends StatelessWidget {
  final WeatherData? weather;
  final String? districtLabel;
  final bool isLoading;
  final bool isError;

  const _WeatherTile({required WeatherData this.weather})
      : districtLabel = null,
        isLoading = false,
        isError = false;

  const _WeatherTile.loading(String district)
      : weather = null,
        districtLabel = district,
        isLoading = true,
        isError = false;

  const _WeatherTile.error(String district)
      : weather = null,
        districtLabel = district,
        isLoading = false,
        isError = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _tileShell(
        district: districtLabel!,
        child: const Center(
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    if (isError || weather == null) {
      return _tileShell(
        district: districtLabel!,
        child:
            const Icon(Icons.cloud_off_rounded, size: 18, color: Colors.grey),
      );
    }

    final w = weather!;
    final tempColor = w.heatStressAlert
        ? AppColors.burntOrange
        : w.temperature > 35
            ? AppColors.amber
            : AppColors.limeGreen;

    return _tileShell(
      district: w.district[0].toUpperCase() + w.district.substring(1),
      child: Row(children: [
        // Temperature badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tempColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (w.heatStressAlert)
              const Icon(Icons.local_fire_department_rounded,
                  size: 12, color: Colors.deepOrange),
            Text('${w.temperature.toStringAsFixed(0)}°C',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tempColor)),
          ]),
        ),
        const SizedBox(width: 6),
        // Rainfall
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            w.droughtAlert
                ? Icons.water_drop_outlined
                : Icons.water_drop_rounded,
            size: 12,
            color: w.droughtAlert ? AppColors.burntOrange : AppColors.skyBlue,
          ),
          const SizedBox(width: 2),
          Text('${w.rainfall30day.toStringAsFixed(0)}mm',
              style: TextStyle(
                  fontSize: 11,
                  color: w.droughtAlert
                      ? AppColors.burntOrange
                      : AppColors.skyBlue)),
        ]),
      ]),
    );
  }

  Widget _tileShell({required String district, required Widget child}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.chipRadius,
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            district,
            style: AppTextStyles.label.copyWith(
                color: AppColors.deepGreen, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final _mockAlerts = [
  const AlertTickerItem(
      district: 'Quetta',
      message: 'Critical drought conditions — yield forecast below 1.0 t/acre',
      severity: 'critical'),
  const AlertTickerItem(
      district: 'Multan',
      message: 'High rust risk detected — immediate fungicide recommended',
      severity: 'high'),
  const AlertTickerItem(
      district: 'Karachi',
      message: 'Extreme heat stress — NDVI dropping rapidly',
      severity: 'high'),
  const AlertTickerItem(
      district: 'Tharparkar',
      message: 'Rainfall 60% below seasonal average',
      severity: 'critical'),
  const AlertTickerItem(
      district: 'Faisalabad',
      message: 'Watch: Soil moisture declining — consider irrigation',
      severity: 'watch'),
  const AlertTickerItem(
      district: 'Sukkur',
      message: 'Pest pressure increasing — monitor cotton fields',
      severity: 'watch'),
];

class _MockQuery {
  final String title, district, crop, time, risk;
  final Color riskColor;
  const _MockQuery({
    required this.title,
    required this.district,
    required this.crop,
    required this.time,
    required this.risk,
    required this.riskColor,
  });
}

final _mockQueries = [
  _MockQuery(
      title: 'Rust disease diagnosis',
      district: 'Faisalabad',
      crop: 'Wheat',
      time: '2h ago',
      risk: 'High',
      riskColor: AppColors.burntOrange),
  _MockQuery(
      title: 'Irrigation schedule',
      district: 'Multan',
      crop: 'Cotton',
      time: '4h ago',
      risk: 'Watch',
      riskColor: AppColors.amber),
  _MockQuery(
      title: 'Yield forecast review',
      district: 'Lahore',
      crop: 'Rice',
      time: '6h ago',
      risk: 'Good',
      riskColor: AppColors.limeGreen),
  _MockQuery(
      title: 'Fertilizer advice',
      district: 'Peshawar',
      crop: 'Maize',
      time: '8h ago',
      risk: 'Good',
      riskColor: AppColors.limeGreen),
];
