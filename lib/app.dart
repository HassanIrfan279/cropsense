import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/data/services/api_service.dart';
import 'package:cropsense/data/services/cache_service.dart';
import 'package:cropsense/main.dart' show cacheService;
import 'package:cropsense/screens/dashboard/dashboard_screen.dart';
import 'package:cropsense/screens/map/map_screen.dart';
import 'package:cropsense/screens/analytics/analytics_screen.dart';
import 'package:cropsense/screens/ai_advisor/ai_advisor_screen.dart';
import 'package:cropsense/screens/crop_calendar/crop_calendar_screen.dart';
import 'package:cropsense/screens/field_management/field_management_screen.dart';
import 'package:cropsense/screens/future_prediction/future_crop_prediction_screen.dart';
import 'package:cropsense/screens/reports/reports_screen.dart';
import 'package:cropsense/shared/widgets/neon_background.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final cacheServiceProvider = Provider<CacheService>((ref) => cacheService);

Page<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(begin: const Offset(0.015, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (c, s) => _fadePage(s, const DashboardScreen())),
        GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (c, s) => _fadePage(s, const MapScreen())),
        GoRoute(
            path: '/analytics',
            name: 'analytics',
            pageBuilder: (c, s) => _fadePage(s, const AnalyticsScreen())),
        GoRoute(
            path: '/future-prediction',
            name: 'future-prediction',
            pageBuilder: (c, s) =>
                _fadePage(s, const FutureCropPredictionScreen())),
        GoRoute(
            path: '/field-management',
            name: 'field-management',
            pageBuilder: (c, s) => _fadePage(s, const FieldManagementScreen())),
        GoRoute(
            path: '/ai-advisor',
            name: 'ai-advisor',
            pageBuilder: (c, s) => _fadePage(s, const AIAdvisorScreen())),
        GoRoute(
            path: '/crop-calendar',
            name: 'crop-calendar',
            pageBuilder: (c, s) => _fadePage(s, const CropCalendarScreen())),
        GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (c, s) => _fadePage(s, const ReportsScreen())),
      ],
    ),
  ],
);

class CropSenseApp extends ConsumerWidget {
  const CropSenseApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CropSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      routerConfig: _router,
    );
  }
}

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  final _routes = [
    '/',
    '/map',
    '/analytics',
    '/future-prediction',
    '/field-management',
    '/ai-advisor',
    '/crop-calendar',
    '/reports'
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _routes.indexOf(location);
    return idx < 0 ? 0 : idx;
  }

  void _onTap(BuildContext context, int index) => context.go(_routes[index]);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    final isWide = width >= 1200;
    final idx = _currentIndex(context);

    if (isCompact) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.navRail),
          ),
          title: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.agriculture_rounded,
                  color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            Text('CropSense',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                )),
          ]),
        ),
        drawer: _CompactDrawer(
            selectedIndex: idx, onTap: (i) => _onTap(context, i)),
        body: NeonBackground(child: widget.child),
      );
    }

    return Scaffold(
      body: NeonBackground(
        child: Row(children: [
          _PremiumNavRail(
            selectedIndex: idx,
            extended: isWide,
            onDestinationSelected: (i) => _onTap(context, i),
          ),
          Expanded(child: widget.child),
        ]),
      ),
    );
  }
}

// ── Compact drawer (mobile / narrow layout) ───────────────────────────────────
class _CompactDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _CompactDrawer({required this.selectedIndex, required this.onTap});

  static const _labels = [
    'Dashboard',
    'Risk Map',
    'Analytics',
    'Future',
    'Fields',
    'AI Advisor',
    'Calendar',
    'Reports'
  ];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.map_rounded,
    Icons.bar_chart_rounded,
    Icons.auto_graph_rounded,
    Icons.landscape_rounded,
    Icons.psychology_rounded,
    Icons.calendar_month_rounded,
    Icons.picture_as_pdf_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.navRail),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(Icons.agriculture_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CropSense',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    )),
                Text('Pakistan Ag Intelligence',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                      letterSpacing: 0.3,
                    )),
              ]),
            ]),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 6),
          ...List.generate(
              _labels.length,
              (i) => ListTile(
                    leading: Icon(_icons[i],
                        color: selectedIndex == i
                            ? AppColors.limeGreen
                            : Colors.white.withValues(alpha: 0.72)),
                    title: Text(_labels[i],
                        style: TextStyle(
                          color: selectedIndex == i
                              ? AppColors.limeGreen
                              : Colors.white.withValues(alpha: 0.72),
                          fontWeight: selectedIndex == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        )),
                    selected: selectedIndex == i,
                    selectedTileColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () {
                      Navigator.pop(context);
                      onTap(i);
                    },
                  )),
        ]),
      ),
    );
  }
}

// ── Premium navigation rail with gradient + hover effects ─────────────────────
class _PremiumNavRail extends StatefulWidget {
  final int selectedIndex;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  const _PremiumNavRail({
    required this.selectedIndex,
    required this.extended,
    required this.onDestinationSelected,
  });

  @override
  State<_PremiumNavRail> createState() => _PremiumNavRailState();
}

class _PremiumNavRailState extends State<_PremiumNavRail> {
  int? _hoveredIndex;

  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
    (Icons.map_outlined, Icons.map_rounded, 'Risk Map'),
    (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
    (Icons.auto_graph_outlined, Icons.auto_graph_rounded, 'Future'),
    (Icons.landscape_outlined, Icons.landscape_rounded, 'Fields'),
    (Icons.psychology_outlined, Icons.psychology_rounded, 'AI Advisor'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Calendar'),
    (Icons.picture_as_pdf_outlined, Icons.picture_as_pdf_rounded, 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      width: widget.extended ? 200 : 72,
      decoration: const BoxDecoration(gradient: AppGradients.navRail),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogo(),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          Expanded(
              child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                ..._items
                    .asMap()
                    .entries
                    .map((e) => _buildNavItem(e.key, e.value)),
              ],
            ),
          )),
          _buildVersion(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.22), width: 1),
          ),
          child: const Icon(Icons.agriculture_rounded,
              color: Colors.white, size: 22),
        ),
        if (widget.extended) ...[
          const SizedBox(height: 10),
          Text('CropSense',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              )),
          const SizedBox(height: 2),
          Text('Pakistan Ag Intelligence',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 10,
                letterSpacing: 0.3,
              )),
        ],
      ]),
    );
  }

  Widget _buildNavItem(
      int index, (IconData outIcon, IconData fillIcon, String label) item) {
    final (iconOut, iconFill, label) = item;
    final isSelected = widget.selectedIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onDestinationSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(
            horizontal: widget.extended ? 10 : 8,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.extended ? 12 : 0,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonMint.withValues(alpha: 0.18)
                : isHovered
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: AppColors.neonMint.withValues(alpha: 0.48), width: 1)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.neonMint.withValues(alpha: 0.22),
                      blurRadius: 18,
                    )
                  ]
                : null,
          ),
          child: widget.extended
              ? Row(children: [
                  const SizedBox(width: 2),
                  Icon(
                    isSelected ? iconFill : iconOut,
                    color: isSelected
                        ? AppColors.limeGreen
                        : Colors.white.withValues(alpha: 0.72),
                    size: 21,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.limeGreen
                              : Colors.white.withValues(alpha: 0.72),
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ),
                  if (isSelected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: AppColors.limeGreen, shape: BoxShape.circle),
                    ),
                  const SizedBox(width: 4),
                ])
              : Center(
                  child: Icon(
                    isSelected ? iconFill : iconOut,
                    color: isSelected
                        ? AppColors.limeGreen
                        : Colors.white.withValues(alpha: 0.72),
                    size: 22,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildVersion() {
    if (!widget.extended) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text('v1.1',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 11,
          )),
    );
  }
}
