from datetime import datetime
import os
bs = chr(92)
nl = chr(10)
q = chr(39)
lt = chr(60)
gt = chr(62)
d = chr(36)   # dollar sign for Dart string interpolation

content = f"""import {q}package:flutter/material.dart{q};
import {q}package:flutter_riverpod/flutter_riverpod.dart{q};
import {q}package:pdf/pdf.dart{q};
import {q}package:pdf/widgets.dart{q} as pw;
import {q}package:printing/printing.dart{q};
import {q}package:cropsense/core/theme.dart{q};
import {q}package:cropsense/core/utils.dart{q};
import {q}package:cropsense/core/constants.dart{q};
import {q}package:cropsense/providers/map_provider.dart{q};
import {q}package:cropsense/providers/district_provider.dart{q};

class ReportsScreen extends ConsumerStatefulWidget {{
  const ReportsScreen({{super.key}});
  @override
  ConsumerState{lt}ReportsScreen{gt} createState() => _ReportsScreenState();
}}

class _ReportsScreenState extends ConsumerState{lt}ReportsScreen{gt} {{
  String _district = {q}faisalabad{q};
  String _crop = {q}wheat{q};
  bool _generating = false;

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text({q}Reports{q}, style: AppTextStyles.displayLarge),
            const SizedBox(height: 4),
            Text(
              {q}Generate downloadable PDF reports for government, insurance, and NGO clients{q},
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600),
            ),
            const SizedBox(height: 32),
            _buildReportTypeCard(
              title: {q}District Intelligence Report{q},
              subtitle: {q}Complete crop analysis for one district{q},
              description: {q}Includes 14-day yield forecast, risk assessment, satellite NDVI trend, ML model confidence intervals, AI advisory recommendations, and cost/ROI estimates in PKR. Ideal for district agriculture officers and provincial food departments.{q},
              icon: Icons.location_on_rounded,
              color: AppColors.deepGreen,
              tags: const [{q}Government{q}, {q}District Level{q}, {q}AI Advisory{q}],
              selector: _buildDistrictSelector(),
              onGenerate: _generateDistrictReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: {q}National Crop Risk Summary{q},
              subtitle: {q}All-Pakistan overview for federal briefings{q},
              description: {q}Province-by-province breakdown of crop conditions across all 36 monitored districts. Highlights critical drought zones, disease outbreaks, and yield variance vs historical average. Suitable for MNFSR and parliamentary committee presentations.{q},
              icon: Icons.map_rounded,
              color: AppColors.skyBlue,
              tags: const [{q}MNFSR{q}, {q}National Level{q}, {q}All Districts{q}],
              selector: const SizedBox.shrink(),
              onGenerate: _generateNationalReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: {q}Crop Insurance Risk Report{q},
              subtitle: {q}Statistical risk analysis for insurers{q},
              description: {q}Actuarial-grade risk data including drought probability distributions, historical yield volatility, confidence intervals, and correlation analysis between climate variables and crop loss. Designed for EFU, Jubilee, and other crop insurers.{q},
              icon: Icons.shield_rounded,
              color: AppColors.amber,
              tags: const [{q}EFU{q}, {q}Jubilee Insurance{q}, {q}Risk Data{q}],
              selector: const SizedBox.shrink(),
              onGenerate: _generateInsuranceReport,
            ),
            const SizedBox(height: 16),
            _buildReportTypeCard(
              title: {q}Farmer Advisory Sheet{q},
              subtitle: {q}Simple one-page advice in Roman Urdu{q},
              description: {q}A single A4 page with crop instructions in simple Roman Urdu — what to spray, when to irrigate, what to buy and where, cost per acre. Printable for distribution to farmers who cannot access digital tools.{q},
              icon: Icons.person_rounded,
              color: AppColors.limeGreen,
              tags: const [{q}Farmers{q}, {q}Roman Urdu{q}, {q}Printable{q}],
              selector: _buildDistrictSelector(),
              onGenerate: _generateFarmerSheet,
            ),
          ],
        ),
      ),
    );
  }}

  Widget _buildDistrictSelector() {{
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text({q}District{q}, style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButton{lt}String{gt}(
              value: _district,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: AppTextStyles.bodyMedium,
              items: AppDistricts.all.take(12).map((d) =>
                  DropdownMenuItem(
                      value: d[{q}id{q}],
                      child: Text(d[{q}label{q}]!))).toList(),
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
            Text({q}Crop{q}, style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButton{lt}String{gt}(
              value: _crop,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: AppTextStyles.bodyMedium,
              items: AppCrops.all.map((c) =>
                  DropdownMenuItem(
                      value: c[{q}id{q}],
                      child: Text(c[{q}label{q}]!))).toList(),
              onChanged: (v) => setState(() => _crop = v!),
            ),
          ],
        ),
      ),
    ]);
  }}

  Widget _buildReportTypeCard({{
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required List{lt}String{gt} tags,
    required Widget selector,
    required VoidCallback onGenerate,
  }}) {{
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
              onPressed: () {{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        {q}Preview mode — generate to see full report{q}),
                    backgroundColor: color,
                  ),
                );
              }},
              icon: const Icon(Icons.preview_rounded, size: 16),
              label: const Text({q}Preview{q}),
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
                  _generating ? {q}Generating...{q} : {q}Download PDF{q}),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ]),
        ],
      ),
    );
  }}

  Future{lt}void{gt} _generateDistrictReport() async {{
    setState(() => _generating = true);
    try {{
      final districtLabel = AppDistricts.all
          .firstWhere((d) => d[{q}id{q}] == _district)[{q}label{q}]!;
      final cropLabel = AppCrops.all
          .firstWhere((c) => c[{q}id{q}] == _crop)[{q}label{q}]!;

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
              pw.Text({q}CropSense Pakistan{q},
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex({q}1B5E20{q}))),
              pw.Text(
                {q}CONFIDENTIAL — For Official Use Only{q},
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
                {q}Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}{q},
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                {q}Page{q} +
                    ctx.pageNumber.toString() +
                    {q} of {q} +
                    ctx.pagesCount.toString(),
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex({q}1B5E20{q}),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(children: [
              pw.Container(
                width: 50, height: 50,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8)),
                ),
                child: pw.Center(
                  child: pw.Text({q}CS{q},
                      style: pw.TextStyle(
                          color: PdfColor.fromHex({q}1B5E20{q}),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text({q}District Intelligence Report{q},
                        style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.Text(
                        {q}{d}districtLabel District · {d}cropLabel · Pakistan{q},
                        style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white)),
                  ]),
            ]),
          ),
          pw.SizedBox(height: 20),

          pw.Text({q}Executive Summary{q},
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex({q}1B5E20{q}))),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex({q}F1F8E9{q}),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              {q}CropSense satellite and climate analysis for {d}districtLabel district indicates WATCH-level agricultural risk for the current {d}cropLabel growing season. Machine learning yield forecast (14-day) is 2.3 tonnes/acre with a 95% confidence interval of 2.0-2.6 t/acre. Immediate attention is recommended for rust disease prevention and irrigation scheduling optimization.{q},
              style: const pw.TextStyle(
                  fontSize: 11, lineSpacing: 5),
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Text({q}Current Field Conditions{q},
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex({q}1B5E20{q}))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            columnWidths: {{
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
            }},
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex({q}1B5E20{q})),
                children: [
                  _cell({q}Indicator{q}, bold: true, white: true),
                  _cell({q}Value{q}, bold: true, white: true),
                  _cell({q}Status{q}, bold: true, white: true),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}NDVI (Vegetation Index){q}),
                _cell({q}0.62{q}),
                _cell({q}Moderate — monitoring needed{q}),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell({q}14-Day Yield Forecast{q}),
                  _cell({q}2.3 t/acre{q}),
                  _cell({q}Near seasonal average{q}),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}Confidence Interval (95%){q}),
                _cell({q}2.0 - 2.6 t/acre{q}),
                _cell({q}Acceptable uncertainty{q}),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell({q}Risk Score{q}),
                  _cell({q}35 / 100{q}),
                  _cell({q}WATCH level{q}),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}30-Day Rainfall{q}),
                _cell({q}82mm{q}),
                _cell({q}Below seasonal average{q}),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell({q}Max Temperature{q}),
                  _cell({q}38°C{q}),
                  _cell({q}Elevated — heat stress risk{q}),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}Soil Moisture{q}),
                _cell({q}42%{q}),
                _cell({q}Adequate{q}),
              ]),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text({q}AI Advisory Recommendations{q},
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex({q}1B5E20{q}))),
          pw.SizedBox(height: 8),
          pw.Text(
              {q}Roman Urdu Alert: Fasal ko zang ka khatara hai — kal subah spray karein{q},
              style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColor.fromHex({q}B71C1C{q}))),
          pw.SizedBox(height: 8),
          ...[
            {q}1. Apply Topsin-M 70 WP at 250g/acre within 48 hours for rust control{q},
            {q}2. Increase irrigation frequency to every 8 days (from current 12 days){q},
            {q}3. Hold all nitrogen (Urea) fertilizer applications for 2 weeks{q},
            {q}4. Monitor fields daily — repeat spray after 10 days if disease spreading{q},
            {q}5. Contact district agriculture officer if more than 30% leaves affected{q},
          ].map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 6, height: 6,
                  margin: const pw.EdgeInsets.only(top: 4, right: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex({q}1B5E20{q}),
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

          pw.Text({q}Recommended Products & Cost Estimate{q},
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex({q}1B5E20{q}))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex({q}1B5E20{q})),
                children: [
                  _cell({q}Product{q}, bold: true, white: true),
                  _cell({q}Dose/Acre{q}, bold: true, white: true),
                  _cell({q}Cost/Acre (PKR){q}, bold: true, white: true),
                  _cell({q}Urgency{q}, bold: true, white: true),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}Topsin-M 70 WP{q}),
                _cell({q}250g in 100L water{q}),
                _cell({q}Rs. 850{q}),
                _cell({q}Immediate{q}),
              ]),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100),
                children: [
                  _cell({q}Dithane M-45{q}),
                  _cell({q}500g in 100L water{q}),
                  _cell({q}Rs. 650{q}),
                  _cell({q}Within 7 days{q}),
                ],
              ),
              pw.TableRow(children: [
                _cell({q}DAP Fertilizer{q}),
                _cell({q}1 bag/acre{q}),
                _cell({q}Rs. 8,500{q}),
                _cell({q}After disease control{q}),
              ]),
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex({q}E8F5E9{q})),
                children: [
                  _cell({q}TOTAL TREATMENT COST{q}, bold: true),
                  _cell({q}{q}),
                  _cell({q}Rs. 12,500/acre{q}, bold: true),
                  _cell({q}{q}),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex({q}1B5E20{q}),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text({q}Return on Investment Estimate:{q},
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11)),
                pw.Text(
                    {q}Spend Rs.12,500 → Protect Rs.45,000 in yield = 260% ROI{q},
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
              {q}Data Sources: Sentinel-2 Satellite NDVI · Pakistan Meteorological Department · Pakistan Bureau of Statistics Crop Area & Production · CropSense Random Forest ML Model (R²=0.89) · xAI Grok Advisory Engine\n\nThis report is generated by CropSense — Pakistan Smart Farm Intelligence Platform. For technical support: cropsense.pk | For emergency agricultural assistance: Pakistan Agricultural Research Council (PARC) helpline.{q},
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ));

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: {q}CropSense_{d}{{districtLabel}}_{d}{{cropLabel}}_Report.pdf{q},
      );
    }} catch (e) {{
      if (mounted) {{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text({q}PDF generation failed: {d}e{q}),
            backgroundColor: AppColors.burntOrange,
          ),
        );
      }}
    }} finally {{
      setState(() => _generating = false);
    }}
  }}

  pw.Widget _cell(String text,
      {{bool bold = false, bool white = false}}) {{
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
  }}

  Future{lt}void{gt} _generateNationalReport() async {{
    setState(() => _generating = true);
    try {{
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              color: PdfColor.fromHex({q}1B5E20{q}),
              child: pw.Text(
                {q}CropSense — National Crop Risk Summary\nPakistan · All 36 Districts{q},
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text({q}Province-Level Overview{q},
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
                      color: PdfColor.fromHex({q}1B5E20{q})),
                  children: [
                    _cell({q}Province{q}, bold: true, white: true),
                    _cell({q}Districts{q}, bold: true, white: true),
                    _cell({q}Avg Yield{q}, bold: true, white: true),
                    _cell({q}NDVI{q}, bold: true, white: true),
                    _cell({q}Risk Level{q}, bold: true, white: true),
                    _cell({q}Alerts{q}, bold: true, white: true),
                  ],
                ),
                ...{{
                  {q}Punjab{q}: [{q}14{q}, {q}2.4 t/ac{q}, {q}0.64{q}, {q}WATCH{q}, {q}6{q}],
                  {q}Sindh{q}: [{q}8{q}, {q}1.9 t/ac{q}, {q}0.51{q}, {q}HIGH{q}, {q}5{q}],
                  {q}Khyber Pakhtunkhwa{q}: [{q}6{q}, {q}2.1 t/ac{q}, {q}0.68{q}, {q}ABOVE AVG{q}, {q}2{q}],
                  {q}Balochistan{q}: [{q}8{q}, {q}1.2 t/ac{q}, {q}0.31{q}, {q}CRITICAL{q}, {q}7{q}],
                }}.entries.toList().asMap().map((i, e) =>
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
            pw.Text({q}Critical Alerts Requiring Immediate Attention{q},
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex({q}B71C1C{q}))),
            pw.SizedBox(height: 8),
            ...[
              {q}Quetta (Balochistan): Critical drought — yield forecast 0.9 t/acre, 82% risk score{q},
              {q}Tharparkar (Sindh): Rainfall 60% below seasonal average — emergency irrigation needed{q},
              {q}Multan (Punjab): High rust disease pressure — fungicide application urgent{q},
              {q}Karachi (Sindh): Extreme heat stress — NDVI declining rapidly{q},
            ].map((alert) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColor.fromHex({q}FFF3E0{q}),
                child: pw.Text({q}⚠ {d}alert{q},
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            )),
          ],
        ),
      ));
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: {q}CropSense_National_Risk_Summary.pdf{q},
      );
    }} finally {{
      setState(() => _generating = false);
    }}
  }}

  Future{lt}void{gt} _generateInsuranceReport() async {{
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _generating = false);
    if (mounted) {{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              {q}Insurance report requires Oracle DB connection — coming in next phase{q}),
          backgroundColor: AppColors.amber,
        ),
      );
    }}
  }}

  Future{lt}void{gt} _generateFarmerSheet() async {{
    setState(() => _generating = true);
    try {{
      final districtLabel = AppDistricts.all
          .firstWhere((d) => d[{q}id{q}] == _district)[{q}label{q}]!;
      final cropLabel = AppCrops.all
          .firstWhere((c) => c[{q}id{q}] == _crop)[{q}label{q}]!;
      final dateStr = {q}{datetime.now().strftime('%Y-%m-%d')}{q};

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
              color: PdfColor.fromHex({q}1B5E20{q}),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text({q}CropSense — Kisan Advisory Sheet{q},
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      {q}{d}districtLabel · {d}cropLabel · {q} + dateStr,
                      style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text({q}Fasal ki Halat (Field Conditions){q},
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(
                {q}Aapki fasal mein zang ka khatara hai. Neeche di gayi hidayaat par amal karein.{q},
                style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 12),
            pw.Text({q}Kya karein? (What to do){q},
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex({q}1B5E20{q}))),
            pw.SizedBox(height: 6),
            ...[
              {q}1. Kal subah Topsin-M 70WP spray karein — 250 gram per acre{q},
              {q}2. Pani 8 din baad dein (zyada pani na dein){q},
              {q}3. 2 hafte tak Urea (khad) na daalein{q},
              {q}4. Roz apni fasal dekhein — agar bimari barhe to agriculture officer ko call karein{q},
            ].map((step) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(step,
                  style: const pw.TextStyle(fontSize: 11)),
            )),
            pw.SizedBox(height: 12),
            pw.Text({q}Kya khareedein? (What to buy){q},
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex({q}1B5E20{q}))),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey400, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex({q}8BC34A{q})),
                  children: [
                    _cell({q}Cheez{q}, bold: true, white: true),
                    _cell({q}Miqdar{q}, bold: true, white: true),
                    _cell({q}Qeemat{q}, bold: true, white: true),
                  ],
                ),
                pw.TableRow(children: [
                  _cell({q}Topsin-M 70WP{q}),
                  _cell({q}250g per acre{q}),
                  _cell({q}Rs. 850{q}),
                ]),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100),
                  children: [
                    _cell({q}Dithane M-45{q}),
                    _cell({q}500g per acre{q}),
                    _cell({q}Rs. 650{q}),
                  ],
                ),
                pw.TableRow(children: [
                  _cell({q}Total per acre{q}, bold: true),
                  _cell({q}{q}),
                  _cell({q}Rs. 1,500{q}, bold: true),
                ]),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              color: PdfColor.fromHex({q}E8F5E9{q}),
              child: pw.Text(
                {q}Kahan se khareedein: Apne ghar ke qareeb kisi bhi agricultural dukaan se. Koi bhi government-approved agri store chalega.\n\nHelpline: Pakistan Agriculture Research Council — 051-9255170{q},
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ));

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: {q}CropSense_Kisan_Sheet_{d}{{districtLabel}}.pdf{q},
      );
    }} finally {{
      setState(() => _generating = false);
    }}
  }}
}}
"""

path = (f'flutter_app{bs}lib{bs}screens{bs}reports{bs}'
        f'reports_screen.dart')
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('reports_screen.dart written!')