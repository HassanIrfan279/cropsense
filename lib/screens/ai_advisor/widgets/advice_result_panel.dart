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
