import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/providers/ai_advisor_provider.dart';
import 'package:cropsense/screens/ai_advisor/widgets/risk_meter.dart';
import 'package:cropsense/screens/ai_advisor/widgets/symptom_selector.dart';
import 'package:cropsense/screens/ai_advisor/widgets/advice_result_panel.dart';

class AIAdvisorScreen extends ConsumerWidget {
  const AIAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    final form = ref.watch(advisorFormProvider);
    final adviceAsync = ref.watch(aiAdviceProvider);

    if (isCompact) {
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
    }

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
  }

  Widget _buildHeader() {
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
  }

  Widget _buildForm(
      BuildContext context, WidgetRef ref, AdvisorFormState form) {
    final notifier = ref.read(advisorFormProvider.notifier);
    final riskScore = _calcRisk(form);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Farm Conditions', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildDropdown<String>(
            label: 'District',
            value: form.district,
            items: AppDistricts.all.take(12).map((d) =>
                DropdownMenuItem(value: d['id'], child: Text(d['label']!))).toList(),
            onChanged: notifier.setDistrict,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildDropdown<String>(
            label: 'Crop',
            value: form.crop,
            items: AppCrops.all.map((c) =>
                DropdownMenuItem(value: c['id'], child: Text(c['label']!))).toList(),
            onChanged: notifier.setCrop,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildDropdown<String>(
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
        Consumer(builder: (context, ref, _) {
          final f = ref.watch(advisorFormProvider);
          return SymptomSelector(
            selected: f.selectedSymptoms,
            onToggle: ref.read(advisorFormProvider.notifier).toggleSymptom,
          );
        }),
        const SizedBox(height: 20),
        Center(child: RiskMeterWidget(riskScore: riskScore)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Consumer(builder: (context, ref, _) {
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
          }),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
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
          child: DropdownButton<T>(
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
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
    int decimals = 0,
  }) {
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
  }

  Widget _buildEmptyResult() {
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
          Text('Then tap "Analyze with AI" to get\nyour personalized advisory',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  double _calcRisk(AdvisorFormState form) {
    double score = 0;
    if (form.ndvi < 0.3) score += 30;
    else if (form.ndvi < 0.5) score += 15;
    if (form.rainfallMm < 50) score += 25;
    else if (form.rainfallMm < 100) score += 10;
    if (form.tempMaxC > 42) score += 20;
    else if (form.tempMaxC > 38) score += 10;
    if (form.soilMoisturePct < 20) score += 15;
    if (form.selectedSymptoms.isNotEmpty &&
        !form.selectedSymptoms.contains('no_symptoms')) score += 10;
    return score.clamp(0, 100);
  }
}
