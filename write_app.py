bs = chr(92)
nl = chr(10)
q = chr(39)
lt = chr(60)
gt = chr(62)

content = f"""import {q}package:flutter/material.dart{q};
import {q}package:flutter_riverpod/flutter_riverpod.dart{q};
import {q}package:go_router/go_router.dart{q};
import {q}package:cropsense/core/theme.dart{q};
import {q}package:cropsense/data/services/api_service.dart{q};
import {q}package:cropsense/data/services/cache_service.dart{q};
import {q}package:cropsense/main.dart{q} show cacheService;
import {q}package:cropsense/screens/dashboard/dashboard_screen.dart{q};
import {q}package:cropsense/screens/map/map_screen.dart{q};
import {q}package:cropsense/screens/analytics/analytics_screen.dart{q};
import {q}package:cropsense/screens/ai_advisor/ai_advisor_screen.dart{q};
import {q}package:cropsense/screens/crop_calendar/crop_calendar_screen.dart{q};
import {q}package:cropsense/screens/reports/reports_screen.dart{q};

final apiServiceProvider = Provider{lt}ApiService{gt}((ref) => ApiService());
final cacheServiceProvider = Provider{lt}CacheService{gt}((ref) => cacheService);

final _router = GoRouter(
  initialLocation: {q}/{q},
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: {q}/{q},
          name: {q}dashboard{q},
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: {q}/map{q},
          name: {q}map{q},
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: {q}/analytics{q},
          name: {q}analytics{q},
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: {q}/ai-advisor{q},
          name: {q}ai-advisor{q},
          builder: (context, state) => const AIAdvisorScreen(),
        ),
        GoRoute(
          path: {q}/crop-calendar{q},
          name: {q}crop-calendar{q},
          builder: (context, state) => const CropCalendarScreen(),
        ),
        GoRoute(
          path: {q}/reports{q},
          name: {q}reports{q},
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    ),
  ],
);

class CropSenseApp extends ConsumerWidget {{
  const CropSenseApp({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return MaterialApp.router(
      title: {q}CropSense — Pakistan Farm Intelligence{q},
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      routerConfig: _router,
    );
  }}
}}

class _AppShell extends StatefulWidget {{
  final Widget child;
  const _AppShell({{required this.child}});

  @override
  State{lt}_AppShell{gt} createState() => _AppShellState();
}}

class _AppShellState extends State{lt}_AppShell{gt} {{
  final _routes = [
    {q}/{q}, {q}/map{q}, {q}/analytics{q}, {q}/ai-advisor{q},
    {q}/crop-calendar{q}, {q}/reports{q},
  ];

  int _currentIndex(BuildContext context) {{
    final location = GoRouterState.of(context).uri.toString();
    final idx = _routes.indexOf(location);
    return idx {lt} 0 ? 0 : idx;
  }}

  void _onTap(BuildContext context, int index) {{
    context.go(_routes[index]);
  }}

  @override
  Widget build(BuildContext context) {{
    final width = MediaQuery.of(context).size.width;
    final isCompact = width {lt} 800;
    final isWide = width {gt}= 1200;
    final idx = _currentIndex(context);

    const destinations = [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: Text({q}Dashboard{q}),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map_rounded),
        label: Text({q}Risk Map{q}),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: Text({q}Analytics{q}),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology_rounded),
        label: Text({q}AI Advisor{q}),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded),
        label: Text({q}Calendar{q}),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.picture_as_pdf_outlined),
        selectedIcon: Icon(Icons.picture_as_pdf_rounded),
        label: Text({q}Reports{q}),
      ),
    ];

    if (isCompact) {{
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.agriculture,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text({q}CropSense{q}),
          ]),
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF1B5E20),
          child: Column(children: [
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Text({q}CropSense{q},
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ),
            const Divider(color: Colors.white24),
            ...List.generate(destinations.length, (i) {{
              final labels = [
                {q}Dashboard{q}, {q}Risk Map{q}, {q}Analytics{q},
                {q}AI Advisor{q}, {q}Calendar{q}, {q}Reports{q},
              ];
              final icons = [
                Icons.dashboard_rounded,
                Icons.map_rounded,
                Icons.bar_chart_rounded,
                Icons.psychology_rounded,
                Icons.calendar_month_rounded,
                Icons.picture_as_pdf_rounded,
              ];
              return ListTile(
                leading: Icon(icons[i],
                    color: idx == i
                        ? const Color(0xFF8BC34A)
                        : Colors.white70),
                title: Text(labels[i],
                    style: TextStyle(
                        color: idx == i
                            ? const Color(0xFF8BC34A)
                            : Colors.white70,
                        fontWeight: idx == i
                            ? FontWeight.w600
                            : FontWeight.normal)),
                selected: idx == i,
                selectedTileColor:
                    Colors.white.withValues(alpha: 0.1),
                onTap: () {{
                  Navigator.pop(context);
                  _onTap(context, i);
                }},
              );
            }}),
          ]),
        ),
        body: widget.child,
      );
    }}

    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: idx,
          extended: isWide,
          minWidth: 72,
          minExtendedWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.agriculture,
                    color: Colors.white, size: 24),
              ),
              if (isWide) ...[
                const SizedBox(height: 8),
                const Text({q}CropSense{q},
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ]),
          ),
          destinations: destinations,
          onDestinationSelected: (i) => _onTap(context, i),
        ),
        Container(
            width: 1,
            color: Colors.white.withValues(alpha: 0.1)),
        Expanded(child: widget.child),
      ]),
    );
  }}
}}
"""

with open('flutter_app' + bs + 'lib' + bs + 'app.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('app.dart written successfully!')