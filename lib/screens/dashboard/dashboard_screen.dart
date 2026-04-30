// lib/screens/dashboard/dashboard_screen.dart
//
// CropSense Dashboard — the first screen users see.
// Shows national KPIs, live alert ticker, and province summaries.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/screens/dashboard/widgets/kpi_card.dart';
import 'package:cropsense/screens/dashboard/widgets/alert_ticker.dart';
import 'package:cropsense/screens/dashboard/widgets/province_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1200;
    final isCompact = width < 800;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ─────────────────────────────────────
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),

            // ── Alert ticker ────────────────────────────────────
            AlertTicker(alerts: _mockAlerts),
            const SizedBox(height: AppSpacing.lg),

            // ── KPI cards row ───────────────────────────────────
            _buildKpiRow(context, isCompact),
            const SizedBox(height: AppSpacing.lg),

            // ── Section title ───────────────────────────────────
            Row(
              children: [
                Text('Province Overview',
                    style: AppTextStyles.headingMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/map'),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('View Map'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Province cards grid ──────────────────────────────
            _buildProvinceGrid(context, isWide, isCompact),
            const SizedBox(height: AppSpacing.lg),

            // ── Bottom row: quick actions + recent queries ───────
            _buildBottomRow(context, isCompact),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pakistan Farm Intelligence',
                style: AppTextStyles.displayLarge,
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 4),
              Text(
                'Real-time crop monitoring across 36 districts · '
                'Updated ${DateTime.now().hour}:00 today',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
            ],
          ),
        ),
        // Data freshness badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withValues(alpha: 0.15),
            borderRadius: AppRadius.chipRadius,
            border: Border.all(
              color: AppColors.limeGreen.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.limeGreen,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scaleXY(begin: 1, end: 1.5, duration: 1000.ms)
                  .then()
                  .scaleXY(begin: 1.5, end: 1, duration: 1000.ms),
              const SizedBox(width: 8),
              Text(
                'Live Data',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.deepGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── KPI Cards ─────────────────────────────────────────────────────────
  Widget _buildKpiRow(BuildContext context, bool isCompact) {
    final cards = [
      const KpiCard(
        label: 'DISTRICTS MONITORED',
        value: '36',
        unit: '',
        icon: Icons.location_on_rounded,
        color: AppColors.deepGreen,
        subtitle: 'Across 4 provinces',
      ),
      const KpiCard(
        label: 'AVG YIELD FORECAST',
        value: '2.1',
        unit: 't/acre',
        icon: Icons.grass_rounded,
        color: AppColors.skyBlue,
        subtitle: '↑ 8% vs last season',
      ),
      KpiCard(
        label: 'ACTIVE ALERTS',
        value: '14',
        unit: '',
        icon: Icons.warning_rounded,
        color: AppColors.burntOrange,
        subtitle: '2 critical, 5 high',
        isAlert: true,
      ),
      const KpiCard(
        label: 'CROPS TRACKED',
        value: '5',
        unit: '',
        icon: Icons.agriculture_rounded,
        color: AppColors.limeGreen,
        subtitle: 'Wheat · Rice · Cotton · More',
      ),
    ];

    if (isCompact) {
      // Compact: 2×2 grid
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.6,
        children: cards,
      );
    }

    // Standard/Wide: single row
    return Row(
      children: cards
          .map((card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: card,
                ),
              ))
          .toList(),
    );
  }

  // ── Province Grid ─────────────────────────────────────────────────────
  Widget _buildProvinceGrid(
      BuildContext context, bool isWide, bool isCompact) {
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

  // ── Bottom Row ────────────────────────────────────────────────────────
  Widget _buildBottomRow(BuildContext context, bool isCompact) {
    if (isCompact) {
      return Column(
        children: [
          _buildQuickActions(context),
          const SizedBox(height: AppSpacing.md),
          _buildRecentQueries(context),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildQuickActions(context)),
        const SizedBox(width: AppSpacing.md),
        Expanded(flex: 3, child: _buildRecentQueries(context)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            icon: Icons.psychology_rounded,
            label: 'Get AI Advice',
            color: AppColors.amber,
            onTap: () => context.go('/ai-advisor'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: Icons.map_rounded,
            label: 'View Risk Map',
            color: AppColors.skyBlue,
            onTap: () => context.go('/map'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: Icons.bar_chart_rounded,
            label: 'Open Analytics',
            color: AppColors.limeGreen,
            onTap: () => context.go('/analytics'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Generate Report',
            color: AppColors.burntOrange,
            onTap: () => context.go('/reports'),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildRecentQueries(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent AI Queries', style: AppTextStyles.headingSmall),
              const Spacer(),
              Text('Last 24 hours',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._mockQueries.map((q) => _QueryTile(query: q)),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: color.withValues(alpha: 0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueryTile extends StatelessWidget {
  final _MockQuery query;
  const _QueryTile({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(query.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                Text(
                  '${query.district} · ${query.crop} · ${query.time}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: query.riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              query.risk,
              style: TextStyle(
                color: query.riskColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────────────────────
final _mockAlerts = [
  const AlertTickerItem(
    district: 'Quetta',
    message: 'Critical drought conditions — yield forecast below 1.0 t/acre',
    severity: 'critical',
  ),
  const AlertTickerItem(
    district: 'Multan',
    message: 'High rust risk detected — immediate fungicide recommended',
    severity: 'high',
  ),
  const AlertTickerItem(
    district: 'Karachi',
    message: 'Extreme heat stress — NDVI dropping rapidly',
    severity: 'high',
  ),
  const AlertTickerItem(
    district: 'Tharparkar',
    message: 'Rainfall 60% below seasonal average',
    severity: 'critical',
  ),
  const AlertTickerItem(
    district: 'Faisalabad',
    message: 'Watch: Soil moisture declining — consider irrigation',
    severity: 'watch',
  ),
  const AlertTickerItem(
    district: 'Sukkur',
    message: 'Pest pressure increasing — monitor cotton fields',
    severity: 'watch',
  ),
];

class _MockQuery {
  final String title;
  final String district;
  final String crop;
  final String time;
  final String risk;
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
    riskColor: AppColors.burntOrange,
  ),
  _MockQuery(
    title: 'Irrigation schedule',
    district: 'Multan',
    crop: 'Cotton',
    time: '4h ago',
    risk: 'Watch',
    riskColor: AppColors.amber,
  ),
  _MockQuery(
    title: 'Yield forecast review',
    district: 'Lahore',
    crop: 'Rice',
    time: '6h ago',
    risk: 'Good',
    riskColor: AppColors.limeGreen,
  ),
  _MockQuery(
    title: 'Fertilizer advice',
    district: 'Peshawar',
    crop: 'Maize',
    time: '8h ago',
    risk: 'Good',
    riskColor: AppColors.limeGreen,
  ),
];