import 'package:flutter/material.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';

class SymptomSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const SymptomSelector({super.key, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Observed Symptoms', style: AppTextStyles.headingSmall),
      const SizedBox(height: 8),
      Text('Select all that apply', style: AppTextStyles.bodySmall),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: AppSymptoms.all.map((s) {
        final sel = selected.contains(s['id']);
        return GestureDetector(
          onTap: () => onToggle(s['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.deepGreen : AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AppColors.deepGreen : AppColors.grey200, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(sel ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 16, color: sel ? Colors.white : AppColors.grey600),
              const SizedBox(width: 6),
              Text(s['label'] as String,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: sel ? Colors.white : AppColors.darkText)),
            ]),
          ),
        );
      }).toList()),
    ]);
  }
}