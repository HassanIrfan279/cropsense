// lib/screens/map/widgets/map_legend.dart
//
// Map legend overlay — shown bottom-left on the map screen.
// Explains what each district polygon color means.

import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Risk Level', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          ..._legendItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.$2,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: item.$2.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.$1, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (label, color) pairs for each risk level
  static const _legendItems = [
    ('Good',         AppColors.riskGood),
    ('Above Average',AppColors.riskAbove),
    ('Watch',        AppColors.riskWatch),
    ('High Risk',    AppColors.riskHigh),
    ('Critical',     AppColors.riskCritical),
  ];
}