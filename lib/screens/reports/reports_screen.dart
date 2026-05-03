import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/shared/widgets/neon_background.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _State();
}

class _State extends ConsumerState<ReportsScreen> {
  String _district = 'faisalabad';
  String _crop = 'wheat';
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GlassPanel(
                glowColor: AppColors.skyBlue,
                padding: const EdgeInsets.all(24),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.neonButton,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.elevated,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports', style: AppTextStyles.displayLarge),
                      const SizedBox(height: 4),
                      Text(
                          'Generate polished PDF reports for government, insurance, NGOs, and farmers.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.grey600)),
                    ],
                  )),
                ]),
              ),
              const SizedBox(height: 32),
              _card(
                  'District Intelligence Report',
                  'Yield forecast, risk assessment, AI recommendations and cost/ROI in PKR.',
                  Icons.location_on_rounded,
                  AppColors.deepGreen,
                  ['Government', 'District Level', 'AI Advisory'],
                  _sel(),
                  _districtReport),
              const SizedBox(height: 16),
              _card(
                  'National Risk Summary',
                  'Province-by-province breakdown across all 36 districts. For MNFSR briefings.',
                  Icons.map_rounded,
                  AppColors.skyBlue,
                  ['MNFSR', 'National Level', 'All Districts'],
                  null,
                  _nationalReport),
              const SizedBox(height: 16),
              _card(
                  'Farmer Advisory Sheet',
                  'One-page advice in Roman Urdu. What to spray, cost per acre. Printable.',
                  Icons.person_rounded,
                  AppColors.limeGreen,
                  ['Farmers', 'Roman Urdu', 'Printable'],
                  _sel(),
                  _farmerReport),
            ])));
  }

  Widget _sel() {
    final districtPicker =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('District', style: AppTextStyles.label),
      DropdownButton<String>(
          value: _district,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: AppDistricts.all
              .take(12)
              .map((d) =>
                  DropdownMenuItem(value: d['id'], child: Text(d['label']!)))
              .toList(),
          onChanged: (v) => setState(() => _district = v!)),
    ]);
    final cropPicker =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Crop', style: AppTextStyles.label),
      DropdownButton<String>(
          value: _crop,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: AppCrops.all
              .map((c) =>
                  DropdownMenuItem(value: c['id'], child: Text(c['label']!)))
              .toList(),
          onChanged: (v) => setState(() => _crop = v!)),
    ]);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(children: [
          districtPicker,
          const SizedBox(height: 12),
          cropPicker,
        ]);
      }
      return Row(children: [
        Expanded(child: districtPicker),
        const SizedBox(width: 16),
        Expanded(child: cropPicker),
      ]);
    });
  }

  Widget _card(String title, String desc, IconData icon, Color color,
      List<String> tags, Widget? extra, VoidCallback onTap) {
    return GlassPanel(
      glowColor: color,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: AppTextStyles.headingSmall),
                const SizedBox(height: 6),
                Text(desc,
                    style: AppTextStyles.bodySmall
                        .copyWith(height: 1.6, color: AppColors.grey600)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    children: tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.3))),
                              child: Text(t,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList()),
              ])),
        ]),
        if (extra != null) ...[
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          extra
        ],
        const SizedBox(height: 16),
        Row(children: [
          const Spacer(),
          ElevatedButton.icon(
              onPressed: _busy ? null : onTap,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf_rounded, size: 16),
              label: Text(_busy ? 'Generating...' : 'Download PDF'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white)),
        ]),
      ]),
    );
  }

  pw.Widget _cell(String t, {bool b = false, bool w = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(t,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: b ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: w ? PdfColors.white : PdfColors.black)));
  Future<void> _districtReport() async {
    setState(() => _busy = true);
    try {
      final dl =
          AppDistricts.all.firstWhere((d) => d['id'] == _district)['label']!;
      final cl = AppCrops.all.firstWhere((c) => c['id'] == _crop)['label']!;
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
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8))),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CropSense District Intelligence Report',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(dl + ' - ' + cl + ' - Pakistan',
                              style: const pw.TextStyle(
                                  color: PdfColors.white, fontSize: 12)),
                        ])),
                pw.SizedBox(height: 20),
                pw.Text('Field Conditions',
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
                            _cell('Indicator', b: true, w: true),
                            _cell('Value', b: true, w: true),
                            _cell('Status', b: true, w: true)
                          ]),
                      pw.TableRow(children: [
                        _cell('NDVI'),
                        _cell('0.62'),
                        _cell('Moderate')
                      ]),
                      pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _cell('Yield Forecast'),
                            _cell('2.3 t/acre'),
                            _cell('Near average')
                          ]),
                      pw.TableRow(children: [
                        _cell('Risk Score'),
                        _cell('35/100'),
                        _cell('WATCH')
                      ]),
                      pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _cell('Rainfall'),
                            _cell('82mm'),
                            _cell('Below average')
                          ]),
                      pw.TableRow(children: [
                        _cell('Max Temp'),
                        _cell('38 C'),
                        _cell('Elevated')
                      ]),
                    ]),
                pw.SizedBox(height: 16),
                pw.Text('AI Advisory',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('1B5E20'))),
                pw.SizedBox(height: 8),
                pw.Text(
                    'Roman Urdu: Fasal ko zang ka khatara hai - subah spray karein',
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColor.fromHex('B71C1C'))),
                pw.SizedBox(height: 8),
                ...[
                  '1. Apply Topsin-M 70WP at 250g/acre within 48 hours',
                  '2. Irrigate every 8 days',
                  '3. Hold Urea for 2 weeks',
                  '4. Monitor daily'
                ].map((s) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child:
                        pw.Text(s, style: const pw.TextStyle(fontSize: 10)))),
                pw.SizedBox(height: 16),
                pw.Text('Cost and ROI',
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
                            _cell('Item', b: true, w: true),
                            _cell('Amount', b: true, w: true)
                          ]),
                      pw.TableRow(children: [
                        _cell('Treatment/acre'),
                        _cell('Rs. 12,500')
                      ]),
                      pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _cell('Protected yield'),
                            _cell('Rs. 45,000')
                          ]),
                      pw.TableRow(children: [
                        _cell('ROI', b: true),
                        _cell('260%', b: true)
                      ]),
                    ]),
              ]));
      await Printing.layoutPdf(
          onLayout: (_) => pdf.save(),
          name: 'CropSense_' + dl + '_' + cl + '.pdf');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _nationalReport() async {
    setState(() => _busy = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(16),
                        color: PdfColor.fromHex('1B5E20'),
                        child: pw.Text('CropSense National Crop Risk Summary',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(height: 20),
                    pw.Text('Province Overview',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Table(
                        border: pw.TableBorder.all(
                            color: PdfColors.grey300, width: 0.5),
                        children: [
                          pw.TableRow(
                              decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('1B5E20')),
                              children: [
                                _cell('Province', b: true, w: true),
                                _cell('Avg Yield', b: true, w: true),
                                _cell('NDVI', b: true, w: true),
                                _cell('Risk', b: true, w: true)
                              ]),
                          pw.TableRow(children: [
                            _cell('Punjab'),
                            _cell('2.4 t/ac'),
                            _cell('0.64'),
                            _cell('WATCH')
                          ]),
                          pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey100),
                              children: [
                                _cell('Sindh'),
                                _cell('1.9 t/ac'),
                                _cell('0.51'),
                                _cell('HIGH')
                              ]),
                          pw.TableRow(children: [
                            _cell('Khyber Pakhtunkhwa'),
                            _cell('2.1 t/ac'),
                            _cell('0.68'),
                            _cell('ABOVE AVG')
                          ]),
                          pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey100),
                              children: [
                                _cell('Balochistan'),
                                _cell('1.2 t/ac'),
                                _cell('0.31'),
                                _cell('CRITICAL')
                              ]),
                        ]),
                  ])));
      await Printing.layoutPdf(
          onLayout: (_) => pdf.save(), name: 'CropSense_National.pdf');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _farmerReport() async {
    setState(() => _busy = true);
    try {
      final dl =
          AppDistricts.all.firstWhere((d) => d['id'] == _district)['label']!;
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
                        child: pw.Text(
                            'CropSense - Kisan Advisory Sheet - ' + dl,
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(height: 16),
                    pw.Text('Fasal ki Halat (Field Conditions)',
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                        'Aapki fasal mein zang ka khatara hai. Neeche di gayi hidayaat par amal karein.',
                        style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 12),
                    pw.Text('Kya Karein?',
                        style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('1B5E20'))),
                    pw.SizedBox(height: 6),
                    ...[
                      '1. Topsin-M 70WP spray karein - 250g per acre',
                      '2. Pani 8 din baad dein',
                      '3. 2 hafte Urea na daalein'
                    ].map((s) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text(s,
                            style: const pw.TextStyle(fontSize: 11)))),
                    pw.SizedBox(height: 12),
                    pw.Table(
                        border: pw.TableBorder.all(
                            color: PdfColors.grey400, width: 0.5),
                        children: [
                          pw.TableRow(
                              decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('8BC34A')),
                              children: [
                                _cell('Cheez', b: true, w: true),
                                _cell('Miqdar', b: true, w: true),
                                _cell('Qeemat', b: true, w: true)
                              ]),
                          pw.TableRow(children: [
                            _cell('Topsin-M'),
                            _cell('250g/acre'),
                            _cell('Rs. 850')
                          ]),
                          pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey100),
                              children: [
                                _cell('Dithane M-45'),
                                _cell('500g/acre'),
                                _cell('Rs. 650')
                              ]),
                        ]),
                  ])));
      await Printing.layoutPdf(
          onLayout: (_) => pdf.save(), name: 'Kisan_' + dl + '.pdf');
    } finally {
      setState(() => _busy = false);
    }
  }
}
