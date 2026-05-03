import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/constants.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});
  @override
  State<CropCalendarScreen> createState() => _State();
}

class _State extends State<CropCalendarScreen> {
  String _crop = 'wheat';
  final _data = {
    'wheat': [
      [
        'Land Preparation',
        'Oct 1-15',
        'Deep plough 2-3 times. Add DAP 1 bag/acre. Level field for uniform irrigation.',
        'amber',
        15
      ],
      [
        'Sowing',
        'Oct 16 - Nov 15',
        'Sow certified seed at 50kg/acre. Row spacing 22cm, depth 5cm. Varieties: Punjab-2011, Faisalabad-2008.',
        'lime',
        30
      ],
      [
        'First Irrigation',
        'Nov 20-25',
        'Apply first irrigation 3-4 weeks after sowing. Do not over-irrigate.',
        'blue',
        5
      ],
      [
        'Fertilizer',
        'Dec 1-15',
        'Apply 1 bag Urea/acre with 2nd irrigation. Watch for nitrogen deficiency (yellowing).',
        'green',
        15
      ],
      [
        'Disease Watch',
        'Jan 1 - Feb 28',
        'Monitor weekly for yellow rust. Spray Topsin-M 70WP at 250g/acre if rust appears.',
        'orange',
        59
      ],
      [
        'Heading',
        'Mar 1-20',
        'Critical water stage. Apply 3rd irrigation at heading. Protect from frost.',
        'amber',
        20
      ],
      [
        'Grain Filling',
        'Mar 21 - Apr 10',
        'Apply final irrigation. Stop pesticides 3 weeks before harvest.',
        'lime',
        20
      ],
      [
        'Harvest',
        'Apr 15-30',
        'Harvest at 12-14% moisture. Expected yield: 2.0-2.8 t/acre.',
        'green',
        15
      ],
    ],
    'rice': [
      [
        'Nursery',
        'May 15 - Jun 1',
        'Prepare beds. Soak seeds 24hr. Keep moist but not waterlogged.',
        'lime',
        17
      ],
      [
        'Transplanting',
        'Jun 15 - Jul 10',
        'Transplant 30-35 day seedlings. Row spacing 20x15cm. Flood fields 2-3cm.',
        'blue',
        25
      ],
      [
        'Water Management',
        'Jul 1 - Aug 15',
        'Apply Urea in 3 splits. Maintain 5-7cm water depth throughout.',
        'blue',
        45
      ],
      [
        'Disease Control',
        'Jul 15 - Sep 1',
        'Watch for blast disease. Apply Beam (Tricyclazole) 200g/acre.',
        'orange',
        47
      ],
      [
        'Harvest',
        'Sep 15 - Oct 15',
        'Harvest when 80% grains golden. Expected: 1.5-2.2 t/acre.',
        'green',
        30
      ],
    ],
    'cotton': [
      [
        'Land Prep',
        'Apr 1-30',
        'Deep plough. Apply FYM 5 tons/acre. Needs well-drained loamy soil.',
        'amber',
        30
      ],
      [
        'Sowing',
        'May 1-31',
        'Sow 5kg seed/acre. Row spacing 75cm. Soil temp must be 25C+.',
        'lime',
        31
      ],
      [
        'Pest Management',
        'Jun 15 - Sep 30',
        'Scout weekly for whitefly and bollworm. Use Confidor when needed.',
        'orange',
        107
      ],
      [
        'Boll Development',
        'Aug 1 - Sep 30',
        'Irrigate every 10 days. Apply SOP at boll formation.',
        'amber',
        60
      ],
      [
        'Picking',
        'Sep 15 - Nov 30',
        'First pick when 60% bolls open. Expected: 1.5-2.2 t/acre.',
        'green',
        76
      ],
    ],
    'sugarcane': [
      [
        'Planting',
        'Nov 1 - Dec 31',
        'Plant setts in furrows 90cm apart. 7-8 tons setts/acre. Irrigate immediately.',
        'lime',
        61
      ],
      [
        'Early Growth',
        'Jan 1 - Mar 31',
        'Germination 3-4 weeks. Apply Atrazine for weeds. First fertilizer at 45 days.',
        'blue',
        90
      ],
      [
        'Grand Growth',
        'Apr 1 - Aug 31',
        'Max water demand. Irrigate every 10-15 days. Apply 3 bags Urea total.',
        'green',
        153
      ],
      [
        'Harvest',
        'Nov 1 - Jan 31',
        'Stop irrigation 6 weeks before harvest. Brix must be 18%+. Expected: 25-35 t/acre.',
        'amber',
        92
      ],
    ],
    'maize': [
      [
        'Sowing',
        'Apr 1-30',
        'Sow hybrid seed 8-10kg/acre. Row spacing 75cm. Soil temp above 15C.',
        'lime',
        30
      ],
      [
        'Vegetative',
        'May 1 - Jun 15',
        'Thin at V3 stage. Apply Urea at knee height. Irrigate every 8-10 days.',
        'blue',
        45
      ],
      [
        'Tasseling',
        'Jun 16 - Jul 15',
        'Most critical water period. Apply 2nd Urea at tasseling. Scout for armyworm.',
        'orange',
        29
      ],
      [
        'Grain Fill',
        'Jul 16 - Aug 15',
        'Reduce irrigation. Stop nitrogen. Monitor for ear rots.',
        'amber',
        31
      ],
      [
        'Harvest',
        'Aug 16 - Sep 15',
        'Harvest at 20-25% moisture. Dry to 13% before storage. Expected: 2.0-3.0 t/acre.',
        'green',
        30
      ],
    ],
  };
  Color _c(String k) {
    switch (k) {
      case 'lime':
        return AppColors.limeGreen;
      case 'blue':
        return AppColors.skyBlue;
      case 'orange':
        return AppColors.burntOrange;
      case 'amber':
        return AppColors.amber;
      default:
        return AppColors.deepGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = _data[_crop] ?? [];
    return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Column(children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.72))),
                boxShadow: AppShadows.card,
              ),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    Text('Crop Calendar', style: AppTextStyles.headingMedium),
                    const SizedBox(width: 24),
                    ...AppCrops.all.map((c) {
                      final sel = _crop == c['id'];
                      return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                              label: Text(c['label']!),
                              selected: sel,
                              onSelected: (_) =>
                                  setState(() => _crop = c['id']!),
                              selectedColor: AppColors.deepGreen,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                  color:
                                      sel ? Colors.white : AppColors.darkText,
                                  fontSize: 13),
                              backgroundColor: AppColors.grey100,
                              side: BorderSide.none));
                    }),
                  ]))),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(children: [
                            Positioned.fill(
                              child: Image.network(
                                'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1400&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  AppColors.deepGreen.withValues(alpha: 0.88),
                                  AppColors.deepGreen.withValues(alpha: 0.44),
                                ]),
                              ),
                              child: Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.24)),
                                  ),
                                  child: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.white,
                                      size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          AppCrops.all.firstWhere((c) =>
                                                  c['id'] == _crop)['label']! +
                                              ' Growing Calendar',
                                          style: AppTextStyles.headingSmall
                                              .copyWith(color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'Tap any stage card for detailed instructions',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(color: Colors.white70)),
                                    ])),
                              ]),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        Text('Growing Stages',
                            style: AppTextStyles.headingMedium),
                        const SizedBox(height: 16),
                        ...stages.asMap().entries.map((e) {
                          final i = e.key;
                          final s = e.value;
                          final color = _c(s[3] as String);
                          return Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: IntrinsicHeight(
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        SizedBox(
                                            width: 60,
                                            child: Column(children: [
                                              Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                      color: color.withValues(
                                                          alpha: 0.12),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: color,
                                                          width: 2)),
                                                  child: Icon(
                                                      Icons.agriculture_rounded,
                                                      color: color,
                                                      size: 20)),
                                              if (i < stages.length - 1)
                                                Expanded(
                                                    child: Container(
                                                        width: 2,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 4),
                                                        color: color.withValues(
                                                            alpha: 0.3))),
                                            ])),
                                        Expanded(
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12, bottom: 24),
                                                child: _SC(
                                                    name: s[0] as String,
                                                    dates: s[1] as String,
                                                    instructions:
                                                        s[2] as String,
                                                    color: color,
                                                    days: s[4] as int))),
                                      ])))
                              .animate(delay: Duration(milliseconds: i * 80))
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.1, end: 0);
                        }),
                      ]))),
        ]));
  }
}

class _SC extends StatefulWidget {
  final String name, dates, instructions;
  final Color color;
  final int days;
  const _SC(
      {required this.name,
      required this.dates,
      required this.instructions,
      required this.color,
      required this.days});
  @override
  State<_SC> createState() => _SCS();
}

class _SCS extends State<_SC> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
            gradient: AppGradients.cardSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _open ? widget.color : AppColors.grey200,
                width: _open ? 2 : 1),
            boxShadow: AppShadows.card),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.name,
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: widget.color),
                    const SizedBox(width: 4),
                    Text(widget.dates,
                        style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.grey600),
                    const SizedBox(width: 4),
                    Text(widget.days.toString() + ' days',
                        style: AppTextStyles.bodySmall),
                  ]),
                ])),
            Icon(
                _open
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey600),
          ]),
          if (_open) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(widget.instructions,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
          ],
        ]),
      ),
    );
  }
}
