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
      return Scaffold(backgroundColor: AppColors.offWhite,
        body: SingleChildScrollView(padding: const EdgeInsets.all(16),
          child: Column(children: [
            _header(),
            const SizedBox(height: 16),
            _form(context, ref, form),
            const SizedBox(height: 16),
            adviceAsync.when(
              data: (a) => a != null ? AdviceResultPanel(advice: a) : const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(color: AppColors.deepGreen),
              error: (e, _) => Text(e.toString()),
            ),
          ]),
        ),
      );
    }
    return Scaffold(backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _header(),
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 420, child: SingleChildScrollView(
            padding: const EdgeInsets.all(20), child: _form(context, ref, form))),
          Container(width: 1, color: AppColors.grey200),
          Expanded(child: adviceAsync.when(
            data: (a) => a != null ? AdviceResultPanel(advice: a) : _empty(),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),
            error: (e, _) => Center(child: Text(e.toString())),
          )),
        ])),
      ]),
    );
  }
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.psychology_rounded, color: AppColors.amber, size: 24)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Farm Advisor', style: AppTextStyles.headingMedium),
          Text('Powered by Grok AI - Roman Urdu + English', style: AppTextStyles.bodySmall),
        ]),
      ]),
    );
  }
  Widget _form(BuildContext context, WidgetRef ref, AdvisorFormState form) {
    final n = ref.read(advisorFormProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Farm Conditions', style: AppTextStyles.headingSmall),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _dd<String>('District', form.district,
          AppDistricts.all.take(12).map((d) => DropdownMenuItem(value: d['id'], child: Text(d['label']!))).toList(),
          n.setDistrict)),
        const SizedBox(width: 12),
        Expanded(child: _dd<String>('Crop', form.crop,
          AppCrops.all.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!))).toList(),
          n.setCrop)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _dd<String>('Season', form.season,
          ['Rabi', 'Kharif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          n.setSeason)),
        const SizedBox(width: 12),
        Expanded(child: _sl('Farm Size', form.farmSizeAcres, 1, 100, ' acres', n.setFarmSize)),
      ]),
      const SizedBox(height: 16),
      Text('Field Readings', style: AppTextStyles.headingSmall),
      const SizedBox(height: 12),
      _sl('NDVI', form.ndvi, 0.0, 1.0, '', n.setNdvi, dec: 2),
      _sl('Rainfall', form.rainfallMm, 0, 500, ' mm', n.setRainfall),
      _sl('Max Temp', form.tempMaxC, 20, 50, ' C', n.setTempMax),
      _sl('Soil Moisture', form.soilMoisturePct, 10, 80, '%', n.setSoilMoisture),
      _sl('Water Table', form.waterTableM, 1, 20, ' m', n.setWaterTable),
      const SizedBox(height: 16),
      Consumer(builder: (ctx, ref, _) {
        final f = ref.watch(advisorFormProvider);
        return SymptomSelector(selected: f.selectedSymptoms,
          onToggle: ref.read(advisorFormProvider.notifier).toggleSymptom);
      }),
      const SizedBox(height: 20),
      Center(child: RiskMeterWidget(riskScore: _risk(form))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: Consumer(builder: (ctx, ref, _) {
        final busy = ref.watch(aiAdviceProvider) is AsyncLoading;
        return ElevatedButton.icon(
          onPressed: busy ? null : () => ref.read(aiAdviceProvider.notifier).analyze(),
          icon: busy ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.psychology_rounded),
          label: Text(busy ? 'Analyzing...' : 'Analyze with AI'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber,
            foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        );
      })),
    ]);
  }
  Widget _dd<T>(String label, T value, List<DropdownMenuItem<T>> items, ValueChanged<T> fn) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label), const SizedBox(height: 4),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey200)),
        child: DropdownButton<T>(value: value, items: items,
          onChanged: (v) => fn(v as T), isExpanded: true,
          underline: const SizedBox.shrink(), style: AppTextStyles.bodyMedium)),
    ]);
  }
  Widget _sl(String label, double value, double min, double max, String unit, ValueChanged<double> fn, {int dec = 0}) {
    final d = dec == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(dec);
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600))),
      Expanded(child: SliderTheme(data: const SliderThemeData(trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7)),
        child: Slider(value: value, min: min, max: max,
          activeColor: AppColors.deepGreen, inactiveColor: AppColors.grey200, onChanged: fn))),
      SizedBox(width: 70, child: Text(d + unit,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.deepGreen),
        textAlign: TextAlign.right)),
    ]));
  }
  Widget _empty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.psychology_rounded, color: AppColors.amber, size: 48)),
      const SizedBox(height: 20),
      Text('Fill in farm conditions', style: AppTextStyles.headingMedium),
      const SizedBox(height: 8),
      Text('Then tap Analyze with AI', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        textAlign: TextAlign.center),
    ]));
  }
  double _risk(AdvisorFormState form) {
    double s = 0;
    if (form.ndvi < 0.3) s += 30; else if (form.ndvi < 0.5) s += 15;
    if (form.rainfallMm < 50) s += 25; else if (form.rainfallMm < 100) s += 10;
    if (form.tempMaxC > 42) s += 20; else if (form.tempMaxC > 38) s += 10;
    if (form.soilMoisturePct < 20) s += 15;
    if (form.selectedSymptoms.isNotEmpty && !form.selectedSymptoms.contains('no_symptoms')) s += 10;
    return s.clamp(0, 100);
  }
}