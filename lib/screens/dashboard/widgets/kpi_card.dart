// lib/screens/dashboard/widgets/kpi_card.dart
//
// Animated KPI card — counts up from 0 to target value on load.
// Used in the Dashboard top row for key statistics.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';

class KpiCard extends StatelessWidget {
  final String label;        // e.g. "Districts Monitored"
  final String value;        // e.g. "36" or "2.1"
  final String unit;         // e.g. "" or "t/acre" or "Active"
  final IconData icon;
  final Color color;
  final String? subtitle;    // Optional second line
  final bool isAlert;        // If true, pulses red

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isAlert
              ? AppColors.burntOrange.withValues(alpha: 0.4)
              : AppColors.grey200,
        ),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon + label row ───────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              // Alert pulse indicator
              if (isAlert)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.burntOrange,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scaleXY(
                      begin: 1.0,
                      end: 1.4,
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scaleXY(begin: 1.4, end: 1.0, duration: 800.ms),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Big number (animates in) ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.kpiNumber.copyWith(color: color),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unit,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // ── Label ─────────────────────────────────────────────
          Text(label, style: AppTextStyles.label),

          // ── Optional subtitle ─────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }
}