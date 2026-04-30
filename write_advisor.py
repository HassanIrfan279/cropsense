import os

bs = chr(92)
nl = chr(10)
q = chr(39)
lt = chr(60)
gt = chr(62)

os.makedirs(f'lib{bs}screens{bs}ai_advisor{bs}widgets', exist_ok=True)

# ── Risk Meter Widget ─────────────────────────────────────────────────
risk_meter = """import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cropsense/core/utils.dart';

class RiskMeterWidget extends StatelessWidget {
  final double riskScore;
  const RiskMeterWidget({super.key, required this.riskScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(180, 100),
          painter: _GaugePainter(riskScore: riskScore),
        ),
        const SizedBox(height: 8),
        Text(
          'Risk Score: ${riskScore.toStringAsFixed(0)}/100',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: riskScoreColor(riskScore),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double riskScore;
  _GaugePainter({required this.riskScore});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    final colors = [
      const Color(0xFF1B5E20),
      const Color(0xFF8BC34A),
      const Color(0xFFFF8F00),
      const Color(0xFFE65100),
      const Color(0xFFB71C1C),
    ];
    final sweepAngle = pi * (riskScore / 100);
    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: pi + sweepAngle,
      colors: colors,
    );
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, sweepAngle, false, fgPaint);

    final needleAngle = pi + (pi * riskScore / 100);
    final needleX = cx + (radius - 8) * cos(needleAngle);
    final needleY = cy + (radius - 8) * sin(needleAngle);
    final needlePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(needleX, needleY), needlePaint);
    canvas.drawCircle(Offset(cx, cy), 5,
        Paint()..color = const Color(0xFF1A1A1A));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.riskScore != riskScore;
}
"""

# ── Symptom Selector Widget ───────────────────────────────────────────
symptom_selector = """import 'package:flutter/material.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';

class SymptomSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const SymptomSelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observed Symptoms', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        Text('Select all that apply', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppSymptoms.all.map((s) {
            final isSelected = selected.contains(s['id']);
            return GestureDetector(
              onTap: () => onToggle(s['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.deepGreen
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.deepGreen
                        : AppColors.grey200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.grey600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
"""

# ── Medicine Card Widget ──────────────────────────────────────────────
medicine_card = """import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String type;
  final String dose;
  final double pricePerAcre;
  final String urgency;
  final String purpose;
  final String whereToBuy;

  const MedicineCard({
    super.key,
    required this.name,
    required this.type,
    required this.dose,
    required this.pricePerAcre,
    required this.urgency,
    required this.purpose,
    required this.whereToBuy,
  });

  Color get _urgencyColor {
    switch (urgency) {
      case 'immediate': return AppColors.burntOrange;
      case 'within_week': return AppColors.amber;
      default: return AppColors.limeGreen;
    }
  }

  String get _urgencyLabel {
    switch (urgency) {
      case 'immediate': return 'Apply Immediately';
      case 'within_week': return 'Within a Week';
      default: return 'Preventive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _urgencyColor.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _urgencyColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.medication_rounded,
                    color: _urgencyColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name,
                      style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _urgencyColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(_urgencyLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(icon: Icons.science_rounded,
                    label: 'Dose', value: dose),
                const SizedBox(height: 6),
                _Row(icon: Icons.currency_rupee_rounded,
                    label: 'Cost/acre',
                    value: formatPKR(pricePerAcre)),
                const SizedBox(height: 6),
                _Row(icon: Icons.info_outline_rounded,
                    label: 'Treats', value: purpose),
                const SizedBox(height: 6),
                _Row(icon: Icons.store_rounded,
                    label: 'Buy at', value: whereToBuy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.grey600),
        const SizedBox(width: 6),
        Text('$label: ',
            style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}
"""

# ── Advice Result Panel ───────────────────────────────────────────────
advice_panel = """import 'package:flutter/material.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertBanner(),
          const SizedBox(height: 16),
          _buildDiagnosisCard(),
          const SizedBox(height: 16),
          _buildActionSteps(),
          const SizedBox(height: 16),
          if (advice.medicines.isNotEmpty) ...[
            Text('Recommended Products',
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ...advice.medicines.map((m) => MedicineCard(
              name: m.name,
              type: m.type.name,
              dose: m.dose,
              pricePerAcre: m.pricePerAcrePkr,
              urgency: m.urgency.name,
              purpose: m.purpose,
              whereToBuy: m.whereToBuy,
            )),
            const SizedBox(height: 16),
          ],
          _buildCostCard(),
          const SizedBox(height: 16),
          _buildAdvisoryCards(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFB71C1C).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_rounded,
                color: Color(0xFFB71C1C), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Alert',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: const Color(0xFFB71C1C))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${advice.confidencePct.toStringAsFixed(0)}% confidence',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(advice.alertEnglish,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.deepGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(advice.alertUrdu,
                style: AppTextStyles.urduBody.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.biotech_rounded,
                color: AppColors.skyBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnosis',
                    style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(advice.diagnosis,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSteps() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.checklist_rounded,
                color: AppColors.deepGreen, size: 20),
            const SizedBox(width: 8),
            Text('Action Steps', style: AppTextStyles.headingSmall),
          ]),
          const SizedBox(height: 12),
          ...advice.actionSteps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(step,
                      style: AppTextStyles.bodyMedium),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost & ROI Estimate',
              style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _CostChip(
              label: 'Per Acre',
              value: formatPKR(advice.totalCostPerAcrePkr),
              icon: Icons.grass_rounded,
            )),
            const SizedBox(width: 8),
            Expanded(child: _CostChip(
              label: 'Total Farm',
              value: formatPKR(advice.totalCostForFarmPkr),
              icon: Icons.agriculture_rounded,
            )),
            const SizedBox(width: 8),
            Expanded(child: _CostChip(
              label: 'Yield Boost',
              value: '+${advice.expectedYieldIncreasePct.toStringAsFixed(0)}%',
              icon: Icons.trending_up_rounded,
            )),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Color(0xFF8BC34A), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(advice.roiNote,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _InfoCard(
          icon: Icons.water_drop_rounded,
          title: 'Irrigation',
          body: advice.irrigationAdvice,
          color: AppColors.skyBlue,
        )),
        const SizedBox(width: 12),
        Expanded(child: _InfoCard(
          icon: Icons.eco_rounded,
          title: 'Fertilizer',
          body: advice.fertilizerAdvice,
          color: AppColors.limeGreen,
        )),
      ],
    );
  }
}

class _CostChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _CostChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13)),
        Text(label, style: const TextStyle(
            color: Colors.white60, fontSize: 10)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _InfoCard({required this.icon, required this.title,
      required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.headingSmall.copyWith(
                fontSize: 13, color: color)),
          ]),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
"""

# ── Main AI Advisor Screen ────────────────────────────────────────────
advisor_screen = f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/providers/ai_advisor_provider.dart';
import 'package:cropsense/screens/ai_advisor/widgets/risk_meter.dart';
import 'package:cropsense/screens/ai_advisor/widgets/symptom_selector.dart';
import 'package:cropsense/screens/ai_advisor/widgets/advice_result_panel.dart';

class AIAdvisorScreen extends ConsumerWidget {{
  const AIAdvisorScreen({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final width = MediaQuery.of(context).size.width;
    final isCompact = width {lt} 800;
    final form = ref.watch(advisorFormProvider);
    final adviceAsync = ref.watch(aiAdviceProvider);

    if (isCompact) {{
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildForm(context, ref, form),
              const SizedBox(height: 16),
              adviceAsync.when(
                data: (advice) => advice != null
                    ? AdviceResultPanel(advice: advice)
                    : const SizedBox.shrink(),
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.deepGreen)),
                error: (e, _) => Text('Error: \$e'),
              ),
            ],
          ),
        ),
      );
    }}

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildForm(context, ref, form),
                  ),
                ),
                Container(width: 1, color: AppColors.grey200),
                Expanded(
                  child: adviceAsync.when(
                    data: (advice) => advice != null
                        ? AdviceResultPanel(advice: advice)
                        : _buildEmptyResult(),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.deepGreen)),
                    error: (e, _) => Center(child: Text('Error: \$e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }}

  Widget _buildHeader() {{
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.amber, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Farm Advisor',
                  style: AppTextStyles.headingMedium),
              Text('Powered by Grok AI — Roman Urdu + English',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }}

  Widget _buildForm(
      BuildContext context, WidgetRef ref, AdvisorFormState form) {{
    final notifier = ref.read(advisorFormProvider.notifier);
    final riskScore = _calcRisk(form);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Farm Conditions', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildDropdown{lt}String{gt}(
            label: 'District',
            value: form.district,
            items: AppDistricts.all.take(12).map((d) =>
                DropdownMenuItem(value: d['id'], child: Text(d['label']!))).toList(),
            onChanged: notifier.setDistrict,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildDropdown{lt}String{gt}(
            label: 'Crop',
            value: form.crop,
            items: AppCrops.all.map((c) =>
                DropdownMenuItem(value: c['id'], child: Text(c['label']!))).toList(),
            onChanged: notifier.setCrop,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildDropdown{lt}String{gt}(
            label: 'Season',
            value: form.season,
            items: ['Rabi', 'Kharif'].map((s) =>
                DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: notifier.setSeason,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildSliderTile(
            label: 'Farm Size',
            value: form.farmSizeAcres,
            min: 1, max: 100,
            unit: 'acres',
            onChanged: notifier.setFarmSize,
          )),
        ]),
        const SizedBox(height: 16),
        Text('Field Readings', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        _buildSliderTile(
          label: 'NDVI',
          value: form.ndvi,
          min: 0.0, max: 1.0,
          unit: '',
          decimals: 2,
          onChanged: notifier.setNdvi,
        ),
        _buildSliderTile(
          label: 'Rainfall',
          value: form.rainfallMm,
          min: 0, max: 500,
          unit: 'mm',
          onChanged: notifier.setRainfall,
        ),
        _buildSliderTile(
          label: 'Max Temp',
          value: form.tempMaxC,
          min: 20, max: 50,
          unit: '°C',
          onChanged: notifier.setTempMax,
        ),
        _buildSliderTile(
          label: 'Soil Moisture',
          value: form.soilMoisturePct,
          min: 10, max: 80,
          unit: '%',
          onChanged: notifier.setSoilMoisture,
        ),
        _buildSliderTile(
          label: 'Water Table',
          value: form.waterTableM,
          min: 1, max: 20,
          unit: 'm',
          onChanged: notifier.setWaterTable,
        ),
        const SizedBox(height: 16),
        Consumer(builder: (context, ref, _) {{
          final f = ref.watch(advisorFormProvider);
          return SymptomSelector(
            selected: f.selectedSymptoms,
            onToggle: ref.read(advisorFormProvider.notifier).toggleSymptom,
          );
        }}),
        const SizedBox(height: 20),
        Center(child: RiskMeterWidget(riskScore: riskScore)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Consumer(builder: (context, ref, _) {{
            final adviceAsync = ref.watch(aiAdviceProvider);
            final isLoading = adviceAsync is AsyncLoading;
            return ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => ref.read(aiAdviceProvider.notifier).analyze(),
              icon: isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.psychology_rounded),
              label: Text(isLoading
                  ? 'Analyzing with AI...'
                  : 'Analyze with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            );
          }}),
        ),
      ],
    );
  }}

  Widget _buildDropdown{lt}T{gt}({{
    required String label,
    required T value,
    required List{lt}DropdownMenuItem{lt}T{gt}{gt} items,
    required ValueChanged{lt}T{gt} onChanged,
  }}) {{
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: DropdownButton{lt}T{gt}(
            value: value,
            items: items,
            onChanged: (v) => onChanged(v as T),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }}

  Widget _buildSliderTile({{
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged{lt}double{gt} onChanged,
    int decimals = 0,
  }}) {{
    final display = decimals == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimals);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: min, max: max,
                activeColor: AppColors.deepGreen,
                inactiveColor: AppColors.grey200,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$display$unit',
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }}

  Widget _buildEmptyResult() {{
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.amber, size: 48),
          ),
          const SizedBox(height: 20),
          Text('Fill in farm conditions',
              style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text('Then tap "Analyze with AI" to get\\nyour personalized advisory',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }}

  double _calcRisk(AdvisorFormState form) {{
    double score = 0;
    if (form.ndvi {lt} 0.3) score += 30;
    else if (form.ndvi {lt} 0.5) score += 15;
    if (form.rainfallMm {lt} 50) score += 25;
    else if (form.rainfallMm {lt} 100) score += 10;
    if (form.tempMaxC {gt} 42) score += 20;
    else if (form.tempMaxC {gt} 38) score += 10;
    if (form.soilMoisturePct {lt} 20) score += 15;
    if (form.selectedSymptoms.isNotEmpty &&
        !form.selectedSymptoms.contains('no_symptoms')) score += 10;
    return score.clamp(0, 100);
  }}
}}
"""

# Write all files
files = {
    f'lib{bs}screens{bs}ai_advisor{bs}widgets{bs}risk_meter.dart': risk_meter,
    f'lib{bs}screens{bs}ai_advisor{bs}widgets{bs}symptom_selector.dart': symptom_selector,
    f'lib{bs}screens{bs}ai_advisor{bs}widgets{bs}medicine_card.dart': medicine_card,
    f'lib{bs}screens{bs}ai_advisor{bs}widgets{bs}advice_result_panel.dart': advice_panel,
    f'lib{bs}screens{bs}ai_advisor{bs}ai_advisor_screen.dart': advisor_screen,
}

for path, content in files.items():
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Written: {path}')

print('\n All AI Advisor files written!')