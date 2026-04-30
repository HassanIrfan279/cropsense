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
