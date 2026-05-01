import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';

class RiskMeterWidget extends StatelessWidget {
  final double riskScore;
  const RiskMeterWidget({super.key, required this.riskScore});

  String get _label {
    if (riskScore < 20) return 'Low Risk';
    if (riskScore < 40) return 'Moderate';
    if (riskScore < 60) return 'Elevated';
    if (riskScore < 80) return 'High Risk';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final color = riskScoreColor(riskScore);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(children: [
        // Animated circular gauge
        TweenAnimationBuilder<double>(
          key: ValueKey(riskScore.round()),
          tween: Tween(begin: 0.0, end: riskScore / 100),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => SizedBox(
            width: 68, height: 68,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: v,
                strokeWidth: 7,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(riskScore.toStringAsFixed(0),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color,
                    height: 1)),
                Text('/100', style: const TextStyle(fontSize: 9, color: AppColors.grey600)),
              ]),
            ]),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Risk Score', style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text(_label, style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.3)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(riskScore.round()),
              tween: Tween(begin: 0.0, end: riskScore / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 4,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Updates live with field conditions',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600, fontSize: 10)),
        ])),
      ]),
    );
  }
}
