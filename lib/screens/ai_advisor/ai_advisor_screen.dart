import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final width       = MediaQuery.of(context).size.width;
    final isCompact   = width < 800;
    final form        = ref.watch(advisorFormProvider);
    final adviceAsync = ref.watch(aiAdviceProvider);
    final risk        = _calcRisk(form);

    if (isCompact) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _Header(form: form),
            const SizedBox(height: 14),
            _FormPanel(form: form, risk: risk),
            const SizedBox(height: 14),
            adviceAsync.when(
              data: (a) => a != null ? AdviceResultPanel(advice: a) : const SizedBox.shrink(),
              loading: () => _ShimmerLoading(),
              error: (e, _) => _ErrorWidget(message: e.toString()),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _Header(form: form),
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 430,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _FormPanel(form: form, risk: risk),
            ),
          ),
          // Prominent divider
          Container(
            width: 1,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, spreadRadius: 0)],
            ),
          ),
          Expanded(child: adviceAsync.when(
            data: (a) => a != null ? AdviceResultPanel(advice: a) : _EmptyState(),
            loading: () => _ShimmerLoading(),
            error: (e, _) => Center(child: _ErrorWidget(message: e.toString())),
          )),
        ])),
      ]),
    );
  }

  double _calcRisk(AdvisorFormState f) {
    double s = 0;
    if (f.ndvi < 0.3) s += 30; else if (f.ndvi < 0.5) s += 15;
    if (f.rainfallMm < 50) s += 25; else if (f.rainfallMm < 100) s += 10;
    if (f.tempMaxC > 42) s += 20; else if (f.tempMaxC > 38) s += 10;
    if (f.soilMoisturePct < 20) s += 15;
    if (f.selectedSymptoms.isNotEmpty &&
        !f.selectedSymptoms.contains('no_symptoms')) s += 10;
    return s.clamp(0, 100);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final AdvisorFormState form;
  const _Header({required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width     = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    final district  = AppDistricts.all
        .firstWhere((d) => d['id'] == form.district,
            orElse: () => {'label': form.district})['label']!;
    final crop = AppCrops.all
        .firstWhere((c) => c['id'] == form.crop,
            orElse: () => {'label': form.crop})['label']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: isCompact ? 12 : 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071F09), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(Icons.psychology_rounded,
            color: AppColors.limeGreen, size: 24),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Farm Advisor', style: GoogleFonts.spaceGrotesk(
            color: Colors.white, fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          Text('Powered by Grok AI · Roman Urdu + English',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        ])),
        if (!isCompact) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_rounded, color: Colors.white54, size: 13),
              const SizedBox(width: 5),
              Text('$district · $crop', style: const TextStyle(
                color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form panel (left side)
// ─────────────────────────────────────────────────────────────────────────────
class _FormPanel extends ConsumerWidget {
  final AdvisorFormState form;
  final double risk;
  const _FormPanel({required this.form, required this.risk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(advisorFormProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Farm Conditions ──────────────────────────────────────────
      _sectionLabel('Farm Conditions', Icons.agriculture_rounded),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Dropdown<String>(
          label: 'District',
          value: form.district,
          items: AppDistricts.all
            .map((d) => DropdownMenuItem(value: d['id'], child: Text(d['label']!)))
            .toList(),
          onChanged: n.setDistrict,
        )),
        const SizedBox(width: 10),
        Expanded(child: _Dropdown<String>(
          label: 'Crop',
          value: form.crop,
          items: AppCrops.all
            .map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!)))
            .toList(),
          onChanged: n.setCrop,
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _Dropdown<String>(
          label: 'Season',
          value: form.season,
          items: ['Rabi', 'Kharif']
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
          onChanged: n.setSeason,
        )),
        const SizedBox(width: 10),
        Expanded(child: _FieldSlider(
          label: 'Farm Size',
          icon: Icons.agriculture_rounded,
          value: form.farmSizeAcres,
          min: 1, max: 100, unit: ' ac',
          onChanged: n.setFarmSize,
          colorFn: (_) => AppColors.deepGreen,
        )),
      ]),

      const SizedBox(height: 18),

      // ── Field Readings ───────────────────────────────────────────
      _sectionLabel('Field Readings', Icons.sensors_rounded),
      const SizedBox(height: 10),
      _FieldSlider(
        label: 'NDVI',
        icon: Icons.eco_rounded,
        value: form.ndvi,
        min: 0.0, max: 1.0, unit: '', decimals: 2,
        onChanged: n.setNdvi,
        colorFn: (v) => Color.lerp(AppColors.riskCritical, AppColors.riskGood, v)!,
      ),
      _FieldSlider(
        label: 'Rainfall',
        icon: Icons.water_drop_rounded,
        value: form.rainfallMm,
        min: 0, max: 500, unit: ' mm',
        onChanged: n.setRainfall,
        colorFn: (v) {
          if (v < 50)  return AppColors.riskCritical;
          if (v < 100) return AppColors.riskWatch;
          if (v < 300) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),
      _FieldSlider(
        label: 'Max Temp',
        icon: Icons.thermostat_rounded,
        value: form.tempMaxC,
        min: 20, max: 50, unit: '°C',
        onChanged: n.setTempMax,
        colorFn: (v) {
          if (v < 30) return AppColors.riskGood;
          if (v < 38) return AppColors.riskAbove;
          if (v < 43) return AppColors.riskWatch;
          return AppColors.riskCritical;
        },
      ),
      _FieldSlider(
        label: 'Soil Moisture',
        icon: Icons.opacity_rounded,
        value: form.soilMoisturePct,
        min: 10, max: 80, unit: '%',
        onChanged: n.setSoilMoisture,
        colorFn: (v) {
          if (v < 20) return AppColors.riskCritical;
          if (v < 30) return AppColors.riskWatch;
          if (v < 60) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),
      _FieldSlider(
        label: 'Water Table',
        icon: Icons.water_rounded,
        value: form.waterTableM,
        min: 1, max: 20, unit: ' m',
        onChanged: n.setWaterTable,
        colorFn: (v) {
          if (v < 3)  return AppColors.riskWatch;
          if (v < 12) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),

      const SizedBox(height: 16),

      // ── Symptoms ─────────────────────────────────────────────────
      Consumer(builder: (ctx, ref, _) {
        final f = ref.watch(advisorFormProvider);
        return SymptomSelector(
          selected: f.selectedSymptoms,
          onToggle: ref.read(advisorFormProvider.notifier).toggleSymptom,
        );
      }),

      const SizedBox(height: 18),

      // ── Live Risk Score ──────────────────────────────────────────
      RiskMeterWidget(riskScore: risk),

      const SizedBox(height: 14),

      // ── Field Condition Summary ──────────────────────────────────
      _ConditionSummary(form: form),

      const SizedBox(height: 18),

      // ── Analyze Button ───────────────────────────────────────────
      Consumer(builder: (ctx, ref, _) {
        final busy = ref.watch(aiAdviceProvider) is AsyncLoading;
        return _AnalyzeButton(busy: busy);
      }),

      const SizedBox(height: 8),
    ]);
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(children: [
      Icon(icon, size: 15, color: AppColors.deepGreen),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.headingSmall),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Analyze button
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyzeButton extends ConsumerWidget {
  final bool busy;
  const _AnalyzeButton({required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget button = SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(13),
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: busy
                ? [AppColors.grey400, AppColors.grey400]
                : [AppColors.amber, const Color(0xFFE65100)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: busy ? [] : [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: 0.35),
                blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            splashColor: Colors.white24,
            highlightColor: Colors.white12,
            onTap: busy ? null : () => ref.read(aiAdviceProvider.notifier).analyze(),
            child: Center(child: busy
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 12),
                  Text('Analyzing...', style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ])
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Analyze with AI', style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
            ),
          ),
        ),
      ),
    );

    // Add shimmer effect while loading
    if (busy) {
      return button
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1300.ms, color: Colors.white30);
    }
    return button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom gradient-colored slider
// ─────────────────────────────────────────────────────────────────────────────
class _FieldSlider extends StatelessWidget {
  final String label, unit;
  final IconData icon;
  final double value, min, max;
  final int decimals;
  final ValueChanged<double> onChanged;
  final Color Function(double) colorFn;

  const _FieldSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    required this.colorFn,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color       = colorFn(value);
    final displayVal  = decimals == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimals);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: AppColors.grey600),
          const SizedBox(width: 5),
          Expanded(child: Text(label,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          // Animated value badge — bounces when displayed text changes
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$displayVal$unit',
              key: ValueKey('$label-$displayVal'),
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
            )
            .animate(key: ValueKey('$label-$displayVal'))
            .scaleXY(begin: 0.85, end: 1.0, duration: 160.ms, curve: Curves.easeOut),
          ),
        ]),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: color,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.grey200),
          boxShadow: AppShadows.card,
        ),
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: (v) => onChanged(v as T),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: AppTextStyles.bodyMedium,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
            size: 18, color: AppColors.grey600),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field condition summary card
// ─────────────────────────────────────────────────────────────────────────────
class _ConditionSummary extends StatelessWidget {
  final AdvisorFormState form;
  const _ConditionSummary({required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.14)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.dashboard_outlined,
            size: 14, color: AppColors.deepGreen),
          const SizedBox(width: 5),
          Text('Field Summary',
            style: AppTextStyles.label.copyWith(color: AppColors.deepGreen)),
        ]),
        const SizedBox(height: 9),
        Wrap(spacing: 7, runSpacing: 6, children: [
          _chip('NDVI', form.ndvi.toStringAsFixed(2), AppColors.limeGreen),
          _chip('Rain', '${form.rainfallMm.toStringAsFixed(0)}mm', AppColors.skyBlue),
          _chip('Temp', '${form.tempMaxC.toStringAsFixed(0)}°C', AppColors.burntOrange),
          _chip('Moisture', '${form.soilMoisturePct.toStringAsFixed(0)}%',
            AppColors.deepGreen),
          _chip('Water', '${form.waterTableM.toStringAsFixed(0)}m', AppColors.skyBlue),
          _chip('Farm', '${form.farmSizeAcres.toStringAsFixed(0)} ac',
            AppColors.limeGreen),
          if (form.selectedSymptoms.isNotEmpty &&
              !form.selectedSymptoms.contains('no_symptoms'))
            _chip('Symptoms', '${form.selectedSymptoms.length}',
              AppColors.burntOrange),
        ]),
      ]),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: TextStyle(
          fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(
          fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / loading / error states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.09),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.psychology_rounded,
            color: AppColors.amber, size: 48)),
        const SizedBox(height: 20),
        Text('Fill in farm conditions',
          style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Text('Then tap Analyze with AI',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center),
      ],
    ));
  }
}

class _ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _block(80),
        const SizedBox(height: 12),
        _block(60),
        const SizedBox(height: 12),
        _block(140),
        const SizedBox(height: 12),
        _block(100),
      ]),
    );
  }

  Widget _block(double h) {
    return Container(
      height: h,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(12)),
    )
    .animate(onPlay: (c) => c.repeat())
    .shimmer(duration: 1400.ms, color: Colors.white70);
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB71C1C).withValues(alpha: 0.28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, color: Color(0xFFB71C1C), size: 32),
        const SizedBox(height: 12),
        Text('Could not get advice',
          style: AppTextStyles.headingSmall.copyWith(
            color: const Color(0xFFB71C1C))),
        const SizedBox(height: 6),
        Text(message,
          style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('Make sure the backend is running on localhost:8000',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center),
      ]),
    );
  }
}
