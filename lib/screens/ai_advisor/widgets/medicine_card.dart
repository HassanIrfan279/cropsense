import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';

class MedicineCard extends StatefulWidget {
  final String name, type, dose, urgency, purpose, whereToBuy;
  final double pricePerAcre;
  final int index;

  const MedicineCard({
    super.key,
    required this.name,
    required this.type,
    required this.dose,
    required this.pricePerAcre,
    required this.urgency,
    required this.purpose,
    required this.whereToBuy,
    this.index = 0,
  });

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _urgencyColor {
    switch (widget.urgency) {
      case 'immediate':
        return AppColors.burntOrange;
      case 'within_week':
        return AppColors.amber;
      default:
        return AppColors.limeGreen;
    }
  }

  String get _urgencyLabel {
    switch (widget.urgency) {
      case 'immediate':
        return 'Immediate';
      case 'within_week':
        return 'This Week';
      default:
        return 'Preventive';
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case 'fungicide':
        return Icons.spa_rounded;
      case 'pesticide':
        return Icons.bug_report_rounded;
      case 'herbicide':
        return Icons.grass_rounded;
      case 'fertilizer':
        return Icons.eco_rounded;
      case 'growth_reg':
        return Icons.science_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  String get _typeLabel {
    switch (widget.type) {
      case 'fungicide':
        return 'Fungicide';
      case 'pesticide':
        return 'Pesticide';
      case 'herbicide':
        return 'Herbicide';
      case 'fertilizer':
        return 'Fertilizer';
      case 'growth_reg':
        return 'Growth Regulator';
      default:
        return widget.type;
    }
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = _urgencyColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Tap-to-expand header ────────────────────────────────────
        GestureDetector(
          onTap: _toggle,
          child: Container(
            color: color.withValues(alpha: 0.07),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.name,
                        style:
                            AppTextStyles.headingSmall.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    Text(_typeLabel,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey600, fontSize: 11)),
                  ])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(100)),
                child: Text(_urgencyLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 0.5).animate(
                    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: color, size: 20),
              ),
            ]),
          ),
        ),
        // ── Expandable detail body ──────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row(Icons.science_rounded, 'Dose', widget.dose,
                            AppColors.skyBlue),
                        const Divider(height: 14, color: AppColors.grey200),
                        _row(
                            Icons.currency_rupee_rounded,
                            'Cost/acre',
                            formatPKR(widget.pricePerAcre),
                            AppColors.limeGreen),
                        const Divider(height: 14, color: AppColors.grey200),
                        _row(Icons.info_outline_rounded, 'Treats',
                            widget.purpose, color),
                        const Divider(height: 14, color: AppColors.grey200),
                        _row(Icons.store_rounded, 'Buy at', widget.whereToBuy,
                            AppColors.deepGreen),
                      ]),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    )
        .animate(delay: Duration(milliseconds: 80 * widget.index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _row(IconData icon, String label, String value, Color iconColor) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: iconColor),
      const SizedBox(width: 8),
      SizedBox(
          width: 60,
          child: Text('$label:',
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.grey600))),
      Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
    ]);
  }
}
