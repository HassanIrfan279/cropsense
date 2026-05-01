import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/data/models/ai_advice.dart';
import 'package:cropsense/screens/ai_advisor/widgets/medicine_card.dart';

class AdviceResultPanel extends StatelessWidget {
  final AIAdvice advice;
  const AdviceResultPanel({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _AlertBanner(advice: advice),
        const SizedBox(height: 14),
        _DiagnosisCard(advice: advice),
        const SizedBox(height: 14),
        _ActionStepsCard(steps: advice.actionSteps),
        const SizedBox(height: 14),
        if (advice.medicines.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.medication_rounded,
            title: 'Recommended Products',
            trailing: const Text('Tap card to expand',
              style: TextStyle(fontSize: 11, color: AppColors.grey600)),
          ),
          const SizedBox(height: 8),
          ...advice.medicines.asMap().entries.map((e) => MedicineCard(
            name: e.value.name,
            type: e.value.type.name,
            dose: e.value.dose,
            pricePerAcre: e.value.pricePerAcrePkr,
            urgency: e.value.urgency.name,
            purpose: e.value.purpose,
            whereToBuy: e.value.whereToBuy,
            index: e.key,
          )),
          const SizedBox(height: 6),
        ],
        _CostSection(advice: advice),
        const SizedBox(height: 14),
        _RoiBox(advice: advice),
        const SizedBox(height: 14),
        _IrrigationFertilizerRow(advice: advice),
        const SizedBox(height: 14),
        _NextCheckupBanner(days: advice.nextCheckupDays),
        const SizedBox(height: 8),
      ]),
    ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alert banner with pulsing icon + confidence gauge
// ─────────────────────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final AIAdvice advice;
  const _AlertBanner({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB71C1C).withValues(alpha: 0.22)),
        boxShadow: [BoxShadow(
          color: const Color(0xFFB71C1C).withValues(alpha: 0.06),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Pulsing warning icon
          const Icon(Icons.warning_rounded, color: Color(0xFFB71C1C), size: 22)
            .animate(onPlay: (c) => c.repeat())
            .scaleXY(begin: 1.0, end: 1.3, duration: 720.ms, curve: Curves.easeInOut)
            .then()
            .scaleXY(begin: 1.3, end: 1.0, duration: 720.ms),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Field Alert', style: AppTextStyles.headingSmall.copyWith(
              color: const Color(0xFFB71C1C))),
            Text(advice.alertEnglish, style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(width: 10),
          _ConfidenceGauge(pct: advice.confidencePct),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.1)),
          ),
          child: Text(advice.alertUrdu,
            style: AppTextStyles.urduBody.copyWith(fontSize: 13.5, height: 1.6)),
        ),
      ]),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: -0.06, end: 0);
  }
}

// ── Animated confidence circular gauge ──────────────────────────────────────
class _ConfidenceGauge extends StatelessWidget {
  final double pct;
  const _ConfidenceGauge({required this.pct});

  Color get _color {
    if (pct >= 75) return AppColors.limeGreen;
    if (pct >= 50) return AppColors.amber;
    return AppColors.burntOrange;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 54, height: 54,
        child: Stack(alignment: Alignment.center, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: pct / 100),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => CircularProgressIndicator(
              value: v,
              strokeWidth: 5,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${pct.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
            const Text('conf.', style: TextStyle(fontSize: 7, color: AppColors.grey600)),
          ]),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis card
// ─────────────────────────────────────────────────────────────────────────────
class _DiagnosisCard extends StatelessWidget {
  final AIAdvice advice;
  const _DiagnosisCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.2)),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.biotech_rounded, color: AppColors.skyBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Diagnosis', style: AppTextStyles.label),
          const SizedBox(height: 3),
          Text(advice.diagnosis,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        ])),
      ]),
    )
    .animate(delay: 80.ms).fadeIn(duration: 380.ms).slideX(begin: -0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action steps with staggered entrance
// ─────────────────────────────────────────────────────────────────────────────
class _ActionStepsCard extends StatelessWidget {
  final List<String> steps;
  const _ActionStepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.deepGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.checklist_rounded,
              color: AppColors.deepGreen, size: 16),
          ),
          const SizedBox(width: 8),
          Text('Action Steps', style: AppTextStyles.headingSmall),
        ]),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((e) =>
          _StepRow(step: e.value, index: e.key)),
      ]),
    ).animate(delay: 130.ms).fadeIn(duration: 380.ms);
  }
}

class _StepRow extends StatelessWidget {
  final String step;
  final int index;
  const _StepRow({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(
            color: AppColors.deepGreen, shape: BoxShape.circle),
          child: Center(child: Text('${index + 1}',
            style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(step, style: AppTextStyles.bodyMedium),
        )),
      ]),
    )
    .animate(delay: Duration(milliseconds: 220 + 90 * index))
    .fadeIn(duration: 320.ms)
    .slideX(begin: -0.08, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cost section with pie chart
// ─────────────────────────────────────────────────────────────────────────────
class _CostSection extends StatelessWidget {
  final AIAdvice advice;
  const _CostSection({required this.advice});

  static const Map<String, Color> _typeColors = {
    'fungicide':  Color(0xFF26A69A),
    'pesticide':  AppColors.burntOrange,
    'herbicide':  AppColors.limeGreen,
    'fertilizer': AppColors.skyBlue,
    'growth_reg': Color(0xFFAB47BC),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B12), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: AppColors.deepGreen.withValues(alpha: 0.3),
          blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.account_balance_wallet_rounded,
            color: Colors.white60, size: 17),
          const SizedBox(width: 8),
          Text('Cost & ROI',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _chip('Per Acre', formatPKR(advice.totalCostPerAcrePkr), Icons.grass_rounded),
          const SizedBox(width: 7),
          _chip('Total Farm',
            formatPKR(advice.totalCostForFarmPkr, compact: true),
            Icons.agriculture_rounded),
          const SizedBox(width: 7),
          _chip('+Yield',
            '+${advice.expectedYieldIncreasePct.toStringAsFixed(0)}%',
            Icons.trending_up_rounded),
        ]),
        // Pie chart for cost distribution (only when ≥2 medicines)
        if (advice.medicines.length >= 2) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 14),
          _buildPieRow(context),
        ],
      ]),
    ).animate(delay: 180.ms).fadeIn(duration: 380.ms);
  }

  Widget _chip(String label, String value, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.5)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ]),
    ));
  }

  Widget _buildPieRow(BuildContext context) {
    final meds = advice.medicines;
    final total = meds.fold<double>(0, (s, m) => s + m.pricePerAcrePkr);
    if (total <= 0) return const SizedBox.shrink();

    return Row(children: [
      SizedBox(
        width: 100, height: 100,
        child: PieChart(PieChartData(
          centerSpaceRadius: 28,
          sectionsSpace: 2,
          sections: meds.asMap().entries.map((e) {
            final m = e.value;
            final color = _typeColors[m.type.name] ?? AppColors.grey400;
            final pct = m.pricePerAcrePkr / total;
            return PieChartSectionData(
              color: color,
              value: m.pricePerAcrePkr,
              title: '${(pct * 100).toStringAsFixed(0)}%',
              radius: 34,
              titleStyle: const TextStyle(
                fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white),
            );
          }).toList(),
        )),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: meds.map((m) {
          final color = _typeColors[m.type.name] ?? AppColors.grey400;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Container(width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Expanded(child: Text(
                m.name.split(' ').take(2).join(' '),
                style: const TextStyle(
                  color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
              Text(formatPKR(m.pricePerAcrePkr, compact: true),
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
            ]),
          );
        }).toList(),
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold ROI box
// ─────────────────────────────────────────────────────────────────────────────
class _RoiBox extends StatelessWidget {
  final AIAdvice advice;
  const _RoiBox({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF0B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.45)),
        boxShadow: [BoxShadow(
          color: AppColors.amber.withValues(alpha: 0.14),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lightbulb_rounded, color: AppColors.amber, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ROI Estimate', style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF6D4C00))),
          const SizedBox(height: 5),
          Text(advice.roiNote, style: const TextStyle(
            fontSize: 12, color: Color(0xFF5A3D00), height: 1.45)),
          if (advice.expectedYieldIncreasePct > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.amber),
                const SizedBox(width: 5),
                Text('+${advice.expectedYieldIncreasePct.toStringAsFixed(0)}% '
                  'expected yield increase',
                  style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amber)),
              ]),
            ),
          ],
        ])),
      ]),
    ).animate(delay: 250.ms).fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Irrigation + Fertilizer cards
// ─────────────────────────────────────────────────────────────────────────────
class _IrrigationFertilizerRow extends StatelessWidget {
  final AIAdvice advice;
  const _IrrigationFertilizerRow({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _InfoCard(
        icon: Icons.water_drop_rounded,
        title: 'Irrigation',
        body: advice.irrigationAdvice,
        color: AppColors.skyBlue,
      )),
      const SizedBox(width: 10),
      Expanded(child: _InfoCard(
        icon: Icons.eco_rounded,
        title: 'Fertilizer',
        body: advice.fertilizerAdvice,
        color: AppColors.limeGreen,
      )),
    ]).animate(delay: 300.ms).fadeIn(duration: 380.ms);
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final Color color;
  const _InfoCard({
    required this.icon, required this.title,
    required this.body, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 13),
          ),
          const SizedBox(width: 7),
          Text(title, style: AppTextStyles.headingSmall.copyWith(
            fontSize: 12.5, color: color)),
        ]),
        const SizedBox(height: 8),
        Text(body, style: AppTextStyles.bodySmall),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Next checkup banner
// ─────────────────────────────────────────────────────────────────────────────
class _NextCheckupBanner extends StatelessWidget {
  final int days;
  const _NextCheckupBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.18)),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_month_rounded,
          color: AppColors.deepGreen, size: 17),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'Next field check recommended in $days days',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600, color: AppColors.deepGreen))),
      ]),
    ).animate(delay: 350.ms).fadeIn(duration: 380.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 17, color: AppColors.deepGreen),
      const SizedBox(width: 7),
      Text(title, style: AppTextStyles.headingSmall),
      if (trailing != null) ...[const Spacer(), trailing!],
    ]);
  }
}
