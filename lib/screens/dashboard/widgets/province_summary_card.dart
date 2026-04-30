// lib/screens/dashboard/widgets/province_summary_card.dart
//
// Province summary card — shows one province's agricultural overview.
// Used in the 2×2 grid on the Dashboard.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';

class ProvinceSummaryCard extends StatelessWidget {
  final String province;
  final int districtCount;
  final double avgYield;
  final String dominantCrop;
  final String riskLevel;
  final double ndvi;
  final int alertCount;
  final int animationDelay; // ms — staggers card animations

  const ProvinceSummaryCard({
    super.key,
    required this.province,
    required this.districtCount,
    required this.avgYield,
    required this.dominantCrop,
    required this.riskLevel,
    required this.ndvi,
    required this.alertCount,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = riskColor(riskLevel);
    final label = riskLabel(riskLevel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.deepGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    province,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Risk badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Stats grid ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.location_city_rounded,
                      label: '$districtCount Districts',
                      color: AppColors.skyBlue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatChip(
                      icon: Icons.grass_rounded,
                      label: formatYield(avgYield),
                      color: AppColors.limeGreen,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.eco_rounded,
                      label: 'NDVI ${formatNdvi(ndvi)}',
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatChip(
                      icon: Icons.warning_amber_rounded,
                      label: '$alertCount Alerts',
                      color: alertCount > 2
                          ? AppColors.burntOrange
                          : AppColors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Dominant crop tag
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs + 2,
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.limeGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.agriculture_rounded,
                          size: 14, color: AppColors.deepGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Main crop: $dominantCrop',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms);
  }
}

// Small chip used inside the stats grid
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}