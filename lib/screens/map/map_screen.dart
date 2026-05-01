import 'dart:convert';
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

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  List<dynamic> _features = [];
  // First polygon ring per district — used for point-in-polygon hit detection
  final Map<String, List<LatLng>> _districtPolygons = {};

  RiskMapEntry? _selectedEntry;
  String _selectedCrop = 'wheat';
  String? _hoveredDistrictId;
  Offset? _tooltipOffset;

  final _mapController = MapController();
  late AnimationController _zoomAnimController;

  @override
  void initState() {
    super.initState();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadGeoJson();
  }

  @override
  void dispose() {
    _zoomAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString('assets/geojson/pakistan_districts.geojson');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final features = decoded['features'] as List<dynamic>;
      final polys = <String, List<LatLng>>{};
      for (final f in features) {
        final id = (f['properties'] as Map<String, dynamic>)['district'] as String;
        final geo = f['geometry'] as Map<String, dynamic>;
        if (geo['type'] == 'Polygon') {
          polys[id] = _toLatLng(geo['coordinates'][0] as List<dynamic>);
        } else if (geo['type'] == 'MultiPolygon') {
          polys[id] = _toLatLng((geo['coordinates'][0] as List<dynamic>)[0] as List<dynamic>);
        }
      }
      if (mounted) {
        setState(() {
          _features = features;
          _districtPolygons.addAll(polys);
        });
      }
    } catch (e) {
      debugPrint('GeoJSON load error: $e');
    }
  }

  List<LatLng> _toLatLng(List<dynamic> coords) => coords
      .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
      .toList();

  // ── Point-in-polygon (ray casting) ──────────────────────────────────
  bool _pointInPolygon(LatLng pt, List<LatLng> poly) {
    bool inside = false;
    final n = poly.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = poly[i].longitude, yi = poly[i].latitude;
      final xj = poly[j].longitude, yj = poly[j].latitude;
      if (((yi > pt.latitude) != (yj > pt.latitude)) &&
          (pt.longitude < (xj - xi) * (pt.latitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  String? _districtAtLatLng(LatLng latlng) {
    for (final e in _districtPolygons.entries) {
      if (_pointInPolygon(latlng, e.value)) return e.key;
    }
    return null;
  }

  String _labelFor(String id) => AppDistricts.all
      .firstWhere((d) => d['id'] == id, orElse: () => {'label': id})['label']!;

  String _provinceFor(String id) => AppDistricts.all
      .firstWhere((d) => d['id'] == id, orElse: () => {'province': 'Pakistan'})['province']!;

  // ── Smooth animated camera move ─────────────────────────────────────
  void _animatedMoveTo(LatLng dest, double destZoom) {
    final startCenter = _mapController.camera.center;
    final startZoom   = _mapController.camera.zoom;
    final latTween  = Tween<double>(begin: startCenter.latitude,  end: dest.latitude);
    final lngTween  = Tween<double>(begin: startCenter.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: startZoom, end: destZoom);
    final anim = CurvedAnimation(parent: _zoomAnimController, curve: Curves.fastOutSlowIn);

    void listener() {
      _mapController.move(
        LatLng(latTween.evaluate(anim), lngTween.evaluate(anim)),
        zoomTween.evaluate(anim),
      );
    }

    _zoomAnimController
      ..reset()
      ..addListener(listener);
    _zoomAnimController.forward().then((_) => _zoomAnimController.removeListener(listener));
  }

  // ── Tap handler ─────────────────────────────────────────────────────
  void _handleTap(LatLng latlng, List<RiskMapEntry> entries) {
    final id = _districtAtLatLng(latlng);
    if (id == null) {
      setState(() => _selectedEntry = null);
      return;
    }
    final entry = entries.firstWhere(
      (e) => e.district == id,
      orElse: () => RiskMapEntry(
        district: id,
        districtName: _labelFor(id),
        province: _provinceFor(id),
        riskLevel: RiskLevel.good,
        riskScore: 0,
        ndvi: 0,
        alertCount: 0,
        cropYields: const {},
      ),
    );
    setState(() => _selectedEntry = entry);

    // Smoothly zoom into the tapped district
    _animatedMoveTo(latlng, (_mapController.camera.zoom + 1.5).clamp(5.0, 9.0));
  }

  // ── Hover handler ────────────────────────────────────────────────────
  void _onMapHover(Offset localPos) {
    try {
      final latlng = _mapController.camera.screenOffsetToLatLng(localPos);
      final newId = _districtAtLatLng(latlng);
      if (newId != _hoveredDistrictId) {
        setState(() {
          _hoveredDistrictId = newId;
          _tooltipOffset = newId != null ? localPos : null;
        });
      } else if (newId != null) {
        // Update tooltip position even if district didn't change
        setState(() => _tooltipOffset = localPos);
      }
    } catch (_) {}
  }

  // ── Build polygons ───────────────────────────────────────────────────
  List<Polygon> _buildPolygons(List<RiskMapEntry> entries) {
    final result = <Polygon>[];
    for (final f in _features) {
      final props = f['properties'] as Map<String, dynamic>;
      final id    = props['district'] as String;
      final entry = entries.cast<RiskMapEntry?>().firstWhere(
        (e) => e!.district == id, orElse: () => null);
      final isSelected = _selectedEntry?.district == id;
      final isHovered  = _hoveredDistrictId == id;

      final base = entry != null ? riskColor(entry.riskLevel.name) : AppColors.grey400;
      final fill = base.withValues(alpha: isSelected ? 0.88 : isHovered ? 0.78 : 0.55);
      final border = (isSelected || isHovered) ? Colors.white : base;
      final borderWidth = isSelected ? 3.0 : isHovered ? 2.5 : 1.2;

      final geo   = f['geometry'] as Map<String, dynamic>;
      final geoType = geo['type'] as String;
      final coords  = geo['coordinates'] as List<dynamic>;

      void addRing(List<dynamic> ring) {
        final pts = _toLatLng(ring);
        result.add(Polygon(
          points: pts,
          color: fill,
          borderColor: border,
          borderStrokeWidth: borderWidth,
        ));
      }

      if (geoType == 'Polygon') {
        addRing(coords[0] as List<dynamic>);
      } else if (geoType == 'MultiPolygon') {
        for (final poly in coords) {
          addRing((poly as List<dynamic>)[0] as List<dynamic>);
        }
      }
    }
    return result;
  }

  // ── UI ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final riskMapAsync = ref.watch(riskMapProvider);
    final width   = MediaQuery.of(context).size.width;
    final compact = width < 800;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _buildToolbar(compact),
        Expanded(child: Row(children: [
          Expanded(
            child: riskMapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),
              error:   (e, _) => Center(child: Text('Error: $e')),
              data:    (rm) => _buildMap(rm, compact),
            ),
          ),
          // ── Desktop side panel (slides in with AnimatedSize) ────────
          if (!compact)
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: _selectedEntry != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: DistrictPopup(
                      district: _selectedEntry!,
                      onClose: () => setState(() => _selectedEntry = null),
                    ).animate().fadeIn(duration: 220.ms).slideX(begin: 0.15, end: 0, duration: 220.ms),
                  )
                : const SizedBox.shrink(),
            ),
        ])),
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
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.map_rounded, color: AppColors.deepGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Text('Pakistan Risk Map', style: AppTextStyles.headingMedium),
        const SizedBox(width: 24),
        if (!compact)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: AppCrops.all.map((crop) {
                final sel = _selectedCrop == crop['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(crop['label']!),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedCrop = crop['id']!),
                    selectedColor: AppColors.deepGreen,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : AppColors.darkText, fontSize: 13),
                    backgroundColor: AppColors.grey100,
                    side: BorderSide.none,
                  ),
                );
              }).toList()),
            ),
          ),
        const Spacer(),
        IconButton(
          onPressed: () => ref.refresh(riskMapProvider),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.deepGreen,
          tooltip: 'Refresh',
        ),
      ]),
    );
  }

  Widget _buildMap(RiskMapResponse riskMap, bool compact) {
    return Listener(
      onPointerHover: (event) => _onMapHover(event.localPosition),
      child: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(MapConstants.pakistanLat, MapConstants.pakistanLng),
            initialZoom: MapConstants.defaultZoom,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            onTap: (_, latlng) => _handleTap(latlng, riskMap.districts),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cropsense.app',
              retinaMode: false,
            ),
            PolygonLayer(polygons: _buildPolygons(riskMap.districts)),
          ],
        ),

        // ── Hover tooltip ──────────────────────────────────────────────
        if (_hoveredDistrictId != null && _tooltipOffset != null)
          _buildTooltip(_tooltipOffset!, _hoveredDistrictId!),

        // ── Legend ─────────────────────────────────────────────────────
        const Positioned(left: 16, bottom: 16, child: MapLegend()),

        // ── Compact bottom popup ───────────────────────────────────────
        if (_selectedEntry != null && compact)
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: DistrictPopup(
              district: _selectedEntry!,
              onClose: () => setState(() => _selectedEntry = null),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0, duration: 200.ms),
          ),

        // ── Zoom controls ──────────────────────────────────────────────
        Positioned(
          right: 16, top: 16,
          child: _ZoomControls(mapController: _mapController),
        ),
      ]),
    );
  }

  Widget _buildTooltip(Offset pos, String id) {
    final label = _labelFor(id);
    // Clamp so tooltip doesn't go off screen edges
    final dx = pos.dx + 14;
    final dy = (pos.dy - 36).clamp(4.0, double.infinity);
    return Positioned(
      left: dx,
      top: dy,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2B1E).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(7),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: AppColors.limeGreen, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

// ── Zoom control buttons ───────────────────────────────────────────────────────
class _ZoomControls extends StatelessWidget {
  final MapController mapController;
  const _ZoomControls({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _ZoomBtn(
        icon: Icons.add_rounded,
        onTap: () {
          final z = (mapController.camera.zoom + 0.8).clamp(4.0, 10.0);
          mapController.move(mapController.camera.center, z);
        },
      ),
      const SizedBox(height: 2),
      _ZoomBtn(
        icon: Icons.remove_rounded,
        onTap: () {
          final z = (mapController.camera.zoom - 0.8).clamp(4.0, 10.0);
          mapController.move(mapController.camera.center, z);
        },
      ),
      const SizedBox(height: 2),
      _ZoomBtn(
        icon: Icons.my_location_rounded,
        onTap: () => mapController.move(
          LatLng(MapConstants.pakistanLat, MapConstants.pakistanLng),
          MapConstants.defaultZoom,
        ),
      ),
    ]);
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 36, height: 36,
          child: Icon(icon, size: 18, color: AppColors.deepGreen),
        ),
      ),
    );
  }
}
