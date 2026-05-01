import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isAlert;
  final int delay; // ms — staggered entrance animation

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isAlert = false,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (isAlert)
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.55),
                          blurRadius: 7,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scaleXY(
                          begin: 1.0, end: 1.6,
                          duration: 800.ms, curve: Curves.easeInOut)
                      .then()
                      .scaleXY(begin: 1.6, end: 1.0, duration: 800.ms),
              ]),

              const SizedBox(height: AppSpacing.md),

              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(value,
                    style: AppTextStyles.kpiNumber
                        .copyWith(color: Colors.white, letterSpacing: -1.2))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(unit,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white60, fontSize: 13)),
                  ),
                ],
              ]),

              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.label.copyWith(color: Colors.white70)),

              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white54)),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.25, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}
