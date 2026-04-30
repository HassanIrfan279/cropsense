import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/constants.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});
  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  String _selectedCrop = 'wheat';

  final _calendar = {
    'wheat': [
      _CropStage('Land Preparation', 'Oct 1 - Oct 15',
          'Deep plough 2-3 times. Add DAP fertilizer 1 bag/acre before last plough. Ensure field is levelled for uniform irrigation.',
          Icons.agriculture_rounded, AppColors.amber, 15),
      _CropStage('Sowing', 'Oct 16 - Nov 15',
          'Sow certified wheat seed at 50kg/acre. Row spacing 22cm. Seed depth 5cm. Use approved varieties: Punjab-2011, Faisalabad-2008, NARC-2009.',
          Icons.grass_rounded, AppColors.limeGreen, 30),
      _CropStage('First Irrigation', 'Nov 20 - Nov 25',
          'Apply first irrigation 3-4 weeks after sowing. Do not over-irrigate — causes root rot. Check soil moisture before irrigating.',
          Icons.water_drop_rounded, AppColors.skyBlue, 5),
      _CropStage('Fertilizer Application', 'Dec 1 - Dec 15',
          'Apply 1 bag Urea per acre with 2nd irrigation. Split application improves uptake. Monitor for nitrogen deficiency (yellowing leaves).',
          Icons.eco_rounded, AppColors.deepGreen, 15),
      _CropStage('Disease Monitoring', 'Jan 1 - Feb 28',
          'Monitor weekly for yellow rust, leaf rust, and powdery mildew. If rust appears spray Topsin-M 70WP at 250g/acre. Contact agriculture officer if 10%+ leaves affected.',
          Icons.biotech_rounded, AppColors.burntOrange, 59),
      _CropStage('Heading Stage', 'Mar 1 - Mar 20',
          'Critical stage — ensure adequate water. Apply 3rd irrigation at heading. Protect from late frost. Check for aphid infestation.',
          Icons.grain_rounded, AppColors.amber, 20),
      _CropStage('Grain Filling', 'Mar 21 - Apr 10',
          'Apply 4th and final irrigation. Stop all pesticide applications 3 weeks before harvest. Monitor grain moisture content daily.',
          Icons.star_rounded, AppColors.limeGreen, 20),
      _CropStage('Harvest', 'Apr 15 - Apr 30',
          'Harvest when grain moisture is 12-14%. Use combine harvester if available. Dry grain to 10% moisture before storage. Expected yield: 2.0-2.8 t/acre.',
          Icons.content_cut_rounded, AppColors.deepGreen, 15),
    ],
    'rice': [
      _CropStage('Nursery Preparation', 'May 15 - Jun 1',
          'Prepare nursery beds. Soak seeds 24 hours before sowing. Sow at 40kg/acre equivalent in nursery. Keep nursery moist but not waterlogged.',
          Icons.grass_rounded, AppColors.limeGreen, 17),
      _CropStage('Transplanting', 'Jun 15 - Jul 10',
          'Transplant 30-35 day old seedlings. Row spacing 20x15cm. 2-3 seedlings per hill. Flood fields 2-3cm deep before transplanting.',
          Icons.agriculture_rounded, AppColors.skyBlue, 25),
      _CropStage('Fertilizer and Water', 'Jul 1 - Aug 15',
          'Apply Urea in 3 splits. Maintain 5-7cm water depth throughout growing season. Drain field 2 weeks before harvest for mechanized harvesting.',
          Icons.water_drop_rounded, AppColors.skyBlue, 45),
      _CropStage('Disease Control', 'Jul 15 - Sep 1',
          'Watch for blast disease, sheath blight, and brown planthopper. Apply Beam (Tricyclazole) for blast at 200g/acre. Scout weekly after heading.',
          Icons.biotech_rounded, AppColors.burntOrange, 47),
      _CropStage('Harvest', 'Sep 15 - Oct 15',
          'Harvest when 80% grains are golden yellow. Drain field 7-10 days before harvest. Expected yield: 1.5-2.2 t/acre for Basmati varieties.',
          Icons.content_cut_rounded, AppColors.deepGreen, 30),
    ],
    'cotton': [
      _CropStage('Land Preparation', 'Apr 1 - Apr 30',
          'Deep plough in winter. Final seedbed preparation in April. Apply FYM 5 tons/acre. Cotton needs well-drained loamy soil.',
          Icons.agriculture_rounded, AppColors.amber, 30),
      _CropStage('Sowing', 'May 1 - May 31',
          'Sow delinted certified seed at 5kg/acre. Row spacing 75cm, plant spacing 30cm. Ideal soil temperature 25C or above. Do not sow in cold wet soil.',
          Icons.grass_rounded, AppColors.limeGreen, 31),
      _CropStage('Thinning and Earthing', 'Jun 1 - Jun 20',
          'Thin to 1 plant per hill when 15cm tall. Earth up plants for support and weed control. Apply 1st Urea dose.',
          Icons.content_cut_rounded, AppColors.skyBlue, 20),
      _CropStage('Pest Management', 'Jun 15 - Sep 30',
          'Scout for whitefly, thrips, bollworm weekly. Use IPM approach — natural enemies first. If threshold exceeded use Confidor or Karate. Pink bollworm is critical threat.',
          Icons.bug_report_rounded, AppColors.burntOrange, 107),
      _CropStage('Boll Development', 'Aug 1 - Sep 30',
          'Critical water stage — irrigate every 10 days. Apply potash (SOP) at boll formation. Avoid excessive nitrogen — reduces fiber quality.',
          Icons.grain_rounded, AppColors.amber, 60),
      _CropStage('Picking', 'Sep 15 - Nov 30',
          'First picking when 60% bolls open. Do 3-4 pickings total. Store separately to maintain grade. Expected yield: 1.5-2.2 t/acre seed cotton.',
          Icons.star_rounded, AppColors.deepGreen, 76),
    ],
    'sugarcane': [
      _CropStage('Sett Preparation', 'Oct 15 - Nov 15',
          'Select disease-free setts from 8-10 month crop. Cut into 2-3 eye pieces. Treat with Emisan 6 fungicide solution before planting.',
          Icons.agriculture_rounded, AppColors.amber, 31),
      _CropStage('Planting', 'Nov 1 - Dec 31',
          'Plant in furrows 90cm apart at depth 8-10cm. Use 7-8 tons setts/acre. Cover with soil and press firmly. Irrigate immediately after planting.',
          Icons.grass_rounded, AppColors.limeGreen, 61),
      _CropStage('Early Growth', 'Jan 1 - Mar 31',
          'Germination takes 3-4 weeks. Gap filling at 6 weeks. Apply Atrazine herbicide for weed control. First fertilizer dose at 45 days.',
          Icons.eco_rounded, AppColors.skyBlue, 90),
      _CropStage('Grand Growth', 'Apr 1 - Aug 31',
          'Maximum water and nutrient demand. Irrigate every 10-15 days. Apply 3 bags Urea plus 1 bag SOP total. Earth up at 1m height for lodging prevention.',
          Icons.trending_up_rounded, AppColors.deepGreen, 153),
      _CropStage('Maturity and Harvest', 'Nov 1 - Jan 31',
          'Stop irrigation 6 weeks before harvest. Brix reading should be 18% or above. Harvest at 12-14 months for best sucrose. Expected yield: 25-35 t/acre.',
          Icons.content_cut_rounded, AppColors.amber, 92),
    ],
    'maize': [
      _CropStage('Land Preparation', 'Mar 1 - Mar 31',
          'Plough 2-3 times. Apply DAP at 1 bag/acre before sowing. Maize needs loose, well-drained soil. pH 5.8-7.0 ideal.',
          Icons.agriculture_rounded, AppColors.amber, 31),
      _CropStage('Sowing', 'Apr 1 - Apr 30',
          'Sow hybrid seed at 8-10kg/acre. Row spacing 75cm, plant spacing 20cm. Depth 3-5cm. Ensure soil temperature is above 15C.',
          Icons.grass_rounded, AppColors.limeGreen, 30),
      _CropStage('Vegetative Growth', 'May 1 - Jun 15',
          'Thin to final stand at V3 stage. Apply 1st Urea dose at knee height. Weed control critical in first 6 weeks. Irrigate every 8-10 days.',
          Icons.eco_rounded, AppColors.skyBlue, 45),
      _CropStage('Tasseling and Silking', 'Jun 16 - Jul 15',
          'Most critical water period — do NOT let crop wilt. Apply 2nd Urea dose at tasseling. Scout for fall armyworm — spray Coragen if found.',
          Icons.warning_rounded, AppColors.burntOrange, 29),
      _CropStage('Grain Filling', 'Jul 16 - Aug 15',
          'Reduce irrigation frequency. Stop nitrogen application. Monitor for ear rots. Check moisture content approaching harvest.',
          Icons.grain_rounded, AppColors.amber, 31),
      _CropStage('Harvest', 'Aug 16 - Sep 15',
          'Harvest when husks are dry and grain moisture is 20-25%. Dry to 13% before storage. Expected yield: 2.0-3.0 t/acre for hybrid varieties.',
          Icons.content_cut_rounded, AppColors.deepGreen, 30),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final stages = _calendar[_selectedCrop] ?? [];
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _buildHeader(isCompact),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeasonInfo(),
                  const SizedBox(height: 24),
                  Text('Growing Stages', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 4),
                  Text('Tap any stage for detailed instructions',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 16),
                  ...stages.asMap().entries.map((entry) =>
                      _buildStageCard(entry.value, entry.key, stages.length)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('Crop Calendar', style: AppTextStyles.headingMedium),
            const SizedBox(width: 24),
            ...AppCrops.all.map((crop) {
              final selected = _selectedCrop == crop['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(crop['label']!),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCrop = crop['id']!),
                  selectedColor: AppColors.deepGreen,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.darkText,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.grey100,
                  side: BorderSide.none,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonInfo() {
    final cropInfo = {
      'wheat': 'Rabi Season (Oct - Apr) · 180-200 days · 50kg seed/acre',
      'rice': 'Kharif Season (Jun - Oct) · 120-150 days · 40kg seed/acre',
      'cotton': 'Kharif Season (May - Nov) · 170-200 days · 5kg seed/acre',
      'sugarcane': 'Annual Crop (Nov - Nov) · 12-14 months · 7-8 tons setts/acre',
      'maize': 'Spring/Kharif (Apr - Sep) · 100-120 days · 8-10kg seed/acre',
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_month_rounded,
            color: Colors.white, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppCrops.all.firstWhere(
                    (c) => c['id'] == _selectedCrop)['label']! +
                    ' — Pakistan Growing Calendar',
                style: AppTextStyles.headingSmall.copyWith(
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                cropInfo[_selectedCrop] ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStageCard(
      _CropStage stage, int index, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: stage.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: stage.color, width: 2),
                    ),
                    child: Icon(stage.icon, color: stage.color, size: 20),
                  ),
                  if (index < total - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: stage.color.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 24),
                child: _StageCard(stage: stage, index: index),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class _StageCard extends StatefulWidget {
  final _CropStage stage;
  final int index;
  const _StageCard({required this.stage, required this.index});
  @override
  State<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<_StageCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? widget.stage.color
                : AppColors.grey200,
            width: _expanded ? 2 : 1,
          ),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.stage.name,
                        style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: widget.stage.color),
                      const SizedBox(width: 4),
                      Text(widget.stage.dateRange,
                          style: TextStyle(
                              fontSize: 12,
                              color: widget.stage.color,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.grey600),
                      const SizedBox(width: 4),
                      Text('${widget.stage.durationDays} days',
                          style: AppTextStyles.bodySmall),
                    ]),
                  ],
                ),
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey600,
              ),
            ]),
            if (_expanded) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(widget.stage.instructions,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CropStage {
  final String name;
  final String dateRange;
  final String instructions;
  final IconData icon;
  final Color color;
  final int durationDays;

  const _CropStage(this.name, this.dateRange, this.instructions,
      this.icon, this.color, this.durationDays);
}