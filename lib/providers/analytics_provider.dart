import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cropsense/app.dart';

@immutable
class AnalyticsFilters {
  final String district;
  final String crop;
  final String season;
  final int startYear;
  final int endYear;
  final String soilType;
  final double farmAcres;

  const AnalyticsFilters({
    required this.district,
    required this.crop,
    required this.season,
    required this.startYear,
    required this.endYear,
    required this.soilType,
    required this.farmAcres,
  });

  AnalyticsFilters copyWith({
    String? district,
    String? crop,
    String? season,
    int? startYear,
    int? endYear,
    String? soilType,
    double? farmAcres,
  }) {
    return AnalyticsFilters(
      district: district ?? this.district,
      crop: crop ?? this.crop,
      season: season ?? this.season,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      soilType: soilType ?? this.soilType,
      farmAcres: farmAcres ?? this.farmAcres,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticsFilters &&
        other.district == district &&
        other.crop == crop &&
        other.season == season &&
        other.startYear == startYear &&
        other.endYear == endYear &&
        other.soilType == soilType &&
        other.farmAcres == farmAcres;
  }

  @override
  int get hashCode => Object.hash(
        district,
        crop,
        season,
        startYear,
        endYear,
        soilType,
        farmAcres,
      );
}

final analyticsProvider = AsyncNotifierProviderFamily<AnalyticsNotifier,
    Map<String, dynamic>, AnalyticsFilters>(AnalyticsNotifier.new);

class AnalyticsNotifier
    extends FamilyAsyncNotifier<Map<String, dynamic>, AnalyticsFilters> {
  @override
  Future<Map<String, dynamic>> build(AnalyticsFilters arg) async {
    final api = ref.read(apiServiceProvider);
    try {
      return await api.getAnalyticsSummary(
        district: arg.district,
        crop: arg.crop,
        season: arg.season,
        startYear: arg.startYear,
        endYear: arg.endYear,
        soilType: arg.soilType,
        farmAcres: arg.farmAcres,
      );
    } catch (e) {
      return _fallback(arg, e);
    }
  }
}

Map<String, dynamic> _fallback(AnalyticsFilters filters, Object error) => {
      'district': filters.district,
      'farmAcres': filters.farmAcres,
      'yearRange': '${filters.startYear}-${filters.endYear}',
      'isDemoData': true,
      'dataSource': 'Offline fallback. Backend analytics could not be reached.',
      'dataQuality': {
        'message': 'Check that the FastAPI backend is running.',
        'technical': error.toString(),
      },
      'filters': {
        'crop': filters.crop,
        'season': filters.season,
        'startYear': filters.startYear,
        'endYear': filters.endYear,
        'soilType': filters.soilType,
        'farmAcres': filters.farmAcres,
      },
      'summary': {
        'bestPerformingCrop': filters.crop,
        'mostProfitableCrop': filters.crop,
        'highestRiskCrop': filters.crop,
        'averageYield': 0.0,
        'expectedProfitPerAcre': 0,
        'probabilityOfLoss': 0.0,
        'mainWeatherRisk': 'unknown',
        'aiRecommendation':
            'Analytics are unavailable because the backend did not respond.',
      },
      'cropPerformance': {'rows': <Map<String, dynamic>>[]},
      'selectedCrop': {
        'crop': filters.crop,
        'cropLabel': filters.crop,
        'descriptiveStats': <String, dynamic>{},
        'probabilities': <String, dynamic>{},
        'correlations': <String, dynamic>{},
        'regression': {'available': false},
        'multiFactorRegression': {'available': false},
        'yearly': <Map<String, dynamic>>[],
      },
      'yieldTrend': {
        'yearly': <Map<String, dynamic>>[],
        'descriptiveStats': <String, dynamic>{},
        'regression': {'available': false},
        'multiFactorRegression': {'available': false},
        'confidenceInterval': {'available': false},
      },
      'costProfit': {
        'cropRows': <Map<String, dynamic>>[],
        'yearly': <Map<String, dynamic>>[],
        'confidenceInterval': {'available': false},
      },
      'weatherImpact': {
        'yearly': <Map<String, dynamic>>[],
        'correlations': <String, dynamic>{},
      },
      'riskProbability': {
        'probabilities': <String, dynamic>{},
        'riskLevel': 'unknown',
      },
      'statisticalTesting': <String, dynamic>{},
      'aiInsights': {
        'farmerSummary': 'No insight available while offline.',
        'bullets': <String>[],
        'recommendation':
            'Start the backend and refresh this page to load analytics.',
      },
      'crops': <String, dynamic>{},
    };
