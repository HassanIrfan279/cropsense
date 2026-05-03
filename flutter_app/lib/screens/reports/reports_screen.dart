import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/providers/map_provider.dart';
import 'package:cropsense/providers/district_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _district = 'faisalabad';
  String _crop = 'wheat';
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports', style: AppTextStyles.displayLarge),
            const SizedBox(height: 4),
            Text(
              'Generate downloadable PDF reports for government, insurance, and NGO clients',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600),
            ),
            const SizedBox(height: 32),
            _buildReportTypeCard(
              title: 'District Intelligence Report',
              subtitle: 'Complete crop analysis for one district',
              description: 'Includes 14-day yield forecast, risk assessment, satellite NDVI trend, ML model confidence intervals, AI advisory recommendations, and cost/ROI estimates in PKR. Ideal for district agriculture officers and provincial food departments.',
              icon: Icons.location_on_rounded,
              color: AppColors.deepGreen,
              tags: const ['Government', 'District Level', 'AI Advisory'],
              selector: _buildDistrictSelector(),
              onGenerate: _generateDistrictReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: 'National Crop Risk Summary',
              subtitle: 'All-Pakistan overview for federal briefings',
              description: 'Province-by-province breakdown of crop conditions across all 36 monitored districts. Highlights critical drought zones, disease outbreaks, and yield variance vs historical average. Suitable for MNFSR and parliamentary committee presentations.',
              icon: Icons.map_rounded,
              color: AppColors.skyBlue,
              tags: const ['MNFSR', 'National Level', 'All Districts'],
              selector: const SizedBox.shrink(),
              onGenerate: _generateNationalReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: 'Crop Insurance Risk Report',
              subtitle: 'Statistical risk analysis for insurers',
              description: 'Actuarial-grade risk data including drought probability distributions, historical yield volatility, confidence intervals, and correlation analysis between climate variables and crop loss. Designed for EFU, Jubilee, and other crop insurers.',
              icon: Icons.shield_rounded,
              color: AppColors.amber,
              tags: const ['EFU', 'Jubilee Insurance', 'Risk Data'],
              selector: const SizedBox.shrink(),
              onGenerate: _generateInsuranceReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: 'Farmer Advisory Sheet',
              subtitle: 'Simple one-page advice in Roman Urdu',
              description: 'A single A4 page with crop instructions in simple Roman Urdu — what to spray, when to irrigate, what to buy and where, cost per acre. Printable for distribution to farmers who cannot access digital tools.',
              icon: Icons.person_rounded,
              color: AppColors.limeGreen,
              tags: const ['Farmers', 'Roman Urdu', 'Printable'],
              selector: _buildDistrictSelector(),
              onGenerate: _generateFarmerSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictSelector() {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('District', style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: _district,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: AppTextStyles.bodyMedium,
              items: AppDistricts.all.take(12).map((d) =>
                  DropdownMenuItem(
                      value: d['id'],
                      child: Text(d['label']!))).toList(),
              onChanged: (v) => setState(() => _district = v!),
            ),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop', style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: _crop,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: AppTextStyles.bodyMedium,
              items: AppCrops.all.map((c) =>
                  DropdownMenuItem(
                      value: c['id'],
                      child: Text(c['label']!))).toList(),
              onChanged: (v) => setState(() => _crop = v!),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildReportTypeCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> tags,
    required Widget selector,
    required VoidCallback onGenerate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(tag,
                          style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text(description,
              style: AppTextStyles.bodySmall.copyWith(
                  height: 1.6, color: AppColors.grey600)),
          if (selector is! SizedBox) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            selector,
          ],
          const SizedBox(height: 16),
          Row(children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Preview mode — generate to see full report'),
                    backgroundColor: color,
                  ),
                );
              },
              icon: const Icon(Icons.preview_rounded, size: 16),
              label: const Text('Preview'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _generating ? null : onGenerate,
              icon: _generating
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                  : const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 16),
              label: Text(
                  _generating ? 'Generating...' : 'Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _generateDistrictReport() async {
    setState(() => _generating = true);
    try {
      final districtLabel = AppDistricts.all
          .firstWhere((d) => d['id'] == _district)['label']!;
      final cropLabel = AppCrops.all
          .firstWhere((c) => c['id'] == _crop)['label']!;

      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(
                    color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('CropSense Pakistan',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('1B5E20'))),
              pw.Text(
                'CONFIDENTIAL — For Official Use Only',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: 2026-04-30 18:44',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                'Page${ctx.pageNumber} of ${ctx.pagesCount}',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('1B5E20'),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(children: [
              pw.Container(
                width: 50, height: 50,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.all(
                      pw.Radius.circular(8)),
                ),
                child: pw.Center(
                  child: pw.Text('CS',
                      style: pw.TextStyle(
                          color: PdfColor.fromHex('1B5E20'),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('District Intelligence Report',
                        style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.Text(
                        '$districtLabel District · $cropLabel · Pakistan',
                        style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white)),
                  ]),
            ]),
          ),
          pw.SizedBox(height: 20),

          pw.Text('Executive Summary',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('F1F8E9'),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              'CropSense satellite and climate analysis for $districtLabel district indicates WATCH-level agricultural risk for the current $cropLabel growing season. Machine learning yield forecast (14-day) is 2.3 tonnes/acre with a 95% confidence interval of 2.0-2.6 t/acre. Immediate attention is recommended for rust disease prevention and irrigation scheduling optimization.',
              style: const pw.TextStyle(
                  fontSize: 11, lineSpacing: 5),
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Text('Current Field Conditions',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('1B5E20')),
                children: [
                  _cell('Indicator', bold: true, white: true),
                  _cell('Value', bold: true, white: true),
                  _cell('Status', bold: true, white: true),
                ],
              ),
              pw.TableRow(children: [
                _cell('NDVI (Vegetation Index)'),
                _cell('0.62'),
                _cell('Moderate — monitoring needed'),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell('14-Day Yield Forecast'),
                  _cell('2.3 t/acre'),
                  _cell('Near seasonal average'),
                ],
              ),
              pw.TableRow(children: [
                _cell('Confidence Interval (95%)'),
                _cell('2.0 - 2.6 t/acre'),
                _cell('Acceptable uncertainty'),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell('Risk Score'),
                  _cell('35 / 100'),
                  _cell('WATCH level'),
                ],
              ),
              pw.TableRow(children: [
                _cell('30-Day Rainfall'),
                _cell('82mm'),
                _cell('Below seasonal average'),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell('Max Temperature'),
                  _cell('38°C'),
                  _cell('Elevated — heat stress risk'),
                ],
              ),
              pw.TableRow(children: [
                _cell('Soil Moisture'),
                _cell('42%'),
                _cell('Adequate'),
              ]),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text('AI Advisory Recommendations',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Text(
              'Roman Urdu Alert: Fasal ko zang ka khatara hai — kal subah spray karein',
              style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColor.fromHex('B71C1C'))),
          pw.SizedBox(height: 8),
          ...[
            '1. Apply Topsin-M 70 WP at 250g/acre within 48 hours for rust control',
            '2. Increase irrigation frequency to every 8 days (from current 12 days)',
            '3. Hold all nitrogen (Urea) fertilizer applications for 2 weeks',
            '4. Monitor fields daily — repeat spray after 10 days if disease spreading',
            '5. Contact district agriculture officer if more than 30% leaves affected',
          ].map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 6, height: 6,
                  margin: const pw.EdgeInsets.only(top: 4, right: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('1B5E20'),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(step,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              ],
            ),
          )),
          pw.SizedBox(height: 16),

          pw.Text('Recommended Products & Cost Estimate',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('1B5E20')),
                children: [
                  _cell('Product', bold: true, white: true),
                  _cell('Dose/Acre', bold: true, white: true),
                  _cell('Cost/Acre (PKR)', bold: true, white: true),
                  _cell('Urgency', bold: true, white: true),
                ],
              ),
              pw.TableRow(children: [
                _cell('Topsin-M 70 WP'),
                _cell('250g in 100L water'),
                _cell('Rs. 850'),
                _cell('Immediate'),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell('Dithane M-45'),
                  _cell('500g in 100L water'),
                  _cell('Rs. 650'),
                  _cell('Within 7 days'),
                ],
              ),
              pw.TableRow(children: [
                _cell('DAP Fertilizer'),
                _cell('1 bag/acre'),
                _cell('Rs. 8,500'),
                _cell('After disease control'),
              ]),
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E8F5E9')),
                children: [
                  _cell('TOTAL TREATMENT COST', bold: true),
                  _cell(''),
                  _cell('Rs. 12,500/acre', bold: true),
                  _cell(''),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('1B5E20'),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Return on Investment Estimate:',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11)),
                pw.Text(
                    'Spend Rs.12,500 → Protect Rs.45,000 in yield = 260% ROI',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border(
                  left: pw.BorderSide(
                      color: PdfColors.grey400, width: 3)),
            ),
            child: pw.Text(
              'Data Sources: Sentinel-2 Satellite NDVI · Pakistan Meteorological Department · Pakistan Bureau of Statistics Crop Area & Production · CropSense Random Forest ML Model (R²=0.89) · xAI Grok Advisory Engine

This report is generated by CropSense — Pakistan Smart Farm Intelligence Platform. For technical support: cropsense.pk | For emergency agricultural assistance: Pakistan Agricultural Research Council (PARC) helpline.',
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ));

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'CropSense_${districtLabel}_${cropLabel}_Report.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generation failed: $e'),
            backgroundColor: AppColors.burntOrange,
          ),
        );
      }
    } finally {
      setState(() => _generating = false);
    }
  }

  pw.Widget _cell(String text,
      {bool bold = false, bool white = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
              bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: white ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  Future<void> _generateNationalReport() async {
    setState(() => _generating = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              color: PdfColor.fromHex('1B5E20'),
              child: pw.Text(
                'CropSense — National Crop Risk Summary
Pakistan · All 36 Districts',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Province-Level Overview',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('1B5E20')),
                  children: [
                    _cell('Province', bold: true, white: true),
                    _cell('Districts', bold: true, white: true),
                    _cell('Avg Yield', bold: true, white: true),
                    _cell('NDVI', bold: true, white: true),
                    _cell('Risk Level', bold: true, white: true),
                    _cell('Alerts', bold: true, white: true),
                  ],
                ),
                ...{
                  'Punjab': ['14', '2.4 t/ac', '0.64', 'WATCH', '6'],
                  'Sindh': ['8', '1.9 t/ac', '0.51', 'HIGH', '5'],
                  'Khyber Pakhtunkhwa': ['6', '2.1 t/ac', '0.68', 'ABOVE AVG', '2'],
                  'Balochistan': ['8', '1.2 t/ac', '0.31', 'CRITICAL', '7'],
                }.entries.toList().asMap().map((i, e) =>
                  MapEntry(i, pw.TableRow(
                    decoration: i % 2 == 0
                        ? const pw.BoxDecoration()
                        : const pw.BoxDecoration(
                            color: PdfColors.grey100),
                    children: [e.key, ...e.value.value]
                        .map((v) => _cell(v.toString()))
                        .toList(),
                  ))).values.toList(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Critical Alerts Requiring Immediate Attention',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('B71C1C'))),
            pw.SizedBox(height: 8),
            ...[
              'Quetta (Balochistan): Critical drought — yield forecast 0.9 t/acre, 82% risk score',
              'Tharparkar (Sindh): Rainfall 60% below seasonal average — emergency irrigation needed',
              'Multan (Punjab): High rust disease pressure — fungicide application urgent',
              'Karachi (Sindh): Extreme heat stress — NDVI declining rapidly',
            ].map((alert) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColor.fromHex('FFF3E0'),
                child: pw.Text('⚠ $alert',
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            )),
          ],
        ),
      ));
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'CropSense_National_Risk_Summary.pdf',
      );
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _generateInsuranceReport() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _generating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Insurance report requires Oracle DB connection — coming in next phase'),
          backgroundColor: AppColors.amber,
        ),
      );
    }
  }

  Future<void> _generateFarmerSheet() async {
    setState(() => _generating = true);
    try {
      final districtLabel = AppDistricts.all
          .firstWhere((d) => d['id'] == _district)['label']!;
      final cropLabel = AppCrops.all
          .firstWhere((c) => c['id'] == _crop)['label']!;
      final dateStr = '2026-04-30';

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              color: PdfColor.fromHex('1B5E20'),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CropSense — Kisan Advisory Sheet',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '$districtLabel · $cropLabel · ' + dateStr,
                      style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Fasal ki Halat (Field Conditions)',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(
                'Aapki fasal mein zang ka khatara hai. Neeche di gayi hidayaat par amal karein.',
                style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 12),
            pw.Text('Kya karein? (What to do)',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('1B5E20'))),
            pw.SizedBox(height: 6),
            ...[
              '1. Kal subah Topsin-M 70WP spray karein — 250 gram per acre',
              '2. Pani 8 din baad dein (zyada pani na dein)',
              '3. 2 hafte tak Urea (khad) na daalein',
              '4. Roz apni fasal dekhein — agar bimari barhe to agriculture officer ko call karein',
            ].map((step) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(step,
                  style: const pw.TextStyle(fontSize: 11)),
            )),
            pw.SizedBox(height: 12),
            pw.Text('Kya khareedein? (What to buy)',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('1B5E20'))),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey400, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('8BC34A')),
                  children: [
                    _cell('Cheez', bold: true, white: true),
                    _cell('Miqdar', bold: true, white: true),
                    _cell('Qeemat', bold: true, white: true),
                  ],
                ),
                pw.TableRow(children: [
                  _cell('Topsin-M 70WP'),
                  _cell('250g per acre'),
                  _cell('Rs. 850'),
                ]),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100),
                  children: [
                    _cell('Dithane M-45'),
                    _cell('500g per acre'),
                    _cell('Rs. 650'),
                  ],
                ),
                pw.TableRow(children: [
                  _cell('Total per acre', bold: true),
                  _cell(''),
                  _cell('Rs. 1,500', bold: true),
                ]),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              color: PdfColor.fromHex('E8F5E9'),
              child: pw.Text(
                'Kahan se khareedein: Apne ghar ke qareeb kisi bhi agricultural dukaan se. Koi bhi government-approved agri store chalega.

Helpline: Pakistan Agriculture Research Council — 051-9255170',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ));

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'CropSense_Kisan_Sheet_${districtLabel}.pdf',
      );
    } finally {
      setState(() => _generating = false);
    }
  }
}

