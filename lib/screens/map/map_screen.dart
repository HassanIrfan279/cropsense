import 'dart:convert';
import 'dart:math' show Point;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/data/models/risk_map.dart';
import 'package:cropsense/providers/map_provider.dart';
import 'package:cropsense/screens/map/widgets/map_legend.dart';
import 'package:cropsense/screens/map/widgets/district_popup.dart';

// Holds polygon points keyed by district id for hit-testing.
typedef _PolyTarget = ({String districtId, List<LatLng> points});

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  List<dynamic> _features = [];
  List<_PolyTarget> _hitTargets = [];
  RiskMapEntry? _selectedEntry;
  String? _hoveredId;
  Offset? _hoverOffset;
  String _selectedCrop = 'wheat';
  int _selectedYear = DataConstants.endYear;
  bool _mapReady = false;
  final _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  // ── GeoJSON ────────────────────────────────────────────────────────────
  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle
          .loadString('assets/geojson/pakistan_districts.geojson');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final features = decoded['features'] as List<dynamic>;
      final targets = <_PolyTarget>[];

      for (final f in features) {
        final id =
            (f['properties'] as Map<String, dynamic>)['district'] as String;
        final geom = f['geometry'] as Map<String, dynamic>;
        final type = geom['type'] as String;
        final coords = geom['coordinates'] as List<dynamic>;

        if (type == 'Polygon') {
          targets.add((districtId: id, points: _ll(coords[0] as List)));
        } else if (type == 'MultiPolygon') {
          for (final ring in coords) {
            targets
                .add((districtId: id, points: _ll((ring as List)[0] as List)));
          }
        }
      }

      if (mounted) {
        setState(() {
          _features = features;
          _hitTargets = targets;
        });
      }
    } catch (e) {
      debugPrint('GeoJSON error: $e');
    }
  }

  List<LatLng> _ll(List<dynamic> coords) => coords
      .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
      .toList();

  // ── Point-in-polygon (ray-casting) ─────────────────────────────────────
  bool _pointInPolygon(LatLng p, List<LatLng> poly) {
    int crosses = 0;
    final n = poly.length;
    for (int i = 0; i < n; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % n];
      final above = a.latitude <= p.latitude && p.latitude < b.latitude;
      final below = b.latitude <= p.latitude && p.latitude < a.latitude;
      if (above || below) {
        final xInt = (b.longitude - a.longitude) *
                (p.latitude - a.latitude) /
                (b.latitude - a.latitude) +
            a.longitude;
        if (p.longitude < xInt) crosses++;
      }
    }
    return crosses.isOdd;
  }

  // Returns the last matching district id (handles MultiPolygon overlap).
  String? _hitTest(LatLng point) {
    String? found;
    for (final t in _hitTargets) {
      if (_pointInPolygon(point, t.points)) found = t.districtId;
    }
    return found;
  }

  // ── Tap ────────────────────────────────────────────────────────────────
  void _handleTap(LatLng point, List<RiskMapEntry> entries) {
    final id = _hitTest(point);
    setState(() {
      _selectedEntry =
          id != null ? _entryFor(id, entries) ?? _missingEntry(id) : null;
    });
  }

  // ── Hover ──────────────────────────────────────────────────────────────
  void _handleHover(PointerHoverEvent event, List<RiskMapEntry> entries) {
    if (!_mapReady) return;
    final latLng = _mapCtrl.camera
        .pointToLatLng(Point(event.localPosition.dx, event.localPosition.dy));
    final id = _hitTest(latLng);
    if (id != _hoveredId) {
      setState(() {
        _hoveredId = id;
        _hoverOffset = event.localPosition;
      });
    } else if (id != null) {
      // Keep tooltip following mouse while staying on same district.
      setState(() => _hoverOffset = event.localPosition);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  RiskMapEntry? _entryFor(String id, List<RiskMapEntry> entries) {
    try {
      return entries.firstWhere((e) => e.district == id);
    } catch (_) {
      return null;
    }
  }

  RiskMapEntry _missingEntry(String id) => RiskMapEntry(
        district: id,
        districtName: id.replaceAll('-', ' '),
        province: 'Data unavailable',
        riskLevel: RiskLevel.watch,
        riskScore: 0,
        selectedCrop: _selectedCrop,
        selectedYear: _selectedYear,
        dataAvailable: false,
        aiExplanation:
            'No connected CropSense API record is available for this region.',
        limitations: const ['Data unavailable for this region.'],
      );

  LatLng _centroid(List<LatLng> pts) => LatLng(
        pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length,
        pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length,
      );

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final riskAsync = ref.watch(riskMapProvider);
    final compact = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _buildToolbar(compact),
        Expanded(
            child: Row(children: [
          Expanded(
              child: riskAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.deepGreen)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (rm) => _buildMap(rm, compact),
          )),
          if (_selectedEntry != null && !compact)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DistrictPopup(
                key: ValueKey(_selectedEntry!.district),
                district: _selectedEntry!,
                selectedCrop: _selectedCrop,
                selectedYear: _selectedYear,
                onClose: () => setState(() => _selectedEntry = null),
              )
                  .animate()
                  .slideX(
                      begin: 1.0,
                      end: 0.0,
                      duration: 220.ms,
                      curve: Curves.easeOut)
                  .fadeIn(duration: 180.ms),
            ),
        ])),
      ]),
    );
  }

  Widget _selectorShell({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(width: 8),
        child,
      ]),
    );
  }

  Widget _buildToolbar(bool compact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(children: [
        Text('Pakistan Risk Map', style: AppTextStyles.headingMedium),
        const SizedBox(width: 24),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _selectorShell(
                label: 'Crop',
                child: DropdownButton<String>(
                  value: _selectedCrop,
                  underline: const SizedBox.shrink(),
                  items: AppCrops.all
                      .map((crop) => DropdownMenuItem(
                            value: crop['id'],
                            child: Text(crop['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCrop = value;
                      _selectedEntry = null;
                    });
                    ref.read(riskMapProvider.notifier).load(
                          crop: _selectedCrop,
                          year: _selectedYear,
                        );
                  },
                ),
              ),
              const SizedBox(width: 10),
              _selectorShell(
                label: 'Year',
                child: DropdownButton<int>(
                  value: _selectedYear,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (int year = DataConstants.endYear;
                        year >= DataConstants.startYear;
                        year--)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedYear = value;
                      _selectedEntry = null;
                    });
                    ref.read(riskMapProvider.notifier).load(
                          crop: _selectedCrop,
                          year: _selectedYear,
                        );
                  },
                ),
              ),
            ]),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => ref.read(riskMapProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.deepGreen,
        ),
      ]),
    );
  }

  // ── Map ─────────────────────────────────────────────────────────────────
  Widget _buildMap(RiskMapResponse riskMap, bool compact) {
    return Stack(children: [
      // Listener captures hover before FlutterMap's gesture layer.
      Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover:
            kIsWeb ? (event) => _handleHover(event, riskMap.districts) : null,
        child: FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter:
                LatLng(MapConstants.pakistanLat, MapConstants.pakistanLng),
            initialZoom: MapConstants.defaultZoom,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            onMapReady: () => setState(() => _mapReady = true),
            // MapOptions.onTap fires for all taps NOT consumed by a child
            // widget (e.g. Marker GestureDetectors absorb their own taps).
            onTap: (_, latLng) => _handleTap(latLng, riskMap.districts),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.cropsense',
            ),
            PolygonLayer(
              polygons: _buildPolygons(riskMap.districts),
              polygonCulling: true,
            ),
            // Fallback tap targets: colored circles at polygon centroids.
            // Marker tap is absorbed by GestureDetector and does NOT
            // trigger MapOptions.onTap, so this path is independent.
            MarkerLayer(
              markers: _buildCenterMarkers(riskMap.districts),
            ),
          ],
        ),
      ),

      // Legend
      Positioned(left: 16, bottom: 16, child: const MapLegend()),

      // Compact bottom popup (slides up)
      if (_selectedEntry != null && compact)
        Positioned(
          left: 16,
          right: 16,
          bottom: 72,
          child: DistrictPopup(
            key: ValueKey(_selectedEntry!.district),
            district: _selectedEntry!,
            selectedCrop: _selectedCrop,
            selectedYear: _selectedYear,
            onClose: () => setState(() => _selectedEntry = null),
          )
              .animate()
              .slideY(
                  begin: 1.0, end: 0.0, duration: 220.ms, curve: Curves.easeOut)
              .fadeIn(duration: 180.ms),
        ),

      // Hover tooltip (web desktop only)
      if (kIsWeb && _hoveredId != null && _hoverOffset != null)
        _buildTooltip(_hoveredId!, riskMap.districts),
    ]);
  }

  // ── Polygons ─────────────────────────────────────────────────────────────
  List<Polygon> _buildPolygons(List<RiskMapEntry> entries) {
    final result = <Polygon>[];
    for (final f in _features) {
      final id =
          (f['properties'] as Map<String, dynamic>)['district'] as String;
      final entry = _entryFor(id, entries);
      final isSel = _selectedEntry?.district == id;
      final isHov = _hoveredId == id;

      final base = entry != null && entry.dataAvailable
          ? riskColor(entry.riskLevel.name)
          : AppColors.grey400;
      final fill = base.withValues(
          alpha: isSel
              ? 0.85
              : isHov
                  ? 0.75
                  : 0.55);
      final border = isSel
          ? Colors.white
          : isHov
              ? Colors.white.withValues(alpha: 0.8)
              : base.withValues(alpha: 0.9);
      final stroke = isSel
          ? 3.0
          : isHov
              ? 2.5
              : 1.5;

      final geom = f['geometry'] as Map<String, dynamic>;
      final type = geom['type'] as String;
      final coords = geom['coordinates'] as List<dynamic>;

      void addPoly(List pts) => result.add(Polygon(
            points: _ll(pts),
            color: fill,
            borderColor: border,
            borderStrokeWidth: stroke,
          ));

      if (type == 'Polygon') {
        addPoly(coords[0] as List);
      } else if (type == 'MultiPolygon') {
        for (final ring in coords) {
          addPoly((ring as List)[0] as List);
        }
      }
    }
    return result;
  }

  // ── Center markers ────────────────────────────────────────────────────────
  List<Marker> _buildCenterMarkers(List<RiskMapEntry> entries) {
    final markers = <Marker>[];
    final seen = <String>{};

    for (final t in _hitTargets) {
      final id = t.districtId;
      if (seen.contains(id)) continue;
      final entry = _entryFor(id, entries) ?? _missingEntry(id);
      seen.add(id);

      final isSel = _selectedEntry?.district == id;
      final color = entry.dataAvailable
          ? riskColor(entry.riskLevel.name)
          : AppColors.grey400;
      final size = isSel ? 18.0 : 11.0;

      markers.add(Marker(
        point: _centroid(t.points),
        width: size,
        height: size,
        child: GestureDetector(
          // This tap is consumed here — MapOptions.onTap will NOT also fire.
          onTap: () => setState(() => _selectedEntry = entry),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: isSel ? 2.5 : 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)
              ],
            ),
          ),
        ),
      ));
    }
    return markers;
  }

  // ── Hover tooltip ─────────────────────────────────────────────────────────
  Widget _buildTooltip(String id, List<RiskMapEntry> entries) {
    final entry = _entryFor(id, entries);
    final offset = _hoverOffset!;
    // Keep tooltip inside viewport
    final screenW = MediaQuery.of(context).size.width;
    final left = (offset.dx + 16).clamp(0.0, screenW - 200);
    final top = (offset.dy - 56).clamp(8.0, double.infinity);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry?.districtName ?? id,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              if (entry != null) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: riskColor(entry.riskLevel.name),
                    ),
                  ),
                  Text(
                    entry.riskLevel.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: riskColor(entry.riskLevel.name),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(
                  'NDVI: ${entry.ndvi.toStringAsFixed(2)}  '
                  'Score: ${entry.riskScore.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
