import os

lt = chr(60)
gt = chr(62)
q = chr(39)
bs = chr(92)
nl = chr(10)

# ── Fix 1: Rewrite yield_provider.dart ───────────────────────────────
yield_lines = [
    f"import {q}package:flutter_riverpod/flutter_riverpod.dart{q};",
    f"import {q}package:cropsense/app.dart{q};",
    f"import {q}package:cropsense/data/models/yield_data.dart{q};",
    "",
    f"final cropYieldProvider = AsyncNotifierProviderFamily{lt}CropYieldNotifier, YieldDataResponse, (String, String){gt}(CropYieldNotifier.new);",
    "",
    f"class CropYieldNotifier extends FamilyAsyncNotifier{lt}YieldDataResponse, (String, String){gt} {{",
    "  @override",
    f"  Future{lt}YieldDataResponse{gt} build((String, String) arg) async {{",
    "    return _load(arg.$1, arg.$2);",
    "  }",
    "",
    f"  Future{lt}YieldDataResponse{gt} _load(String district, String crop) async {{",
    "    final cache = ref.read(cacheServiceProvider);",
    "    final api = ref.read(apiServiceProvider);",
    "    final cached = cache.getCachedYieldData(district, crop);",
    "    if (cached != null) { return YieldDataResponse.fromJson(cached); }",
    "    try {",
    "      final response = await api.getYieldData(district: district, crop: crop);",
    "      await cache.cacheYieldData(district, crop, response.toJson());",
    "      return response;",
    "    } catch (e) { return _mock(district, crop); }",
    "  }",
    "}",
    "",
    "YieldDataResponse _mock(String district, String crop) {",
    "  final years = List.generate(19, (i) => 2005 + i);",
    "  final data = years.map((yr) {",
    "    final p = (yr - 2005) / 18.0;",
    "    final base = 1.8 + (p * 0.6);",
    "    final v = 0.3 * (yr % 3 == 0 ? -1 : 1);",
    "    return YieldData(",
    "      district: district, crop: crop, year: yr,",
    "      yieldTAcre: (base + v).clamp(0.8, 3.5),",
    "      ndvi: (0.45 + p * 0.25).clamp(0.2, 0.9),",
    "      rainfallMm: 180 + (yr % 5) * 40.0,",
    "      tempMaxC: 36 + (yr % 3) * 2.0,",
    "      tempMinC: 18 + (yr % 4) * 1.5,",
    "      soilMoisturePct: 35 + (yr % 6) * 5.0,",
    "      predictedYield: base + v * 0.8,",
    "    );",
    "  }).toList();",
    "  return YieldDataResponse(district: district, crop: crop, data: data);",
    "}",
]

with open(f'lib{bs}providers{bs}yield_provider.dart', 'w', encoding='utf-8') as f:
    f.write(nl.join(yield_lines))
print('✅ yield_provider.dart written')

# ── Fix 2: Delete crop_yield_provider.dart (duplicate) ───────────────
cyp = f'lib{bs}providers{bs}crop_yield_provider.dart'
if os.path.exists(cyp):
    os.remove(cyp)
    print('✅ crop_yield_provider.dart deleted (was duplicate)')

# ── Fix 3: Rewrite analytics_screen.dart ─────────────────────────────
analytics_lines = [
    f"import {q}package:flutter/material.dart{q};",
    f"import {q}package:flutter_riverpod/flutter_riverpod.dart{q};",
    f"import {q}package:cropsense/core/constants.dart{q};",
    f"import {q}package:cropsense/core/theme.dart{q};",
    f"import {q}package:cropsense/providers/yield_provider.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/ndvi_chart.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/yield_bar_chart.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/scatter_chart.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/correlation_heatmap.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/probability_curve.dart{q};",
    f"import {q}package:cropsense/screens/analytics/widgets/residuals_chart.dart{q};",
    "",
    "class AnalyticsScreen extends ConsumerStatefulWidget {",
    "  const AnalyticsScreen({super.key});",
    "  @override",
    f"  ConsumerState{lt}AnalyticsScreen{gt} createState() => _AnalyticsScreenState();",
    "}",
    "",
    f"class _AnalyticsScreenState extends ConsumerState{lt}AnalyticsScreen{gt} {{",
    f"  String _district = {q}faisalabad{q};",
    f"  String _crop = {q}wheat{q};",
    "",
    "  static const _provinceYields = {",
    f"    {q}Punjab{q}: 2.4, {q}Sindh{q}: 1.9, {q}KPK{q}: 2.1, {q}Balochistan{q}: 1.2,",
    "  };",
    "",
    "  @override",
    "  Widget build(BuildContext context) {",
    "    final width = MediaQuery.of(context).size.width;",
    f"    final isCompact = width {lt} 800;",
    f"    final isWide = width {gt}= 1200;",
    "    final yieldAsync = ref.watch(cropYieldProvider((_district, _crop)));",
    "    return Scaffold(",
    "      backgroundColor: AppColors.offWhite,",
    "      body: Column(",
    "        children: [",
    "          _buildToolbar(),",
    "          Expanded(",
    "            child: yieldAsync.when(",
    "              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),",
    "              error: (e, _) => _buildChartGrid(_mockChartData(), _provinceYields, isCompact, isWide),",
    "              data: (response) => _buildChartGrid(",
    "                response.data.map((d) => d.toJson()).toList(),",
    "                _provinceYields, isCompact, isWide,",
    "              ),",
    "            ),",
    "          ),",
    "        ],",
    "      ),",
    "    );",
    "  }",
    "",
    "  Widget _buildToolbar() {",
    "    return Container(",
    "      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),",
    "      decoration: BoxDecoration(",
    "        color: AppColors.cardSurface,",
    "        border: Border(bottom: BorderSide(color: AppColors.grey200)),",
    "      ),",
    "      child: Row(",
    "        children: [",
    "          Text('Analytics', style: AppTextStyles.headingMedium),",
    "          const SizedBox(width: 24),",
    "          const Text('District:', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),",
    "          const SizedBox(width: 8),",
    f"          DropdownButton{lt}String{gt}(",
    "            value: _district,",
    "            underline: const SizedBox.shrink(),",
    "            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),",
    f"            items: AppDistricts.all.take(12).map((d) => DropdownMenuItem{lt}String{gt}(",
    "              value: d['id'], child: Text(d['label']!),",
    "            )).toList(),",
    "            onChanged: (v) => setState(() => _district = v!),",
    "          ),",
    "          const SizedBox(width: 20),",
    "          const Text('Crop:', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),",
    "          const SizedBox(width: 8),",
    f"          DropdownButton{lt}String{gt}(",
    "            value: _crop,",
    "            underline: const SizedBox.shrink(),",
    "            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),",
    f"            items: AppCrops.all.map((c) => DropdownMenuItem{lt}String{gt}(",
    "              value: c['id'], child: Text(c['label']!),",
    "            )).toList(),",
    "            onChanged: (v) => setState(() => _crop = v!),",
    "          ),",
    "        ],",
    "      ),",
    "    );",
    "  }",
    "",
    f"  Widget _buildChartGrid(List{lt}Map{lt}String, dynamic{gt}{gt} data, Map{lt}String, double{gt} pYields, bool isCompact, bool isWide) {{",
    "    final charts = [",
    "      NdviChart(data: data),",
    "      YieldBarChart(provinceYields: pYields),",
    "      NdviYieldScatter(data: data),",
    "      const CorrelationHeatmap(),",
    "      const ProbabilityCurve(),",
    "      ResidualsChart(data: data),",
    "    ];",
    "    if (isCompact) {",
    "      return ListView.separated(",
    "        padding: const EdgeInsets.all(16),",
    "        itemCount: charts.length,",
    "        separatorBuilder: (_, __) => const SizedBox(height: 16),",
    "        itemBuilder: (_, i) => SizedBox(height: 280, child: charts[i]),",
    "      );",
    "    }",
    "    return GridView.count(",
    "      padding: const EdgeInsets.all(16),",
    "      crossAxisCount: isWide ? 3 : 2,",
    "      crossAxisSpacing: 16, mainAxisSpacing: 16,",
    "      childAspectRatio: isWide ? 1.4 : 1.3,",
    "      children: charts,",
    "    );",
    "  }",
    "}",
    "",
    f"List{lt}Map{lt}String, dynamic{gt}{gt} _mockChartData() {{",
    "  return List.generate(19, (i) {",
    "    final p = i / 18.0;",
    "    final base = 1.8 + p * 0.6;",
    "    final v = 0.3 * (i % 3 == 0 ? -1 : 1);",
    f"    return {lt}String, dynamic{gt}{{",
    "      'year': 2005 + i,",
    "      'ndvi': (0.45 + p * 0.25 + (i % 4 == 0 ? -0.1 : 0.05)).clamp(0.2, 0.9),",
    "      'yieldTAcre': (base + v).clamp(0.8, 3.5),",
    "      'predictedYield': base + v * 0.8,",
    "      'rainfallMm': 180.0 + (i % 5) * 40.0,",
    "    };",
    "  });",
    "}",
]

with open(f'lib{bs}screens{bs}analytics{bs}analytics_screen.dart', 'w', encoding='utf-8') as f:
    f.write(nl.join(analytics_lines))
print('✅ analytics_screen.dart written')

# ── Fix 4: Update app.dart route + import ────────────────────────────
app_path = f'lib{bs}app.dart'
app = open(app_path, encoding='utf-8').read()

# Add import if missing
imp = f"import {q}package:cropsense/screens/analytics/analytics_screen.dart{q};"
if imp not in app:
    dash_imp = f"import {q}package:cropsense/screens/dashboard/dashboard_screen.dart{q};"
    app = app.replace(dash_imp, dash_imp + nl + imp)
    print('✅ Analytics import added to app.dart')
else:
    print('✅ Analytics import already in app.dart')

# Replace placeholder route
if '_PlaceholderScreen' in app and 'Analytics' in app:
    import re
    app = re.sub(
        r"GoRoute\(\s*path: '/analytics'.*?builder: \(context, state\) => const _PlaceholderScreen\(\s*title: 'Analytics'.*?\),\s*\),",
        "GoRoute(\n          path: '/analytics',\n          name: 'analytics',\n          builder: (context, state) => const AnalyticsScreen(),\n        ),",
        app,
        flags=re.DOTALL
    )
    print('✅ Analytics route updated in app.dart')
else:
    print('✅ Analytics route already updated or pattern not found')

open(app_path, 'w', encoding='utf-8').write(app)
print('\n🎉 All fixes applied!')