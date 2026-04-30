import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _MapScreenState extends ConsumerState<MapScreen> {
  List<dynamic> _features = [];
  RiskMapEntry? _selectedEntry;
  String _selectedCrop = 'wheat';
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString('assets/geojson/pakistan_districts.geojson');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      setState(() { _features = decoded['features'] as List<dynamic>; });
    } catch (e) {
      debugPrint('GeoJSON load error: \$e');
    }
  }

  RiskMapEntry? _getEntry(String id, List<RiskMapEntry> entries) {
    try { return entries.firstWhere((e) => e.district == id); }
    catch (_) { return null; }
  }

  List<LatLng> _toLatLng(List<dynamic> coords) {
    return coords.map((c) => LatLng(
      (c[1] as num).toDouble(),
      (c[0] as num).toDouble(),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final riskMapAsync = ref.watch(riskMapProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 800;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _buildToolbar(compact),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: riskMapAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),
                    error: (e, _) => Center(child: Text('Error: \$e')),
                    data: (rm) => _buildMap(rm, compact),
                  ),
                ),
                _selectedEntry != null && !compact
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: DistrictPopup(
                        district: _selectedEntry!,
                        onClose: () => setState(() => _selectedEntry = null),
                      ),
                    )
                  : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool compact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Text('Pakistan Risk Map', style: AppTextStyles.headingMedium),
          const SizedBox(width: 24),
          compact ? const SizedBox.shrink() : Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppCrops.all.map((crop) {
                  final sel = _selectedCrop == crop['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(crop['label']!),
                      selected: sel,
                      onSelected: (_) => setState(() => _selectedCrop = crop['id']!),
                      selectedColor: AppColors.deepGreen,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(color: sel ? Colors.white : AppColors.darkText, fontSize: 13),
                      backgroundColor: AppColors.grey100,
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => ref.refresh(riskMapProvider),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.deepGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildMap(RiskMapResponse riskMap, bool compact) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(MapConstants.pakistanLat, MapConstants.pakistanLng),
            initialZoom: MapConstants.defaultZoom,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            onTap: (_, __) => setState(() => _selectedEntry = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cropsense',
            ),
            PolygonLayer(
              polygons: _buildPolygons(riskMap.districts),
            ),
          ],
        ),
        Positioned(
          left: 16, bottom: 16,
          child: const MapLegend(),
        ),
        _selectedEntry != null && compact
          ? Positioned(
              left: 16, right: 16, bottom: 16,
              child: DistrictPopup(
                district: _selectedEntry!,
                onClose: () => setState(() => _selectedEntry = null),
              ),
            )
          : const SizedBox.shrink(),
      ],
    );
  }

  List<Polygon> _buildPolygons(List<RiskMapEntry> entries) {
    final polygons = <Polygon>[];
    for (final feature in _features) {
      final props = feature['properties'] as Map<String, dynamic>;
      final districtId = props['district'] as String;
      final entry = _getEntry(districtId, entries);
      final isSelected = _selectedEntry?.district == districtId;
      final fillColor = entry != null
          ? riskColor(entry.riskLevel.name).withValues(alpha: 0.65)
          : AppColors.grey400.withValues(alpha: 0.4);
      final borderColor = isSelected
          ? Colors.white
          : (entry != null ? riskColor(entry.riskLevel.name) : AppColors.grey400);
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final geoType = geometry['type'] as String;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      if (geoType == 'Polygon') {
        final pts = _toLatLng(coordinates[0] as List<dynamic>);
        polygons.add(Polygon(
          points: pts,
          color: fillColor,
          borderColor: borderColor,
          borderStrokeWidth: isSelected ? 3.0 : 1.5,
        ));
      } else if (geoType == 'MultiPolygon') {
        for (final poly in coordinates) {
          final pts = _toLatLng((poly as List<dynamic>)[0] as List<dynamic>);
          polygons.add(Polygon(
            points: pts,
            color: fillColor,
            borderColor: borderColor,
            borderStrokeWidth: isSelected ? 3.0 : 1.5,
          ));
        }
      }
    }
    return polygons;
  }
}
