// lib/screens/map/widgets/district_popup.dart
//
// District detail panel — shown when user clicks a district on the map.
// Wide screen: slides in as right panel.
// Compact: shown as bottom sheet.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/data/models/risk_map.dart';

class DistrictPopup extends StatelessWidget {
  final RiskMapEntry district;
  final VoidCallback onClose;

  const DistrictPopup({
    super.key,
    required this.district,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color = riskColor(district.riskLevel.name);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevated,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.deepGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        district.districtName,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        district.province,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Stats ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Risk level badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: color, size: 10),
                      const SizedBox(width: 8),
                      Text(
                        'Risk: ${district.riskLevel.label}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${district.riskScore.toStringAsFixed(0)}/100',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // NDVI row
                _InfoRow(
                  icon: Icons.satellite_alt_rounded,
                  label: 'NDVI',
                  value: formatNdvi(district.ndvi),
                  color: AppColors.skyBlue,
                ),
                const Divider(height: 1),

                // Yield per crop
                ...district.cropYields.entries.map(
                  (e) => Column(
                    children: [
                      _InfoRow(
                        icon: Icons.grass_rounded,
                        label: '${e.key[0].toUpperCase()}${e.key.substring(1)} yield',
                        value: formatYield(e.value),
                        color: AppColors.limeGreen,
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),

                // Alerts
                _InfoRow(
                  icon: Icons.warning_rounded,
                  label: 'Active Alerts',
                  value: '${district.alertCount}',
                  color: district.alertCount > 3
                      ? AppColors.burntOrange
                      : AppColors.amber,
                ),

                const SizedBox(height: AppSpacing.md),

                // AI Advisor button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/ai-advisor'),
                    icon: const Icon(Icons.psychology_rounded, size: 18),
                    label: const Text('Analyze with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}