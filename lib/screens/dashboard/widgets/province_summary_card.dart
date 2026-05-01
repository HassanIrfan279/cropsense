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
  final int animationDelay;

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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF3F8F3)],
        ),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Colored left strip matching risk level ────────────────
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
          ),

          // ── Card content ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Province name + risk badge
                  Row(children: [
                    Expanded(
                      child: Text(province,
                          style: AppTextStyles.headingSmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: color.withValues(alpha: 0.28), width: 1),
                      ),
                      child: Text(label, style: TextStyle(
                        color: color, fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ]),

                  const SizedBox(height: AppSpacing.sm + 4),

                  // Stats chips — 2 rows
                  Row(children: [
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
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
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
                  ]),

                  const SizedBox(height: AppSpacing.sm),

                  // Dominant crop tag
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs + 2,
                        horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                          color: AppColors.limeGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.agriculture_rounded,
                          size: 14, color: AppColors.deepGreen),
                      const SizedBox(width: 6),
                      Text('Main crop: $dominantCrop',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.deepGreen,
                            fontWeight: FontWeight.w600,
                          )),
                    ]),
                  ),
                ],
              ),
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
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}
