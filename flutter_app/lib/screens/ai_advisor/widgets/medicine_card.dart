import 'package:flutter/material.dart';
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
  const MedicineCard({super.key, required this.name, required this.type,
    required this.dose, required this.pricePerAcre, required this.urgency,
    required this.purpose, required this.whereToBuy});

  Color get _uc {
    switch (urgency) {
      case 'immediate': return AppColors.burntOrange;
      case 'within_week': return AppColors.amber;
      default: return AppColors.limeGreen;
    }
  }
  String get _ul {
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
        border: Border.all(color: _uc.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _uc.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(Icons.medication_rounded, color: _uc, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: AppTextStyles.headingSmall.copyWith(fontSize: 14))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _uc, borderRadius: BorderRadius.circular(100)),
              child: Text(_ul, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _row(Icons.science_rounded, 'Dose', dose),
          const SizedBox(height: 6),
          _row(Icons.currency_rupee_rounded, 'Cost/acre', formatPKR(pricePerAcre)),
          const SizedBox(height: 6),
          _row(Icons.info_outline_rounded, 'Treats', purpose),
          const SizedBox(height: 6),
          _row(Icons.store_rounded, 'Buy at', whereToBuy),
        ])),
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: AppColors.grey600),
      const SizedBox(width: 6),
      Text(label + ': ', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
    ]);
  }
}