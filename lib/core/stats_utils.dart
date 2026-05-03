import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:cropsense/config/app_config.dart';

class RegressionResult {
  final double slope, intercept, rSquared, pValue, stdError;
  const RegressionResult({
    required this.slope,
    required this.intercept,
    required this.rSquared,
    required this.pValue,
    required this.stdError,
  });
}

class TTestResult {
  final double tStat, pValue, df, cohensD;
  const TTestResult({
    required this.tStat,
    required this.pValue,
    required this.df,
    required this.cohensD,
  });
}

class ConfidenceInterval {
  final double lower, upper, mean;
  const ConfidenceInterval({
    required this.lower,
    required this.upper,
    required this.mean,
  });
}

class BoxPlotStats {
  final double min, q1, median, q3, max;
  final List<double> outliers;
  const BoxPlotStats({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    required this.outliers,
  });
}

abstract class StatsUtils {
  static double mean(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  static double median(List<double> data) {
    if (data.isEmpty) return 0;
    final s = List<double>.from(data)..sort();
    final n = s.length;
    return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
  }

  static double variance(List<double> data) {
    if (data.length < 2) return 0;
    final m = mean(data);
    return data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b) /
        (data.length - 1);
  }

  static double standardDeviation(List<double> data) =>
      math.sqrt(variance(data));

  static double coefficientOfVariation(List<double> data) {
    final m = mean(data);
    return m == 0 ? 0 : (standardDeviation(data) / m) * 100;
  }

  static double skewness(List<double> data) {
    if (data.length < 3) return 0;
    final n = data.length;
    final m = mean(data);
    final s = standardDeviation(data);
    if (s == 0) return 0;
    final sum = data
        .map((x) => math.pow((x - m) / s, 3).toDouble())
        .reduce((a, b) => a + b);
    return (n / ((n - 1) * (n - 2))) * sum;
  }

  static double kurtosis(List<double> data) {
    if (data.length < 4) return 0;
    final n = data.length;
    final m = mean(data);
    final s = standardDeviation(data);
    if (s == 0) return 0;
    final sum4 = data
        .map((x) => math.pow((x - m) / s, 4).toDouble())
        .reduce((a, b) => a + b);
    final k = (n.toDouble() * (n + 1)) / ((n - 1) * (n - 2) * (n - 3)) * sum4;
    return k - 3.0 * (n - 1) * (n - 1) / ((n - 2) * (n - 3));
  }

  static double iqr(List<double> data) {
    if (data.length < 4) return 0;
    final s = List<double>.from(data)..sort();
    final n = s.length;
    return s[(n * 3) ~/ 4] - s[n ~/ 4];
  }

  static double pearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0;
    final mx = mean(x), my = mean(y);
    double num = 0, denX = 0, denY = 0;
    for (int i = 0; i < x.length; i++) {
      num += (x[i] - mx) * (y[i] - my);
      denX += (x[i] - mx) * (x[i] - mx);
      denY += (y[i] - my) * (y[i] - my);
    }
    final den = math.sqrt(denX * denY);
    return den == 0 ? 0 : num / den;
  }

  static double spearmanCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0;
    final n = x.length;
    final rx = _ranks(x), ry = _ranks(y);
    double d2 = 0;
    for (int i = 0; i < n; i++) {
      final d = rx[i] - ry[i];
      d2 += d * d;
    }
    return 1 - (6 * d2) / (n * (n * n - 1));
  }

  static List<int> _ranks(List<double> data) {
    final indexed = data.asMap().entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final ranks = List<int>.filled(data.length, 0);
    for (int i = 0; i < indexed.length; i++) {
      ranks[indexed[i].key] = i + 1;
    }
    return ranks;
  }

  static RegressionResult linearRegression(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) {
      return const RegressionResult(
          slope: 0, intercept: 0, rSquared: 0, pValue: 1, stdError: 0);
    }
    final n = x.length.toDouble();
    final mx = mean(x), my = mean(y);
    double sxy = 0, sxx = 0;
    for (int i = 0; i < x.length; i++) {
      sxy += (x[i] - mx) * (y[i] - my);
      sxx += (x[i] - mx) * (x[i] - mx);
    }
    final slope = sxx == 0 ? 0.0 : sxy / sxx;
    final intercept = my - slope * mx;

    double ssTot = 0, ssRes = 0;
    for (int i = 0; i < x.length; i++) {
      ssTot += (y[i] - my) * (y[i] - my);
      ssRes += (y[i] - (slope * x[i] + intercept)) *
          (y[i] - (slope * x[i] + intercept));
    }
    final rSquared = ssTot == 0 ? 0.0 : 1.0 - (ssRes / ssTot);

    final df = n - 2;
    final mse = df > 0 ? ssRes / df : 0;
    final seSlope = sxx == 0 ? 0.0 : math.sqrt(mse / sxx);
    final tStat = seSlope == 0 ? 0.0 : slope / seSlope;
    final pVal = _tPValue(tStat, df);

    return RegressionResult(
      slope: slope,
      intercept: intercept,
      rSquared: rSquared,
      pValue: pVal,
      stdError: seSlope,
    );
  }

  static TTestResult tTest(List<double> data, double populationMean) {
    if (data.length < 2) {
      return const TTestResult(tStat: 0, pValue: 1, df: 0, cohensD: 0);
    }
    final n = data.length.toDouble();
    final m = mean(data);
    final s = standardDeviation(data);
    final se = s / math.sqrt(n);
    final tStat = se == 0 ? 0.0 : (m - populationMean) / se;
    final df = n - 1;
    return TTestResult(
      tStat: tStat,
      pValue: _tPValue(tStat, df),
      df: df,
      cohensD: s == 0 ? 0.0 : (m - populationMean) / s,
    );
  }

  static ConfidenceInterval confidenceInterval(
      List<double> data, double confidence) {
    if (data.length < 2) {
      return const ConfidenceInterval(lower: 0, upper: 0, mean: 0);
    }
    final m = mean(data);
    final se = standardDeviation(data) / math.sqrt(data.length.toDouble());
    final z = confidence >= 0.99
        ? 2.576
        : confidence >= 0.95
            ? 1.96
            : 1.645;
    return ConfidenceInterval(lower: m - z * se, upper: m + z * se, mean: m);
  }

  static double normalPDF(double x, double mu, double sigma) {
    if (sigma == 0) return 0;
    final z = (x - mu) / sigma;
    return math.exp(-0.5 * z * z) / (sigma * math.sqrt(2 * math.pi));
  }

  static double normalCDF(double x, double mu, double sigma) {
    if (sigma == 0) return x >= mu ? 1.0 : 0.0;
    final z = (x - mu) / (sigma * math.sqrt(2));
    return 0.5 * (1 + _erf(z));
  }

  // Abramowitz & Stegun 7.1.26 — max error < 2.5e-4
  static double _erf(double x) {
    const t1 = 0.3480242, t2 = -0.0958798, t3 = 0.7478556;
    final t = 1.0 / (1.0 + 0.47047 * x.abs());
    final poly = t * (t1 + t * (t2 + t * t3));
    final result = 1.0 - poly * math.exp(-x * x);
    return x >= 0 ? result : -result;
  }

  static List<int> outlierDetection(List<double> data) {
    if (data.length < 4) return [];
    final s = List<double>.from(data)..sort();
    final n = s.length;
    final q1 = s[n ~/ 4], q3 = s[(n * 3) ~/ 4];
    final fence = 1.5 * (q3 - q1);
    return data
        .asMap()
        .entries
        .where((e) => e.value < q1 - fence || e.value > q3 + fence)
        .map((e) => e.key)
        .toList();
  }

  static double yieldExceedanceProbability(
      double threshold, List<double> data) {
    if (data.isEmpty) return 0;
    return data.where((y) => y > threshold).length / data.length;
  }

  // Naive Bayes drought probability given NDVI and rainfall
  static double droughtProbability(
      double ndvi, double rainfall, List<double> historicalYields) {
    if (historicalYields.isEmpty) return 0.3;
    final prior =
        historicalYields.where((y) => y < 1.2).length / historicalYields.length;
    final ndviFactor = (1.0 - ndvi).clamp(0.0, 1.0);
    final rainFactor = (1.0 - (rainfall / 500.0)).clamp(0.0, 1.0);
    final likelihood = 0.5 + 0.3 * ndviFactor + 0.2 * rainFactor;
    return (prior * likelihood).clamp(0.0, 0.99);
  }

  static BoxPlotStats boxPlot(List<double> data) {
    if (data.isEmpty) {
      return const BoxPlotStats(
          min: 0, q1: 0, median: 0, q3: 0, max: 0, outliers: []);
    }
    final s = List<double>.from(data)..sort();
    final n = s.length;
    final q1 = s[n ~/ 4], q3 = s[(n * 3) ~/ 4];
    final fence = 1.5 * (q3 - q1);
    final whiskerMin =
        s.firstWhere((v) => v >= q1 - fence, orElse: () => s.first);
    final whiskerMax =
        s.lastWhere((v) => v <= q3 + fence, orElse: () => s.last);
    final outliers = s.where((v) => v < whiskerMin || v > whiskerMax).toList();
    return BoxPlotStats(
        min: whiskerMin,
        q1: q1,
        median: median(data),
        q3: q3,
        max: whiskerMax,
        outliers: outliers);
  }

  static double mannWhitneyU(List<double> x, List<double> y) {
    int u = 0;
    for (final xi in x) {
      for (final yj in y) {
        if (xi > yj) u++;
      }
    }
    return u.toDouble();
  }

  // Two-tailed p-value — normal approx for df>30, beta-regularized otherwise
  static double _tPValue(double t, double df) {
    if (df <= 0) return 1.0;
    if (df > 30) {
      return (2 * (1 - normalCDF(t.abs(), 0, 1))).clamp(0.0001, 1.0);
    }
    final x = df / (df + t * t);
    return _betaInc(x, df / 2, 0.5).clamp(0.0001, 1.0);
  }

  // Regularized incomplete beta I_x(a,b) via Lentz continued fractions
  static double _betaInc(double x, double a, double b) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    final front =
        math.exp(math.log(x) * a + math.log(1 - x) * b - _logBeta(a, b)) / a;
    return front * _betaCF(a, b, x);
  }

  static double _betaCF(double a, double b, double x) {
    double c = 1.0, d = 1.0 - (a + b) * x / (a + 1);
    if (d.abs() < 1e-30) d = 1e-30;
    d = 1.0 / d;
    double res = d;
    for (int m = 1; m <= 100; m++) {
      double aa = m * (b - m) * x / ((a + 2 * m - 1) * (a + 2 * m));
      d = 1 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1 / d;
      res *= d * c;
      aa = -(a + m) * (a + b + m) * x / ((a + 2 * m) * (a + 2 * m + 1));
      d = 1 + aa * d;
      if (d.abs() < 1e-30) d = 1e-30;
      c = 1 + aa / c;
      if (c.abs() < 1e-30) c = 1e-30;
      d = 1 / d;
      final delta = d * c;
      res *= delta;
      if ((delta - 1).abs() < 3e-7) break;
    }
    return res;
  }

  static double _logBeta(double a, double b) =>
      _logGamma(a) + _logGamma(b) - _logGamma(a + b);

  // Lanczos approximation for log-gamma
  static double _logGamma(double x) {
    const g = 7.0;
    const c = [
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7
    ];
    if (x < 0.5) {
      return math.log(math.pi / math.sin(math.pi * x)) - _logGamma(1 - x);
    }
    final z = x - 1;
    final t = z + g + 0.5;
    double sum = c[0];
    for (int i = 1; i < c.length; i++) {
      sum += c[i] / (z + i);
    }
    return 0.5 * math.log(2 * math.pi) +
        (z + 0.5) * math.log(t) -
        t +
        math.log(sum);
  }

  // Inverse normal CDF (probit) — Beasley-Springer-Moro approximation
  static double inverseCDF(double p) {
    if (p <= 0) return -6;
    if (p >= 1) return 6;
    const a0 = 2.515517, a1 = 0.802853, a2 = 0.010328;
    const b1 = 1.432788, b2 = 0.189269, b3 = 0.001308;
    final q = p < 0.5 ? p : 1 - p;
    final t = math.sqrt(-2 * math.log(q));
    final num = ((a2 * t + a1) * t + a0);
    final den = (((b3 * t + b2) * t + b1) * t + 1);
    final val = t - num / den;
    return p < 0.5 ? -val : val;
  }

  static double chiSquare2x2(int a, int b, int c, int d) {
    final n = (a + b + c + d).toDouble();
    if (n == 0) return 0;
    final r1 = (a + b).toDouble(), r2 = (c + d).toDouble();
    final col1 = (a + c).toDouble(), col2 = (b + d).toDouble();
    if (r1 == 0 || r2 == 0 || col1 == 0 || col2 == 0) return 0;
    double chi2 = 0;
    for (final pair in [
      [a, r1 * col1 / n],
      [b, r1 * col2 / n],
      [c, r2 * col1 / n],
      [d, r2 * col2 / n]
    ]) {
      final o = pair[0].toDouble(), e = pair[1];
      if (e > 0) chi2 += (o - e) * (o - e) / e;
    }
    return chi2;
  }

  static double chiSquarePValue(double chi2) {
    // CDF of chi-square with df=1 via normalCDF
    return 1 -
        normalCDF(math.sqrt(2 * chi2), 0, 1) * 2 +
        (normalCDF(0, 0, 1) * 2 - 1);
    // Simple: P-value = 1 - chi2_cdf(chi2, df=1) ≈ 2*(1 - normalCDF(sqrt(chi2)))
  }

  static double chiSquarePValueDf1(double chi2) {
    if (chi2 <= 0) return 1.0;
    return (2 * (1 - normalCDF(math.sqrt(chi2), 0, 1))).clamp(0.0, 1.0);
  }

  // ── Remote fetch helpers ────────────────────────────────────────────────
  static Dio? _dio;
  static Dio get _client {
    _dio ??= Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    return _dio!;
  }

  static Future<Map<String, dynamic>?> fetchDistrictStats(
      String district, String crop) async {
    try {
      final resp = await _client.get('/api/stats/$district/$crop');
      return resp.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchComparison(
      String district1, String district2, String crop) async {
    try {
      final resp = await _client.get(
          '/api/compare?district1=$district1&district2=$district2&crop=$crop');
      return resp.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
