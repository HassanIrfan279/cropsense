import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/data/services/api_service.dart';
import 'package:cropsense/data/services/cache_service.dart';
import 'package:cropsense/main.dart' show cacheService;
import 'package:cropsense/screens/dashboard/dashboard_screen.dart';
import 'package:cropsense/screens/map/map_screen.dart';
import 'package:cropsense/screens/analytics/analytics_screen.dart';
import 'package:cropsense/screens/ai_advisor/ai_advisor_screen.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final cacheServiceProvider = Provider<CacheService>((ref) => cacheService);

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/analytics',
          name: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/ai-advisor',
          name: 'ai-advisor',
          builder: (context, state) => const AIAdvisorScreen(),
        ),
        GoRoute(
          path: '/crop-calendar',
          name: 'crop-calendar',
          builder: (context, state) => const _PlaceholderScreen(
            title: 'Crop Calendar',
            icon: Icons.calendar_month_rounded,
            color: Color(0xFF8BC34A),
          ),
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const _PlaceholderScreen(
            title: 'Reports',
            icon: Icons.picture_as_pdf_rounded,
            color: Color(0xFFE65100),
          ),
        ),
      ],
    ),
  ],
);

class CropSenseApp extends ConsumerWidget {
  const CropSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CropSense — Pakistan Farm Intelligence',
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
  final _routes = ['/', '/map', '/analytics', '/ai-advisor', '/crop-calendar', '/reports'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _routes.indexOf(location);
    return idx < 0 ? 0 : idx;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 800;
    final isWide = width >= 1200;
    final idx = _currentIndex(context);

    const destinations = [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map_rounded),
        label: Text('Risk Map'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: Text('Analytics'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology_rounded),
        label: Text('AI Advisor'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded),
        label: Text('Calendar'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.picture_as_pdf_outlined),
        selectedIcon: Icon(Icons.picture_as_pdf_rounded),
        label: Text('Reports'),
      ),
    ];

    if (isCompact) {
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('CropSense'),
          ]),
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF1B5E20),
          child: Column(children: [
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('CropSense', style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const Divider(color: Colors.white24),
            ...List.generate(destinations.length, (i) {
              final labels = ['Dashboard', 'Risk Map', 'Analytics',
                  'AI Advisor', 'Calendar', 'Reports'];
              final icons = [
                Icons.dashboard_rounded, Icons.map_rounded,
                Icons.bar_chart_rounded, Icons.psychology_rounded,
                Icons.calendar_month_rounded, Icons.picture_as_pdf_rounded,
              ];
              return ListTile(
                leading: Icon(icons[i],
                    color: idx == i ? const Color(0xFF8BC34A) : Colors.white70),
                title: Text(labels[i], style: TextStyle(
                    color: idx == i ? const Color(0xFF8BC34A) : Colors.white70,
                    fontWeight: idx == i ? FontWeight.w600 : FontWeight.normal)),
                selected: idx == i,
                selectedTileColor: Colors.white.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.pop(context);
                  _onTap(context, i);
                },
              );
            }),
          ]),
        ),
        body: widget.child,
      );
    }

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
                const Text('CropSense', style: TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w700)),
              ],
            ]),
          ),
          destinations: destinations,
          onDestinationSelected: (i) => _onTap(context, i),
        ),
        Container(width: 1, color: Colors.white.withValues(alpha: 0.1)),
        Expanded(child: widget.child),
      ]),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 8),
            Text('Coming Soon', style: TextStyle(
                fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
