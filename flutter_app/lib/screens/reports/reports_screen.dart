import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/constants.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _district = 'faisalabad';
  String _crop = 'wheat';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reports', style: AppTextStyles.displayLarge),
          const SizedBox(height: 4),
          Text('Generate PDF reports for government, insurance, and NGO clients',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600)),
          const SizedBox(height: 32),
          _reportCard(
            title: 'District Intelligence Report',
            desc: 'Complete yield forecast, risk assessment, AI recommendations and cost estimates in PKR. For district agriculture officers and provincial food departments.',
            icon: Icons.location_on_rounded,
            color: AppColors.deepGreen,
            tags: const ['Government', 'District Level', 'AI Advisory'],
            extra: _buildSelectors(),
            onGenerate: _generateDistrict,
          ),
          const SizedBox(height: 16),
          _reportCard(
            title: 'National Risk Summary',
            desc: 'Province-by-province breakdown across all 36 districts. Highlights critical drought zones and disease outbreaks. Suitable for MNFSR briefings.',
            icon: Icons.map_rounded,
            color: AppColors.skyBlue,
            tags: const ['MNFSR', 'National Level', 'All Districts'],
            onGenerate: _generateNational,
          ),
          const SizedBox(height: 16),
          _reportCard(
            title: 'Farmer Advisory Sheet',
            desc: 'One-page advice in Roman Urdu. What to spray, when to irrigate, cost per acre. Printable for farmers without digital access.',
            icon: Icons.person_rounded,
            color: AppColors.limeGreen,
            tags: const ['Farmers', 'Roman Urdu', 'Printable'],
            extra: _buildSelectors(),
            onGenerate: _generateFarmer,
          ),
        ]),
      ),
    );
  }

  Widget _buildSelectors() {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('District', style: AppTextStyles.label),
        DropdownButton<String>(
          value: _district,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: AppTextStyles.bodyMedium,
          items: AppDistricts.all.take(12).map((d) =>
            DropdownMenuItem(value: d['id'], child: Text(d['label']!))).toList(),
          onChanged: (v) => setState(() => _district = v!),
        ),
      ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Crop', style: AppTextStyles.label),
        DropdownButton<String>(
          value: _crop,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: AppTextStyles.bodyMedium,
          items: AppCrops.all.map((c) =>
            DropdownMenuItem(value: c['id'], child: Text(c['label']!))).toList(),
          onChanged: (v) => setState(() => _crop = v!),
        ),
      ])),
    ]);
  }

  Widget _reportCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required List<String> tags,
    Widget? extra,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.headingSmall),
            const SizedBox(height: 6),
            Text(desc, style: AppTextStyles.bodySmall.copyWith(height: 1.6, color: AppColors.grey600)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(t, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            )).toList()),
          ])),
        ]),
        if (extra != null) ...[
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          extra,
        ],
        const SizedBox(height: 16),
        Row(children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loading ? null : onGenerate,
            icon: _loading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.picture_as_pdf_rounded, size: 16),
            label: Text(_loading ? 'Generating...' : 'Download PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
        ]),
      ]),
    );
  }

  pw.Widget _cell(String text, {bool bold = false, bool white = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: white ? PdfColors.white : PdfColors.black,
      )),
    );
  }

  Future<void> _generateDistrict() async {
    setState(() => _loading = true);
    try {
      final districtLabel = AppDistricts.all.firstWhere((d) => d['id'] == _district)['label']!;
      final cropLabel = AppCrops.all.firstWhere((c) => c['id'] == _crop)['label']!;
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('1B5E20'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CropSense District Intelligence Report',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(districtLabel + ' - ' + cropLabel + ' - Pakistan',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            ]),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            color: PdfColor.fromHex('F1F8E9'),
            child: pw.Text(
              'CropSense satellite and climate analysis for ' + districtLabel + ' district indicates WATCH-level agricultural risk. ML yield forecast is 2.3 t/acre with 95% confidence interval of 2.0 to 2.6 t/acre. Immediate attention recommended for rust disease prevention.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Field Conditions', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex('1B5E20')), children: [
                _cell('Indicator', bold: true, white: true), _cell('Value', bold: true, white: true), _cell('Status', bold: true, white: true)]),
              pw.TableRow(children: [_cell('NDVI'), _cell('0.62'), _cell('Moderate - monitoring needed')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Yield Forecast'), _cell('2.3 t/acre'), _cell('Near seasonal average')]),
              pw.TableRow(children: [_cell('Risk Score'), _cell('35/100'), _cell('WATCH level')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Rainfall 30-day'), _cell('82mm'), _cell('Below seasonal average')]),
              pw.TableRow(children: [_cell('Max Temperature'), _cell('38 C'), _cell('Elevated - heat stress risk')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Soil Moisture'), _cell('42%'), _cell('Adequate')]),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('AI Advisory Recommendations', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Text('Roman Urdu Alert: Fasal ko zang ka khatara hai - kal subah spray karein',
              style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic, color: PdfColor.fromHex('B71C1C'))),
          pw.SizedBox(height: 8),
          ...[
            '1. Apply Topsin-M 70WP at 250g/acre within 48 hours for rust control',
            '2. Increase irrigation to every 8 days (from current 12 days)',
            '3. Hold all Urea fertilizer for 2 weeks',
            '4. Monitor fields daily and repeat spray after 10 days if spreading',
            '5. Contact district agriculture officer if more than 30% leaves affected',
          ].map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(step, style: const pw.TextStyle(fontSize: 10)),
          )),
          pw.SizedBox(height: 16),
          pw.Text('Cost and ROI Estimate', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex('1B5E20')), children: [
                _cell('Item', bold: true, white: true), _cell('Amount PKR', bold: true, white: true)]),
              pw.TableRow(children: [_cell('Treatment cost per acre'), _cell('Rs. 12,500')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Protected yield value'), _cell('Rs. 45,000')]),
              pw.TableRow(children: [_cell('Net ROI on treatment', bold: true), _cell('260%', bold: true)]),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            color: PdfColors.grey100,
            child: pw.Text(
              'Data Sources: Sentinel-2 Satellite NDVI, Pakistan Meteorological Department, Pakistan Bureau of Statistics, CropSense Random Forest ML Model (R2=0.89), Grok AI Advisory Engine. Generated by CropSense Pakistan Smart Farm Intelligence Platform.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ));
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'CropSense_' + districtLabel + '_' + cropLabel + '_Report.pdf',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generateNational() async {
    setState(() => _loading = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            color: PdfColor.fromHex('1B5E20'),
            child: pw.Text('CropSense - National Crop Risk Summary - Pakistan',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Province Overview', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex('1B5E20')), children: [
                _cell('Province', bold: true, white: true),
                _cell('Avg Yield', bold: true, white: true),
                _cell('NDVI', bold: true, white: true),
                _cell('Risk Level', bold: true, white: true),
                _cell('Alerts', bold: true, white: true),
              ]),
              pw.TableRow(children: [_cell('Punjab'), _cell('2.4 t/ac'), _cell('0.64'), _cell('WATCH'), _cell('6')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Sindh'), _cell('1.9 t/ac'), _cell('0.51'), _cell('HIGH'), _cell('5')]),
              pw.TableRow(children: [_cell('Khyber Pakhtunkhwa'), _cell('2.1 t/ac'), _cell('0.68'), _cell('ABOVE AVG'), _cell('2')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Balochistan'), _cell('1.2 t/ac'), _cell('0.31'), _cell('CRITICAL'), _cell('7')]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Critical Alerts Requiring Immediate Attention',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('B71C1C'))),
          pw.SizedBox(height: 8),
          ...[
            'Quetta (Balochistan): Critical drought - yield forecast 0.9 t/acre, risk score 82/100',
            'Tharparkar (Sindh): Rainfall 60% below seasonal average - emergency irrigation needed',
            'Multan (Punjab): High rust disease pressure - fungicide application urgent',
            'Karachi (Sindh): Extreme heat stress - NDVI declining rapidly',
          ].map((alert) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: PdfColor.fromHex('FFF3E0'),
              child: pw.Text('Alert: ' + alert, style: const pw.TextStyle(fontSize: 10)),
            ),
          )),
        ]),
      ));
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'CropSense_National_Risk_Summary.pdf',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generateFarmer() async {
    setState(() => _loading = true);
    try {
      final districtLabel = AppDistricts.all.firstWhere((d) => d['id'] == _district)['label']!;
      final cropLabel = AppCrops.all.firstWhere((c) => c['id'] == _crop)['label']!;
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            color: PdfColor.fromHex('1B5E20'),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CropSense - Kisan Advisory Sheet',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(districtLabel + ' - ' + cropLabel,
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
            ]),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Fasal ki Halat (Field Conditions)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('Aapki fasal mein zang ka khatara hai. Neeche di gayi hidayaat par amal karein.',
              style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 12),
          pw.Text('Kya Karein? (What to do)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 6),
          ...[
            '1. Kal subah Topsin-M 70WP spray karein - 250 gram per acre',
            '2. Pani 8 din baad dein (zyada pani na dein)',
            '3. 2 hafte tak Urea (khad) na daalein',
            '4. Roz apni fasal dekhein',
          ].map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Text(step, style: const pw.TextStyle(fontSize: 11)),
          )),
          pw.SizedBox(height: 12),
          pw.Text('Kya Khareedein? (What to buy)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1B5E20'))),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex('8BC34A')), children: [
                _cell('Cheez', bold: true, white: true),
                _cell('Miqdar', bold: true, white: true),
                _cell('Qeemat', bold: true, white: true),
              ]),
              pw.TableRow(children: [_cell('Topsin-M 70WP'), _cell('250g per acre'), _cell('Rs. 850')]),
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [_cell('Dithane M-45'), _cell('500g per acre'), _cell('Rs. 650')]),
              pw.TableRow(children: [_cell('TOTAL', bold: true), _cell(''), _cell('Rs. 1,500', bold: true)]),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            color: PdfColor.fromHex('E8F5E9'),
            child: pw.Text(
              'Kahan se khareedein: Ghar ke qareeb kisi bhi agricultural dukaan se. Helpline: PARC 051-9255170',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ]),
      ));
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'Kisan_Sheet_' + districtLabel + '.pdf',
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}