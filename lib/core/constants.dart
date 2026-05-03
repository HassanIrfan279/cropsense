// lib/core/constants.dart
//
// CropSense Global Constants
// ─────────────────────────────────────────────────────────────────────────
// All fixed values that are referenced across multiple files live here.
// Import with: import 'package:cropsense/core/constants.dart';

// ─────────────────────────────────────────────────────────────────────────
// RESPONSIVE LAYOUT BREAKPOINTS
// These determine when the layout switches between compact/standard/wide.
// See adaptive_layout.dart for how these are used.
// ─────────────────────────────────────────────────────────────────────────
class AppBreakpoints {
  static const double compact = 800.0; // Below this: mobile/narrow layout
  static const double wide = 1200.0; // Above this: wide desktop layout
}

// ─────────────────────────────────────────────────────────────────────────
// API ENDPOINTS
// All FastAPI backend routes live here.
// The base URL is loaded from compile-time dart defines (see AppConfig).
// ─────────────────────────────────────────────────────────────────────────
class ApiEndpoints {
  static const String districts = '/api/districts';
  static const String riskMap = '/api/risk-map';
  static const String provinces = '/api/provinces';
  static const String predict = '/api/predict';
  static const String aiAdvise = '/api/ai-advise';
  static const String futurePrediction = '/api/future-prediction';

  // These use path parameters filled in at call time:
  // e.g. '/api/yield/lahore/wheat'
  static String yieldData(String district, String crop) =>
      '/api/yield/$district/$crop';
  static String riskMapFor(String crop, int year) =>
      '/api/risk-map?crop=$crop&year=$year';
  static String ndviTimeseries(String district) =>
      '/api/ndvi-timeseries/$district';
  static String stats(String district) => '/api/stats/$district';
  static String statsCrop(String district, String crop) =>
      '/api/stats/$district/$crop';
  static String weather(String district) => '/api/weather/$district';
  static String compare(String d1, String d2, String crop) =>
      '/api/compare?district1=$d1&district2=$d2&crop=$crop';

  static String analyticsSummary(String district, double farmAcres) =>
      '/api/analytics/summary/$district?farm_acres=$farmAcres';
}

// ─────────────────────────────────────────────────────────────────────────
// CACHE KEYS (Hive offline cache)
// Format: "table_district_crop" style.
// ─────────────────────────────────────────────────────────────────────────
class CacheKeys {
  static const String districtList = 'districts_all';
  static const String riskMap = 'risk_map';

  static String districtDetail(String id) => 'district_$id';
  static String aiAdvice(String district, String crop) =>
      'ai_${district}_$crop';
  static String yield_(String district, String crop) =>
      'yield_${district}_$crop';
  static String ndvi(String district) => 'ndvi_$district';
  static String stats(String district) => 'stats_$district';
  static String weather(String district) => 'weather_$district';
  static String comparison(String d1, String d2, String crop) =>
      'compare_${d1}_${d2}_$crop';
}

// ─────────────────────────────────────────────────────────────────────────
// CACHE DURATIONS
// How long each cached item is considered "fresh" before we re-fetch.
// ─────────────────────────────────────────────────────────────────────────
class CacheDurations {
  static const Duration districtList = Duration(hours: 24);
  static const Duration riskMap =
      Duration(seconds: 0); // disabled — always fetch live
  static const Duration aiAdvice = Duration(hours: 6);
  static const Duration yieldData =
      Duration(seconds: 0); // disabled — always fetch live
  static const Duration ndvi = Duration(hours: 12);
  static const Duration weather = Duration(minutes: 30);
  static const Duration comparison = Duration(hours: 6);
}

// ─────────────────────────────────────────────────────────────────────────
// CROPS
// The 5 main crops tracked in CropSense.
// The id is used in API calls; the label is shown in the UI.
// ─────────────────────────────────────────────────────────────────────────
class AppCrops {
  static const List<Map<String, String>> all = [
    {'id': 'wheat', 'label': 'Wheat', 'urdu': 'گندم'},
    {'id': 'rice', 'label': 'Rice', 'urdu': 'چاول'},
    {'id': 'cotton', 'label': 'Cotton', 'urdu': 'کپاس'},
    {'id': 'sugarcane', 'label': 'Sugarcane', 'urdu': 'گنا'},
    {'id': 'maize', 'label': 'Maize', 'urdu': 'مکئی'},
  ];

  static List<String> get ids => all.map((c) => c['id']!).toList();
  static List<String> get labels => all.map((c) => c['label']!).toList();
}

// ─────────────────────────────────────────────────────────────────────────
// PAKISTAN PROVINCES
// ─────────────────────────────────────────────────────────────────────────
class AppProvinces {
  static const List<String> all = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// PAKISTAN DISTRICTS
// 36 major agricultural districts across all provinces.
// The id is lowercase-hyphenated for API calls.
// ─────────────────────────────────────────────────────────────────────────
class AppDistricts {
  static const List<Map<String, String>> all = [
    // Punjab (major agricultural districts)
    {'id': 'lahore', 'label': 'Lahore', 'province': 'Punjab'},
    {'id': 'faisalabad', 'label': 'Faisalabad', 'province': 'Punjab'},
    {'id': 'multan', 'label': 'Multan', 'province': 'Punjab'},
    {'id': 'rawalpindi', 'label': 'Rawalpindi', 'province': 'Punjab'},
    {'id': 'gujranwala', 'label': 'Gujranwala', 'province': 'Punjab'},
    {'id': 'sialkot', 'label': 'Sialkot', 'province': 'Punjab'},
    {'id': 'bahawalpur', 'label': 'Bahawalpur', 'province': 'Punjab'},
    {'id': 'sargodha', 'label': 'Sargodha', 'province': 'Punjab'},
    {'id': 'sheikhupura', 'label': 'Sheikhupura', 'province': 'Punjab'},
    {'id': 'jhang', 'label': 'Jhang', 'province': 'Punjab'},
    {'id': 'vehari', 'label': 'Vehari', 'province': 'Punjab'},
    {'id': 'sahiwal', 'label': 'Sahiwal', 'province': 'Punjab'},
    {'id': 'okara', 'label': 'Okara', 'province': 'Punjab'},
    {'id': 'kasur', 'label': 'Kasur', 'province': 'Punjab'},

    // Sindh
    {'id': 'karachi', 'label': 'Karachi', 'province': 'Sindh'},
    {'id': 'hyderabad', 'label': 'Hyderabad', 'province': 'Sindh'},
    {'id': 'sukkur', 'label': 'Sukkur', 'province': 'Sindh'},
    {'id': 'larkana', 'label': 'Larkana', 'province': 'Sindh'},
    {'id': 'nawabshah', 'label': 'Nawabshah', 'province': 'Sindh'},
    {'id': 'mirpur-khas', 'label': 'Mirpur Khas', 'province': 'Sindh'},
    {'id': 'tharparkar', 'label': 'Tharparkar', 'province': 'Sindh'},
    {'id': 'kashmore', 'label': 'Kashmore', 'province': 'Sindh'},

    // Khyber Pakhtunkhwa
    {'id': 'peshawar', 'label': 'Peshawar', 'province': 'Khyber Pakhtunkhwa'},
    {'id': 'mardan', 'label': 'Mardan', 'province': 'Khyber Pakhtunkhwa'},
    {'id': 'swat', 'label': 'Swat', 'province': 'Khyber Pakhtunkhwa'},
    {
      'id': 'abbottabad',
      'label': 'Abbottabad',
      'province': 'Khyber Pakhtunkhwa'
    },
    {'id': 'charsadda', 'label': 'Charsadda', 'province': 'Khyber Pakhtunkhwa'},
    {
      'id': 'dera-ismail-khan',
      'label': 'Dera Ismail Khan',
      'province': 'Khyber Pakhtunkhwa'
    },

    // Balochistan
    {'id': 'quetta', 'label': 'Quetta', 'province': 'Balochistan'},
    {'id': 'turbat', 'label': 'Turbat', 'province': 'Balochistan'},
    {'id': 'khuzdar', 'label': 'Khuzdar', 'province': 'Balochistan'},
    {'id': 'hub', 'label': 'Hub', 'province': 'Balochistan'},
    {'id': 'loralai', 'label': 'Loralai', 'province': 'Balochistan'},
    {'id': 'zhob', 'label': 'Zhob', 'province': 'Balochistan'},
    {'id': 'naseerabad', 'label': 'Naseerabad', 'province': 'Balochistan'},
    {'id': 'sibi', 'label': 'Sibi', 'province': 'Balochistan'},
  ];

  static List<String> get ids => all.map((d) => d['id']!).toList();
  static List<String> get labels => all.map((d) => d['label']!).toList();

  // Get all districts for a specific province
  static List<Map<String, String>> byProvince(String province) =>
      all.where((d) => d['province'] == province).toList();
}

// ─────────────────────────────────────────────────────────────────────────
// SYMPTOMS (used in AI Advisor symptom selector)
// ─────────────────────────────────────────────────────────────────────────
class AppSymptoms {
  static const List<Map<String, dynamic>> all = [
    {
      'id': 'leaf_yellowing',
      'label': 'Leaf Yellowing',
      'urdu': 'پتوں کا پیلا پڑنا',
      'icon': 'warning_amber',
    },
    {
      'id': 'brown_spots',
      'label': 'Brown Spots',
      'urdu': 'بھورے دھبے',
      'icon': 'blur_on',
    },
    {
      'id': 'wilting',
      'label': 'Wilting',
      'urdu': 'مرجھانا',
      'icon': 'local_florist',
    },
    {
      'id': 'pest_damage',
      'label': 'Pest Damage',
      'urdu': 'کیڑوں کا نقصان',
      'icon': 'bug_report',
    },
    {
      'id': 'stunted_growth',
      'label': 'Stunted Growth',
      'urdu': 'کم بڑھوتری',
      'icon': 'trending_down',
    },
    {
      'id': 'rust_patches',
      'label': 'Rust Patches',
      'urdu': 'زنگ کے دھبے',
      'icon': 'texture',
    },
    {
      'id': 'no_symptoms',
      'label': 'No Symptoms',
      'urdu': 'کوئی علامت نہیں',
      'icon': 'check_circle',
    },
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// MAP CENTER (Pakistan geographic center)
// Used to initialize the flutter_map camera position.
// ─────────────────────────────────────────────────────────────────────────
class MapConstants {
  static const double pakistanLat = 30.3753;
  static const double pakistanLng = 69.3451;
  static const double defaultZoom = 5.5;
  static const double minZoom = 4.0;
  static const double maxZoom = 10.0;
}

// ─────────────────────────────────────────────────────────────────────────
// DATA YEAR RANGE
// Historical data available from 2005 to current year.
// ─────────────────────────────────────────────────────────────────────────
class DataConstants {
  static const int startYear = 2005;
  static const int endYear = 2023;
}
