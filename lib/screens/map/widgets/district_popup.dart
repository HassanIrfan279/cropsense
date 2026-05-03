import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/data/models/risk_map.dart';

class DistrictPopup extends StatelessWidget {
  final RiskMapEntry district;
  final String selectedCrop;
  final int selectedYear;
  final VoidCallback onClose;

  const DistrictPopup({
    super.key,
    required this.district,
    required this.selectedCrop,
    required this.selectedYear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final dataAvailable = district.dataAvailable;
    final color =
        dataAvailable ? riskColor(district.riskLevel.name) : AppColors.grey600;
    final crop = (district.selectedCrop.isNotEmpty
            ? district.selectedCrop
            : selectedCrop)
        .replaceAll('-', ' ');
    final cropLabel =
        crop.isEmpty ? 'Crop' : '${crop[0].toUpperCase()}${crop.substring(1)}';
    final year = district.selectedYear ?? selectedYear;

    return Container(
      width: 320,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 48,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevated,
        border: Border.all(color: AppColors.grey200),
      ),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Header(
            district: district,
            cropLabel: cropLabel,
            year: year,
            onClose: onClose,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: [
              _RiskBadge(
                label: dataAvailable
                    ? 'Risk: ${district.riskLevel.label}'
                    : 'Data unavailable',
                score: district.riskScore,
                color: color,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!dataAvailable)
                _Notice(
                  text: district.aiExplanation.isNotEmpty
                      ? district.aiExplanation
                      : 'No connected CropSense API data is available for this region.',
                ),
              _InfoRow(
                icon: Icons.grass_rounded,
                label: '$cropLabel yield',
                value: district.yieldTAcre == null
                    ? 'Unavailable'
                    : formatYield(district.yieldTAcre!),
                color: AppColors.limeGreen,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icons.factory_rounded,
                label: 'Production',
                value: district.productionTons == null
                    ? 'Data unavailable'
                    : '${district.productionTons!.toStringAsFixed(1)} tons',
                color: AppColors.amber,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icons.water_drop_rounded,
                label: 'Rainfall',
                value: district.rainfallMm == null
                    ? 'Unavailable'
                    : '${district.rainfallMm!.toStringAsFixed(0)} mm',
                color: AppColors.skyBlue,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icons.satellite_alt_rounded,
                label: 'NDVI',
                value:
                    dataAvailable ? formatNdvi(district.ndvi) : 'Unavailable',
                color: AppColors.skyBlue,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icons.warning_rounded,
                label: 'Active risk flags',
                value: '${district.alertCount}',
                color: district.alertCount > 3
                    ? AppColors.burntOrange
                    : AppColors.amber,
              ),
              if (district.weatherRisks.isNotEmpty)
                _BulletSection(
                  title: 'Weather risks',
                  items: district.weatherRisks,
                  color: AppColors.skyBlue,
                ),
              if (district.cropRisks.isNotEmpty)
                _BulletSection(
                  title: 'Crop risks',
                  items: district.cropRisks,
                  color: AppColors.burntOrange,
                ),
              if (district.aiExplanation.isNotEmpty)
                _Notice(text: district.aiExplanation),
              if (district.limitations.isNotEmpty)
                _BulletSection(
                  title: 'Data limits',
                  items: district.limitations,
                  color: AppColors.grey600,
                ),
              if (district.cropYields.isNotEmpty)
                _BulletSection(
                  title: 'Crop comparison yields',
                  items: district.cropYields.entries
                      .map((entry) =>
                          '${entry.key}: ${formatYield(entry.value)}')
                      .toList(),
                  color: AppColors.deepGreen,
                ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/ai-advisor'),
                  icon: const Icon(Icons.psychology_rounded, size: 18),
                  label: const Text('Analyze with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final RiskMapEntry district;
  final String cropLabel;
  final int year;
  final VoidCallback onClose;

  const _Header({
    required this.district,
    required this.cropLabel,
    required this.year,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              district.districtName,
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
            Text(
              '${district.province} | $cropLabel | $year',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ]),
        ),
        IconButton(
          onPressed: onClose,
          icon:
              const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _RiskBadge({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '${score.toStringAsFixed(0)}/100',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
      ]),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.22)),
      ),
      child: Text(text, style: AppTextStyles.bodySmall.copyWith(height: 1.45)),
    );
  }
}

class _BulletSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _BulletSection({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.label.copyWith(color: color)),
        const SizedBox(height: 6),
        ...items.take(5).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('- ', style: TextStyle(color: color)),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                        ),
                      ),
                    ]),
              ),
            ),
      ]),
    );
  }
}
