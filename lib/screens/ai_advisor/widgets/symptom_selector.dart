import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';

class SymptomSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const SymptomSelector({super.key, required this.selected, required this.onToggle});

  static IconData _icon(String name) {
    switch (name) {
      case 'warning_amber': return Icons.warning_amber_rounded;
      case 'blur_on':       return Icons.blur_on_rounded;
      case 'local_florist': return Icons.local_florist_rounded;
      case 'bug_report':    return Icons.bug_report_rounded;
      case 'trending_down': return Icons.trending_down_rounded;
      case 'texture':       return Icons.texture_rounded;
      case 'check_circle':  return Icons.check_circle_rounded;
      default:              return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.visibility_rounded, size: 15, color: AppColors.deepGreen),
        const SizedBox(width: 6),
        Text('Observed Symptoms', style: AppTextStyles.headingSmall),
      ]),
      const SizedBox(height: 3),
      Text('Tap all that apply', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.7,
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
        ),
        itemCount: AppSymptoms.all.length,
        itemBuilder: (_, i) {
          final s = AppSymptoms.all[i];
          final id    = s['id'] as String;
          final label = s['label'] as String;
          final urdu  = s['urdu'] as String;
          final sel   = selected.contains(id);
          return _SymptomCard(
            id: id, label: label, urdu: urdu,
            icon: _icon(s['icon'] as String),
            selected: sel,
            onTap: () => onToggle(id),
            delay: i * 35,
          );
        },
      ),
    ]);
  }
}

class _SymptomCard extends StatelessWidget {
  final String id, label, urdu;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int delay;

  const _SymptomCard({
    required this.id, required this.label, required this.urdu,
    required this.icon, required this.selected,
    required this.onTap, required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = id == 'no_symptoms';
    final activeColor = isPositive ? AppColors.limeGreen : AppColors.deepGreen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? activeColor : AppColors.grey200,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
            ? [BoxShadow(
                color: activeColor.withValues(alpha: 0.28),
                blurRadius: 8, offset: const Offset(0, 3))]
            : AppShadows.card,
        ),
        child: Row(children: [
          // Icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: selected
                ? Colors.white.withValues(alpha: 0.22)
                : activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14,
              color: selected ? Colors.white : activeColor),
          ),
          const SizedBox(width: 7),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.darkText),
                overflow: TextOverflow.ellipsis),
              Text(urdu,
                style: TextStyle(
                  fontSize: 9.5,
                  color: selected
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.grey600),
                overflow: TextOverflow.ellipsis),
            ],
          )),
          if (selected)
            const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
        ]),
      )
      .animate(delay: Duration(milliseconds: delay))
      .fadeIn(duration: 280.ms)
      .slideY(begin: 0.12, end: 0),
    );
  }
}
