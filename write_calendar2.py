import os
bs = chr(92)
nl = chr(10)
q = chr(39)
dl = chr(36)
lt = chr(60)
gt = chr(62)
lb = chr(123)
rb = chr(125)

# Build the duration text line safely
duration_text = f"Text({q}{dl}{lb}widget.stage.durationDays{rb} days{q},"

path = f'flutter_app{bs}lib{bs}screens{bs}crop_calendar{bs}crop_calendar_screen.dart'
os.makedirs(os.path.dirname(path), exist_ok=True)

lines = []
lines.append(f"import {q}package:flutter/material.dart{q};")
lines.append(f"import {q}package:flutter_animate/flutter_animate.dart{q};")
lines.append(f"import {q}package:cropsense/core/theme.dart{q};")
lines.append(f"import {q}package:cropsense/core/constants.dart{q};")
lines.append("")
lines.append("class CropCalendarScreen extends StatefulWidget {")
lines.append("  const CropCalendarScreen({super.key});")
lines.append("  @override")
lines.append(f"  State{lt}CropCalendarScreen{gt} createState() => _CropCalendarScreenState();")
lines.append("}")
lines.append("")
lines.append(f"class _CropCalendarScreenState extends State{lt}CropCalendarScreen{gt} {{")
lines.append(f"  String _selectedCrop = {q}wheat{q};")
lines.append("")
lines.append(f"  final _calendar = {{")

# Wheat stages
lines.append(f"    {q}wheat{q}: [")
stages_wheat = [
    ("Land Preparation", "Oct 1 - Oct 15", "Deep plough 2-3 times. Add DAP fertilizer 1 bag/acre before last plough. Ensure field is levelled for uniform irrigation.", "Icons.agriculture_rounded", "AppColors.amber", 15),
    ("Sowing", "Oct 16 - Nov 15", "Sow certified wheat seed at 50kg/acre. Row spacing 22cm. Seed depth 5cm. Use approved varieties: Punjab-2011, Faisalabad-2008, NARC-2009.", "Icons.grass_rounded", "AppColors.limeGreen", 30),
    ("First Irrigation", "Nov 20 - Nov 25", "Apply first irrigation 3-4 weeks after sowing. Do not over-irrigate — causes root rot. Check soil moisture before irrigating.", "Icons.water_drop_rounded", "AppColors.skyBlue", 5),
    ("Fertilizer Application", "Dec 1 - Dec 15", "Apply 1 bag Urea per acre with 2nd irrigation. Split application improves uptake. Monitor for nitrogen deficiency (yellowing leaves).", "Icons.eco_rounded", "AppColors.deepGreen", 15),
    ("Disease Monitoring", "Jan 1 - Feb 28", "Monitor weekly for yellow rust, leaf rust, and powdery mildew. If rust appears spray Topsin-M 70WP at 250g/acre. Contact agriculture officer if 10%+ leaves affected.", "Icons.biotech_rounded", "AppColors.burntOrange", 59),
    ("Heading Stage", "Mar 1 - Mar 20", "Critical stage — ensure adequate water. Apply 3rd irrigation at heading. Protect from late frost. Check for aphid infestation.", "Icons.grain_rounded", "AppColors.amber", 20),
    ("Grain Filling", "Mar 21 - Apr 10", "Apply 4th and final irrigation. Stop all pesticide applications 3 weeks before harvest. Monitor grain moisture content daily.", "Icons.star_rounded", "AppColors.limeGreen", 20),
    ("Harvest", "Apr 15 - Apr 30", "Harvest when grain moisture is 12-14%. Use combine harvester if available. Dry grain to 10% moisture before storage. Expected yield: 2.0-2.8 t/acre.", "Icons.content_cut_rounded", "AppColors.deepGreen", 15),
]
for name, dates, instructions, icon, color, days in stages_wheat:
    lines.append(f"      _CropStage({q}{name}{q}, {q}{dates}{q},")
    lines.append(f"          {q}{instructions}{q},")
    lines.append(f"          {icon}, {color}, {days}),")
lines.append("    ],")

# Rice stages
lines.append(f"    {q}rice{q}: [")
stages_rice = [
    ("Nursery Preparation", "May 15 - Jun 1", "Prepare nursery beds. Soak seeds 24 hours before sowing. Sow at 40kg/acre equivalent in nursery. Keep nursery moist but not waterlogged.", "Icons.grass_rounded", "AppColors.limeGreen", 17),
    ("Transplanting", "Jun 15 - Jul 10", "Transplant 30-35 day old seedlings. Row spacing 20x15cm. 2-3 seedlings per hill. Flood fields 2-3cm deep before transplanting.", "Icons.agriculture_rounded", "AppColors.skyBlue", 25),
    ("Fertilizer and Water", "Jul 1 - Aug 15", "Apply Urea in 3 splits. Maintain 5-7cm water depth throughout growing season. Drain field 2 weeks before harvest for mechanized harvesting.", "Icons.water_drop_rounded", "AppColors.skyBlue", 45),
    ("Disease Control", "Jul 15 - Sep 1", "Watch for blast disease, sheath blight, and brown planthopper. Apply Beam (Tricyclazole) for blast at 200g/acre. Scout weekly after heading.", "Icons.biotech_rounded", "AppColors.burntOrange", 47),
    ("Harvest", "Sep 15 - Oct 15", "Harvest when 80% grains are golden yellow. Drain field 7-10 days before harvest. Expected yield: 1.5-2.2 t/acre for Basmati varieties.", "Icons.content_cut_rounded", "AppColors.deepGreen", 30),
]
for name, dates, instructions, icon, color, days in stages_rice:
    lines.append(f"      _CropStage({q}{name}{q}, {q}{dates}{q},")
    lines.append(f"          {q}{instructions}{q},")
    lines.append(f"          {icon}, {color}, {days}),")
lines.append("    ],")

# Cotton stages
lines.append(f"    {q}cotton{q}: [")
stages_cotton = [
    ("Land Preparation", "Apr 1 - Apr 30", "Deep plough in winter. Final seedbed preparation in April. Apply FYM 5 tons/acre. Cotton needs well-drained loamy soil.", "Icons.agriculture_rounded", "AppColors.amber", 30),
    ("Sowing", "May 1 - May 31", "Sow delinted certified seed at 5kg/acre. Row spacing 75cm, plant spacing 30cm. Ideal soil temperature 25C or above. Do not sow in cold wet soil.", "Icons.grass_rounded", "AppColors.limeGreen", 31),
    ("Thinning and Earthing", "Jun 1 - Jun 20", "Thin to 1 plant per hill when 15cm tall. Earth up plants for support and weed control. Apply 1st Urea dose.", "Icons.content_cut_rounded", "AppColors.skyBlue", 20),
    ("Pest Management", "Jun 15 - Sep 30", "Scout for whitefly, thrips, bollworm weekly. Use IPM approach — natural enemies first. If threshold exceeded use Confidor or Karate. Pink bollworm is critical threat.", "Icons.bug_report_rounded", "AppColors.burntOrange", 107),
    ("Boll Development", "Aug 1 - Sep 30", "Critical water stage — irrigate every 10 days. Apply potash (SOP) at boll formation. Avoid excessive nitrogen — reduces fiber quality.", "Icons.grain_rounded", "AppColors.amber", 60),
    ("Picking", "Sep 15 - Nov 30", "First picking when 60% bolls open. Do 3-4 pickings total. Store separately to maintain grade. Expected yield: 1.5-2.2 t/acre seed cotton.", "Icons.star_rounded", "AppColors.deepGreen", 76),
]
for name, dates, instructions, icon, color, days in stages_cotton:
    lines.append(f"      _CropStage({q}{name}{q}, {q}{dates}{q},")
    lines.append(f"          {q}{instructions}{q},")
    lines.append(f"          {icon}, {color}, {days}),")
lines.append("    ],")

# Sugarcane stages
lines.append(f"    {q}sugarcane{q}: [")
stages_sugarcane = [
    ("Sett Preparation", "Oct 15 - Nov 15", "Select disease-free setts from 8-10 month crop. Cut into 2-3 eye pieces. Treat with Emisan 6 fungicide solution before planting.", "Icons.agriculture_rounded", "AppColors.amber", 31),
    ("Planting", "Nov 1 - Dec 31", "Plant in furrows 90cm apart at depth 8-10cm. Use 7-8 tons setts/acre. Cover with soil and press firmly. Irrigate immediately after planting.", "Icons.grass_rounded", "AppColors.limeGreen", 61),
    ("Early Growth", "Jan 1 - Mar 31", "Germination takes 3-4 weeks. Gap filling at 6 weeks. Apply Atrazine herbicide for weed control. First fertilizer dose at 45 days.", "Icons.eco_rounded", "AppColors.skyBlue", 90),
    ("Grand Growth", "Apr 1 - Aug 31", "Maximum water and nutrient demand. Irrigate every 10-15 days. Apply 3 bags Urea plus 1 bag SOP total. Earth up at 1m height for lodging prevention.", "Icons.trending_up_rounded", "AppColors.deepGreen", 153),
    ("Maturity and Harvest", "Nov 1 - Jan 31", "Stop irrigation 6 weeks before harvest. Brix reading should be 18% or above. Harvest at 12-14 months for best sucrose. Expected yield: 25-35 t/acre.", "Icons.content_cut_rounded", "AppColors.amber", 92),
]
for name, dates, instructions, icon, color, days in stages_sugarcane:
    lines.append(f"      _CropStage({q}{name}{q}, {q}{dates}{q},")
    lines.append(f"          {q}{instructions}{q},")
    lines.append(f"          {icon}, {color}, {days}),")
lines.append("    ],")

# Maize stages
lines.append(f"    {q}maize{q}: [")
stages_maize = [
    ("Land Preparation", "Mar 1 - Mar 31", "Plough 2-3 times. Apply DAP at 1 bag/acre before sowing. Maize needs loose, well-drained soil. pH 5.8-7.0 ideal.", "Icons.agriculture_rounded", "AppColors.amber", 31),
    ("Sowing", "Apr 1 - Apr 30", "Sow hybrid seed at 8-10kg/acre. Row spacing 75cm, plant spacing 20cm. Depth 3-5cm. Ensure soil temperature is above 15C.", "Icons.grass_rounded", "AppColors.limeGreen", 30),
    ("Vegetative Growth", "May 1 - Jun 15", "Thin to final stand at V3 stage. Apply 1st Urea dose at knee height. Weed control critical in first 6 weeks. Irrigate every 8-10 days.", "Icons.eco_rounded", "AppColors.skyBlue", 45),
    ("Tasseling and Silking", "Jun 16 - Jul 15", "Most critical water period — do NOT let crop wilt. Apply 2nd Urea dose at tasseling. Scout for fall armyworm — spray Coragen if found.", "Icons.warning_rounded", "AppColors.burntOrange", 29),
    ("Grain Filling", "Jul 16 - Aug 15", "Reduce irrigation frequency. Stop nitrogen application. Monitor for ear rots. Check moisture content approaching harvest.", "Icons.grain_rounded", "AppColors.amber", 31),
    ("Harvest", "Aug 16 - Sep 15", "Harvest when husks are dry and grain moisture is 20-25%. Dry to 13% before storage. Expected yield: 2.0-3.0 t/acre for hybrid varieties.", "Icons.content_cut_rounded", "AppColors.deepGreen", 30),
]
for name, dates, instructions, icon, color, days in stages_maize:
    lines.append(f"      _CropStage({q}{name}{q}, {q}{dates}{q},")
    lines.append(f"          {q}{instructions}{q},")
    lines.append(f"          {icon}, {color}, {days}),")
lines.append("    ],")
lines.append("  };")
lines.append("")

# Build method
lines.append("  @override")
lines.append("  Widget build(BuildContext context) {")
lines.append("    final stages = _calendar[_selectedCrop] ?? [];")
lines.append("    final width = MediaQuery.of(context).size.width;")
lines.append(f"    final isCompact = width {lt} 800;")
lines.append("    return Scaffold(")
lines.append("      backgroundColor: AppColors.offWhite,")
lines.append("      body: Column(")
lines.append("        children: [")
lines.append("          _buildHeader(isCompact),")
lines.append("          Expanded(")
lines.append("            child: SingleChildScrollView(")
lines.append("              padding: EdgeInsets.all(isCompact ? 16 : 24),")
lines.append("              child: Column(")
lines.append("                crossAxisAlignment: CrossAxisAlignment.start,")
lines.append("                children: [")
lines.append("                  _buildSeasonInfo(),")
lines.append("                  const SizedBox(height: 24),")
lines.append("                  Text('Growing Stages', style: AppTextStyles.headingMedium),")
lines.append("                  const SizedBox(height: 4),")
lines.append("                  Text('Tap any stage for detailed instructions',")
lines.append("                      style: AppTextStyles.bodySmall),")
lines.append("                  const SizedBox(height: 16),")
lines.append("                  ...stages.asMap().entries.map((entry) =>")
lines.append("                      _buildStageCard(entry.value, entry.key, stages.length)),")
lines.append("                ],")
lines.append("              ),")
lines.append("            ),")
lines.append("          ),")
lines.append("        ],")
lines.append("      ),")
lines.append("    );")
lines.append("  }")
lines.append("")

# _buildHeader
lines.append("  Widget _buildHeader(bool isCompact) {")
lines.append("    return Container(")
lines.append("      padding: EdgeInsets.symmetric(")
lines.append("          horizontal: isCompact ? 16 : 24, vertical: 12),")
lines.append("      decoration: BoxDecoration(")
lines.append("        color: AppColors.cardSurface,")
lines.append("        border: Border(bottom: BorderSide(color: AppColors.grey200)),")
lines.append("      ),")
lines.append("      child: SingleChildScrollView(")
lines.append("        scrollDirection: Axis.horizontal,")
lines.append("        child: Row(")
lines.append("          children: [")
lines.append("            Text('Crop Calendar', style: AppTextStyles.headingMedium),")
lines.append("            const SizedBox(width: 24),")
lines.append("            ...AppCrops.all.map((crop) {")
lines.append("              final selected = _selectedCrop == crop['id'];")
lines.append("              return Padding(")
lines.append("                padding: const EdgeInsets.only(right: 8),")
lines.append("                child: FilterChip(")
lines.append("                  label: Text(crop['label']!),")
lines.append("                  selected: selected,")
lines.append("                  onSelected: (_) =>")
lines.append("                      setState(() => _selectedCrop = crop['id']!),")
lines.append("                  selectedColor: AppColors.deepGreen,")
lines.append("                  checkmarkColor: Colors.white,")
lines.append("                  labelStyle: TextStyle(")
lines.append("                    color: selected ? Colors.white : AppColors.darkText,")
lines.append("                    fontSize: 13,")
lines.append("                  ),")
lines.append("                  backgroundColor: AppColors.grey100,")
lines.append("                  side: BorderSide.none,")
lines.append("                ),")
lines.append("              );")
lines.append("            }),")
lines.append("          ],")
lines.append("        ),")
lines.append("      ),")
lines.append("    );")
lines.append("  }")
lines.append("")

# _buildSeasonInfo
lines.append("  Widget _buildSeasonInfo() {")
lines.append("    final cropInfo = {")
lines.append(f"      {q}wheat{q}: {q}Rabi Season (Oct - Apr) · 180-200 days · 50kg seed/acre{q},")
lines.append(f"      {q}rice{q}: {q}Kharif Season (Jun - Oct) · 120-150 days · 40kg seed/acre{q},")
lines.append(f"      {q}cotton{q}: {q}Kharif Season (May - Nov) · 170-200 days · 5kg seed/acre{q},")
lines.append(f"      {q}sugarcane{q}: {q}Annual Crop (Nov - Nov) · 12-14 months · 7-8 tons setts/acre{q},")
lines.append(f"      {q}maize{q}: {q}Spring/Kharif (Apr - Sep) · 100-120 days · 8-10kg seed/acre{q},")
lines.append("    };")
lines.append("    return Container(")
lines.append("      padding: const EdgeInsets.all(16),")
lines.append("      decoration: BoxDecoration(")
lines.append("        color: AppColors.deepGreen,")
lines.append("        borderRadius: BorderRadius.circular(12),")
lines.append("      ),")
lines.append("      child: Row(children: [")
lines.append("        const Icon(Icons.calendar_month_rounded,")
lines.append("            color: Colors.white, size: 32),")
lines.append("        const SizedBox(width: 16),")
lines.append("        Expanded(")
lines.append("          child: Column(")
lines.append("            crossAxisAlignment: CrossAxisAlignment.start,")
lines.append("            children: [")
lines.append("              Text(")
lines.append("                AppCrops.all.firstWhere(")
lines.append("                    (c) => c['id'] == _selectedCrop)['label']! +")
lines.append("                    ' — Pakistan Growing Calendar',")
lines.append("                style: AppTextStyles.headingSmall.copyWith(")
lines.append("                    color: Colors.white),")
lines.append("              ),")
lines.append("              const SizedBox(height: 4),")
lines.append("              Text(")
lines.append("                cropInfo[_selectedCrop] ?? '',")
lines.append("                style: AppTextStyles.bodySmall.copyWith(")
lines.append("                    color: Colors.white70),")
lines.append("              ),")
lines.append("            ],")
lines.append("          ),")
lines.append("        ),")
lines.append("      ]),")
lines.append("    );")
lines.append("  }")
lines.append("")

# _buildStageCard
lines.append("  Widget _buildStageCard(")
lines.append("      _CropStage stage, int index, int total) {")
lines.append("    return Padding(")
lines.append("      padding: const EdgeInsets.only(bottom: 0),")
lines.append("      child: IntrinsicHeight(")
lines.append("        child: Row(")
lines.append("          crossAxisAlignment: CrossAxisAlignment.start,")
lines.append("          children: [")
lines.append("            SizedBox(")
lines.append("              width: 60,")
lines.append("              child: Column(")
lines.append("                children: [")
lines.append("                  Container(")
lines.append("                    width: 44, height: 44,")
lines.append("                    decoration: BoxDecoration(")
lines.append("                      color: stage.color.withValues(alpha: 0.12),")
lines.append("                      shape: BoxShape.circle,")
lines.append("                      border: Border.all(color: stage.color, width: 2),")
lines.append("                    ),")
lines.append("                    child: Icon(stage.icon, color: stage.color, size: 20),")
lines.append("                  ),")
lines.append(f"                  if (index {lt} total - 1)")
lines.append("                    Expanded(")
lines.append("                      child: Container(")
lines.append("                        width: 2,")
lines.append("                        margin: const EdgeInsets.symmetric(vertical: 4),")
lines.append("                        color: stage.color.withValues(alpha: 0.3),")
lines.append("                      ),")
lines.append("                    ),")
lines.append("                ],")
lines.append("              ),")
lines.append("            ),")
lines.append("            Expanded(")
lines.append("              child: Padding(")
lines.append("                padding: const EdgeInsets.only(left: 12, bottom: 24),")
lines.append("                child: _StageCard(stage: stage, index: index),")
lines.append("              ),")
lines.append("            ),")
lines.append("          ],")
lines.append("        ),")
lines.append("      ),")
lines.append("    ).animate(delay: Duration(milliseconds: index * 80))")
lines.append("        .fadeIn(duration: 400.ms)")
lines.append("        .slideX(begin: 0.1, end: 0);")
lines.append("  }")
lines.append("}")
lines.append("")

# _StageCard widget
lines.append(f"class _StageCard extends StatefulWidget {{")
lines.append("  final _CropStage stage;")
lines.append("  final int index;")
lines.append("  const _StageCard({required this.stage, required this.index});")
lines.append("  @override")
lines.append(f"  State{lt}_StageCard{gt} createState() => _StageCardState();")
lines.append("}")
lines.append("")
lines.append(f"class _StageCardState extends State{lt}_StageCard{gt} {{")
lines.append("  bool _expanded = false;")
lines.append("")
lines.append("  @override")
lines.append("  Widget build(BuildContext context) {")
lines.append("    return GestureDetector(")
lines.append("      onTap: () => setState(() => _expanded = !_expanded),")
lines.append("      child: AnimatedContainer(")
lines.append("        duration: const Duration(milliseconds: 250),")
lines.append("        decoration: BoxDecoration(")
lines.append("          color: Colors.white,")
lines.append("          borderRadius: BorderRadius.circular(12),")
lines.append("          border: Border.all(")
lines.append("            color: _expanded")
lines.append("                ? widget.stage.color")
lines.append("                : AppColors.grey200,")
lines.append("            width: _expanded ? 2 : 1,")
lines.append("          ),")
lines.append("          boxShadow: AppShadows.card,")
lines.append("        ),")
lines.append("        padding: const EdgeInsets.all(14),")
lines.append("        child: Column(")
lines.append("          crossAxisAlignment: CrossAxisAlignment.start,")
lines.append("          children: [")
lines.append("            Row(children: [")
lines.append("              Expanded(")
lines.append("                child: Column(")
lines.append("                  crossAxisAlignment: CrossAxisAlignment.start,")
lines.append("                  children: [")
lines.append("                    Text(widget.stage.name,")
lines.append("                        style: AppTextStyles.headingSmall.copyWith(")
lines.append("                            fontSize: 14)),")
lines.append("                    const SizedBox(height: 2),")
lines.append("                    Row(children: [")
lines.append("                      Icon(Icons.calendar_today_rounded,")
lines.append("                          size: 12, color: widget.stage.color),")
lines.append("                      const SizedBox(width: 4),")
lines.append("                      Text(widget.stage.dateRange,")
lines.append("                          style: TextStyle(")
lines.append("                              fontSize: 12,")
lines.append("                              color: widget.stage.color,")
lines.append("                              fontWeight: FontWeight.w600)),")
lines.append("                      const SizedBox(width: 12),")
lines.append("                      Icon(Icons.schedule_rounded,")
lines.append("                          size: 12, color: AppColors.grey600),")
lines.append("                      const SizedBox(width: 4),")
# Use safe string concatenation for the dollar sign
dur_str = f"'{dl}{lb}widget.stage.durationDays{rb} days'"
lines.append(f"                      Text({dur_str},")
lines.append("                          style: AppTextStyles.bodySmall),")
lines.append("                    ]),")
lines.append("                  ],")
lines.append("                ),")
lines.append("              ),")
lines.append("              Icon(")
lines.append("                _expanded")
lines.append("                    ? Icons.keyboard_arrow_up_rounded")
lines.append("                    : Icons.keyboard_arrow_down_rounded,")
lines.append("                color: AppColors.grey600,")
lines.append("              ),")
lines.append("            ]),")
lines.append("            if (_expanded) ...[")
lines.append("              const SizedBox(height: 10),")
lines.append("              const Divider(height: 1),")
lines.append("              const SizedBox(height: 10),")
lines.append("              Text(widget.stage.instructions,")
lines.append("                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),")
lines.append("            ],")
lines.append("          ],")
lines.append("        ),")
lines.append("      ),")
lines.append("    );")
lines.append("  }")
lines.append("}")
lines.append("")

# _CropStage data class
lines.append("class _CropStage {")
lines.append("  final String name;")
lines.append("  final String dateRange;")
lines.append("  final String instructions;")
lines.append("  final IconData icon;")
lines.append("  final Color color;")
lines.append("  final int durationDays;")
lines.append("")
lines.append("  const _CropStage(this.name, this.dateRange, this.instructions,")
lines.append("      this.icon, this.color, this.durationDays);")
lines.append("}")

with open(path, 'w', encoding='utf-8') as f:
    f.write(nl.join(lines))
print('crop_calendar_screen.dart written successfully!')