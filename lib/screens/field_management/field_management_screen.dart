import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/providers/auth_provider.dart';
import 'package:cropsense/providers/field_management_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FieldManagementScreen extends ConsumerStatefulWidget {
  const FieldManagementScreen({super.key});

  @override
  ConsumerState<FieldManagementScreen> createState() =>
      _FieldManagementScreenState();
}

class _FieldManagementScreenState extends ConsumerState<FieldManagementScreen> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      _loaded = false;
      return const _AuthGate();
    }

    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(fieldManagementProvider.notifier).load();
      });
    }

    return const _FieldDashboard();
  }
}

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // Validates fields locally and returns an error string, or null if valid.
  String? _validate() {
    final email = _email.text.trim();
    final password = _password.text;

    if (_register) {
      if (email.isEmpty) return 'Email is required.';
      if (!email.contains('@') || !email.contains('.')) {
        return 'Enter a valid email address (e.g. farmer@gmail.com).';
      }
      if (_username.text.trim().length < 2) {
        return 'Username must be at least 2 characters.';
      }
      if (password.length < 8) {
        return 'Password must be at least 8 characters.';
      }
    } else {
      if (email.isEmpty) return 'Enter your email or username.';
      if (password.isEmpty) return 'Enter your password.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width >= 820)
                  Expanded(child: _AuthHero(register: _register)),
                Expanded(
                  child: _GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _register ? 'Create farmer account' : 'Farmer login',
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Field Management is protected. Your field records are saved in the backend database.',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText:
                                _register ? 'Email' : 'Username or email',
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        if (_register) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _username,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                              icon: Icon(_showPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded),
                            ),
                          ),
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          _InlineError(message: auth.error!),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: auth.loading ? null : _submit,
                            icon: auth.loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(_register
                                    ? Icons.person_add_alt_rounded
                                    : Icons.login_rounded),
                            label: Text(_register ? 'Register' : 'Login'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () =>
                              setState(() => _register = !_register),
                          child: Text(_register
                              ? 'Already have an account? Login'
                              : 'New farmer? Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final validation = _validate();
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }
    if (_register) {
      await ref.read(authProvider.notifier).register(
            email: _email.text.trim(),
            username: _username.text.trim(),
            password: _password.text,
          );
    } else {
      await ref.read(authProvider.notifier).login(
            identifier: _email.text.trim(),
            password: _password.text,
          );
    }
  }
}

class _AuthHero extends StatelessWidget {
  final bool register;

  const _AuthHero({required this.register});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: AppGradients.heroGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.landscape_rounded, color: Colors.white, size: 42),
          const Spacer(),
          Text(
            'Manage every field like a business.',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track water, fertilizer, medicine, labor, income, and profit with AI cost-saving suggestions.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldDashboard extends ConsumerWidget {
  const _FieldDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final state = ref.watch(fieldManagementProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        children: [
          _Header(
            username: auth.user?['username']?.toString() ?? 'Farmer',
            onLogout: () {
              ref.read(authProvider.notifier).logout();
              ref.read(fieldManagementProvider.notifier).reset();
            },
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: _InlineError(message: state.error!),
            ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;
              final content = [
                _FieldListPanel(state: state),
                _FieldMainPanel(state: state),
                _AnalyticsSidePanel(state: state),
              ];
              if (compact) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: content
                      .map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: child,
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 285, child: content[0]),
                  Expanded(child: content[1]),
                  SizedBox(width: 330, child: content[2]),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _FieldDialog(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add field'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const _Header({required this.username, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
      decoration: const BoxDecoration(gradient: AppGradients.heroGreen),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Field Management',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Welcome, $username. Track fields, costs, activities, and AI savings.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (compact)
            IconButton(
              tooltip: 'Logout',
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            )
          else
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _FieldListPanel extends ConsumerWidget {
  final FieldManagementState state;

  const _FieldListPanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GlassPanel(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text('My fields', style: AppTextStyles.headingSmall)),
            IconButton(
              onPressed: () =>
                  ref.read(fieldManagementProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
          ]),
          const SizedBox(height: 8),
          if (state.loading && state.fields.isEmpty)
            const LinearProgressIndicator()
          else if (state.fields.isEmpty)
            const _EmptyBox(
              icon: Icons.add_location_alt_rounded,
              title: 'No fields yet',
              text: 'Add your first field to start tracking activities.',
            )
          else
            ...state.fields.map((field) {
              final selected = state.selectedField?['id'] == field['id'];
              return _FieldTile(field: field, selected: selected);
            }),
          const SizedBox(height: 14),
          Text('Field comparison', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          SizedBox(
              height: 190,
              child: _FieldComparisonChart(rows: state.comparison)),
        ],
      ),
    );
  }
}

class _FieldTile extends ConsumerWidget {
  final Map<String, dynamic> field;
  final bool selected;

  const _FieldTile({required this.field, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = selected ? AppColors.deepGreen : AppColors.grey600;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => ref
          .read(fieldManagementProvider.notifier)
          .selectField(field['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.deepGreen.withValues(alpha: 0.08)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.deepGreen.withValues(alpha: 0.22)
                : AppColors.grey200,
          ),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.limeGreen.withValues(alpha: 0.9),
                  AppColors.deepGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grass_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                field['fieldName']?.toString() ?? '',
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${_title(field['crop'])} / ${_num(field['areaSizeAcres']).toStringAsFixed(1)} acres',
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FieldMainPanel extends ConsumerWidget {
  final FieldManagementState state;

  const _FieldMainPanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = state.selectedField;
    final analytics = state.analytics;

    if (field == null || analytics == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: _EmptyBox(
          icon: Icons.landscape_rounded,
          title: 'Select or add a field',
          text:
              'Your field dashboard, logs, and finance charts will appear here.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      children: [
        _CropVisual(field: field),
        const SizedBox(height: 14),
        _QuickActions(fieldId: field['id'] as String),
        const SizedBox(height: 14),
        _FinanceCharts(analytics: analytics),
        const SizedBox(height: 14),
        _Timeline(analytics: analytics),
      ],
    );
  }
}

class _CropVisual extends ConsumerWidget {
  final Map<String, dynamic> field;

  const _CropVisual({required this.field});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 230,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF113D19), Color(0xFF79B34D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            Positioned(
              right: 16,
              bottom: 6,
              child: Icon(
                Icons.eco_rounded,
                color: Colors.white.withValues(alpha: 0.18),
                size: 150,
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                field['fieldName']?.toString() ?? '',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${_title(field['crop'])} growing in ${field['location'] ?? ''}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _WhiteChip(
                    '${_num(field['areaSizeAcres']).toStringAsFixed(1)} acres'),
                _WhiteChip('Soil: ${_title(field['soilType'])}'),
                _WhiteChip('Water: ${_title(field['waterAvailability'])}'),
                if (field['expectedHarvestDate'] != null)
                  _WhiteChip('Harvest: ${field['expectedHarvestDate']}'),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _FieldDialog(existing: field),
            ),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit field'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () async {
              final id = field['id'] as String;
              await ref.read(fieldManagementProvider.notifier).deleteField(id);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
          ),
        ]),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String fieldId;

  const _QuickActions({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('irrigation', 'Irrigation', Icons.water_drop_rounded, AppColors.skyBlue),
      ('fertilizer', 'Fertilizer', Icons.science_rounded, AppColors.deepGreen),
      ('medicine', 'Medicine', Icons.medication_rounded, AppColors.burntOrange),
      ('activities', 'Activity', Icons.construction_rounded, AppColors.amber),
      ('finance', 'Finance', Icons.payments_rounded, AppColors.limeGreen),
    ];
    return _GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Log activity', style: AppTextStyles.headingSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions.map((item) {
            return ActionChip(
              avatar: Icon(item.$3, size: 16, color: item.$4),
              label: Text(
                item.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _LogDialog(fieldId: fieldId, type: item.$1),
              ),
              backgroundColor: item.$4.withValues(alpha: 0.08),
              side: BorderSide(color: item.$4.withValues(alpha: 0.20)),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

class _FinanceCharts extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const _FinanceCharts({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 760;
      final charts = [
        _ChartPanel(
          title: 'Cost breakdown',
          child: _BreakdownDonut(rows: _rows(analytics['categoryBreakdown'])),
        ),
        _ChartPanel(
          title: 'Monthly money flow',
          child: _MonthlyLine(rows: _rows(analytics['monthlyMoneyFlow'])),
        ),
        _ChartPanel(
          title: 'Income vs expense',
          child: _IncomeExpenseBar(analytics: analytics),
        ),
        _ChartPanel(
          title: 'Usage summary',
          child: _UsageBars(usage: _map(analytics['usage'])),
        ),
      ];
      if (compact) {
        return Column(
          children: charts
              .map(
                (chart) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: chart,
                ),
              )
              .toList(),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: charts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 270,
        ),
        itemBuilder: (context, index) => charts[index],
      );
    });
  }
}

class _AnalyticsSidePanel extends ConsumerWidget {
  final FieldManagementState state;

  const _AnalyticsSidePanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = state.analytics;
    final advice = state.advice;
    final fieldId = state.selectedField?['id'] as String?;

    return _GlassPanel(
      margin: const EdgeInsets.all(16),
      child: analytics == null
          ? const _EmptyBox(
              icon: Icons.analytics_outlined,
              title: 'Analytics side panel',
              text:
                  'Select a field to view cost, risk, tasks, and AI warnings.',
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child:
                        Text('Analytics', style: AppTextStyles.headingSmall)),
                if (fieldId != null)
                  IconButton(
                    tooltip: 'Download report',
                    onPressed: () => _downloadReport(context, ref, fieldId),
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                  ),
              ]),
              const SizedBox(height: 10),
              _MetricGrid(analytics: analytics),
              const SizedBox(height: 12),
              Text('Upcoming tasks', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              ..._list(analytics['upcomingTasks']).map(
                (task) => _TaskTile(text: task),
              ),
              const SizedBox(height: 12),
              Text('AI Cost Advisor', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              if (advice == null)
                const LinearProgressIndicator()
              else
                _AdviceCard(advice: advice),
            ]),
    );
  }

  Future<void> _downloadReport(
    BuildContext context,
    WidgetRef ref,
    String fieldId,
  ) async {
    final report =
        await ref.read(fieldManagementProvider.notifier).buildReport(fieldId);
    final pdf = pw.Document();
    final analytics = _map(report['analytics']);
    final field = _map(report['field']);
    final advice = _map(report['aiRecommendations']);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        build: (_) => [
          pw.Text(
            report['title']?.toString() ?? 'Field Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Field: ${field['fieldName']}'),
          pw.Text(
              'Crop: ${field['crop']} / Area: ${field['areaSizeAcres']} acres'),
          pw.Text('Location: ${field['location']}'),
          pw.SizedBox(height: 12),
          pw.Text('Profit/Loss Overview',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Total cost: ${_money(_num(analytics['totalCostPkr']))}'),
          pw.Text('Total income: ${_money(_num(analytics['totalIncomePkr']))}'),
          pw.Text(
              'Net profit/loss: ${_money(_num(analytics['netProfitPkr']))}'),
          pw.Text(
              'Cost per acre: ${_money(_num(analytics['costPerAcrePkr']))}'),
          pw.SizedBox(height: 12),
          pw.Text('AI Recommendations',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(advice['summary']?.toString() ?? ''),
          ..._list(advice['costSavingSuggestions'])
              .map((item) => pw.Text('- $item')),
          pw.SizedBox(height: 12),
          pw.Text('Recent Timeline',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ..._rows(analytics['activityTimeline'])
              .take(12)
              .map((item) => pw.Text('${item['date']} - ${item['title']}')),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: '${field['fieldName'] ?? 'Field'}_Report.pdf',
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const _MetricGrid({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final metrics = <({String title, String value, IconData icon})>[
      (
        title: 'Total cost',
        value: _money(_num(analytics['totalCostPkr'])),
        icon: Icons.receipt_long_rounded,
      ),
      (
        title: 'Income',
        value: _money(_num(analytics['totalIncomePkr'])),
        icon: Icons.savings_rounded,
      ),
      (
        title: 'Net',
        value: _money(_num(analytics['netProfitPkr'])),
        icon: Icons.trending_up_rounded,
      ),
      (
        title: 'Cost/acre',
        value: _money(_num(analytics['costPerAcrePkr'])),
        icon: Icons.straighten_rounded,
      ),
      (
        title: 'Water',
        value: '${_num(analytics['waterUsage']).toStringAsFixed(0)} units',
        icon: Icons.water_drop_rounded,
      ),
      (
        title: 'Risk',
        value: analytics['riskLevel']?.toString() ?? 'low',
        icon: Icons.warning_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 680
            ? 3
            : width >= 360
                ? 2
                : 1;
        final extent = width < 360
            ? 138.0
            : width < 680
                ? 128.0
                : 118.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, index) {
            final item = metrics[index];
            return _MetricCard(
              title: item.title,
              value: item.value,
              icon: item.icon,
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.deepGreen),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final Map<String, dynamic> advice;

  const _AdviceCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(advice['summary']?.toString() ?? '',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        ..._list(advice['costSavingSuggestions']).map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_rounded,
                  size: 14, color: AppColors.deepGreen),
              const SizedBox(width: 6),
              Expanded(child: Text(item, style: AppTextStyles.bodySmall)),
            ]),
          ),
        ),
        if (_list(advice['warnings']).isNotEmpty) ...[
          const Divider(),
          ..._list(advice['warnings']).map(
            (item) => Text(
              'Warning: $item',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.burntOrange),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Timeline extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const _Timeline({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final rows = _rows(analytics['activityTimeline']);
    return _GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Activity timeline', style: AppTextStyles.headingSmall),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          Text('No activities logged yet.', style: AppTextStyles.bodySmall)
        else
          ...rows.take(8).map((row) => _TimelineRow(row: row)),
      ]),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final Map<String, dynamic> row;

  const _TimelineRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: AppColors.deepGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row['title']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              '${row['date'] ?? ''} / ${_title(row['type'])} / ${_money(_num(row['amountPkr']))}',
              style: AppTextStyles.bodySmall,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _FieldDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const _FieldDialog({this.existing});

  @override
  ConsumerState<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends ConsumerState<_FieldDialog> {
  late final TextEditingController name;
  late final TextEditingController location;
  late final TextEditingController area;
  late final TextEditingController notes;
  late String soil;
  late String crop;
  late String water;
  late DateTime sowing;
  late DateTime harvest;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    name =
        TextEditingController(text: existing?['fieldName']?.toString() ?? '');
    location =
        TextEditingController(text: existing?['location']?.toString() ?? '');
    area = TextEditingController(
        text: existing?['areaSizeAcres']?.toString() ?? '5');
    notes = TextEditingController(text: existing?['notes']?.toString() ?? '');
    soil = existing?['soilType']?.toString() ?? 'loam';
    crop = existing?['crop']?.toString() ?? 'wheat';
    water = existing?['waterAvailability']?.toString() ?? 'medium';
    sowing = _parseDate(existing?['sowingDate']) ?? DateTime.now();
    harvest = _parseDate(existing?['expectedHarvestDate']) ??
        DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    name.dispose();
    location.dispose();
    area.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 620 ? screenWidth * 0.82 : 520.0;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add field' : 'Edit field'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Field name')),
            const SizedBox(height: 10),
            TextField(
                controller: location,
                decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 10),
            TextField(
              controller: area,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Area size acres'),
            ),
            const SizedBox(height: 10),
            _DialogDropdown(
              label: 'Crop',
              value: crop,
              items: AppCrops.all.map((item) => item['id']!).toList(),
              onChanged: (value) => setState(() => crop = value),
            ),
            const SizedBox(height: 10),
            _DialogDropdown(
              label: 'Soil type',
              value: soil,
              items: const ['loam', 'clay', 'sandy', 'saline', 'mixed'],
              onChanged: (value) => setState(() => soil = value),
            ),
            const SizedBox(height: 10),
            _DialogDropdown(
              label: 'Water availability',
              value: water,
              items: const ['low', 'medium', 'high'],
              onChanged: (value) => setState(() => water = value),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _DateButton(
                      label: 'Sowing',
                      date: sowing,
                      onPick: (d) => setState(() => sowing = d))),
              const SizedBox(width: 8),
              Expanded(
                  child: _DateButton(
                      label: 'Harvest',
                      date: harvest,
                      onPick: (d) => setState(() => harvest = d))),
            ]),
            const SizedBox(height: 10),
            TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes')),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    final request = {
      'fieldName': name.text.trim(),
      'location': location.text.trim(),
      'areaSizeAcres': double.tryParse(area.text) ?? 1.0,
      'soilType': soil,
      'crop': crop,
      'sowingDate': _date(sowing),
      'expectedHarvestDate': _date(harvest),
      'waterAvailability': water,
      'cropImageUrl': null,
      'notes': notes.text.trim(),
    };
    final notifier = ref.read(fieldManagementProvider.notifier);
    final id = widget.existing?['id'] as String?;
    if (id == null) {
      await notifier.createField(request);
    } else {
      await notifier.updateField(id, request);
    }
    if (mounted) Navigator.pop(context);
  }
}

class _LogDialog extends ConsumerStatefulWidget {
  final String fieldId;
  final String type;

  const _LogDialog({required this.fieldId, required this.type});

  @override
  ConsumerState<_LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends ConsumerState<_LogDialog> {
  DateTime date = DateTime.now();
  final a = TextEditingController();
  final b = TextEditingController();
  final c = TextEditingController();
  final cost = TextEditingController(text: '0');
  final notes = TextEditingController();
  String financeType = 'expense';

  @override
  void dispose() {
    a.dispose();
    b.dispose();
    c.dispose();
    cost.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _title(widget.type);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 560 ? screenWidth * 0.82 : 460.0;
    return AlertDialog(
      title: Text('Log $title'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _DateButton(
                label: 'Date',
                date: date,
                onPick: (d) => setState(() => date = d)),
            const SizedBox(height: 10),
            ..._fields(),
            const SizedBox(height: 10),
            TextField(
              controller: notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  List<Widget> _fields() {
    if (widget.type == 'irrigation') {
      return [
        TextField(
            controller: a,
            decoration: const InputDecoration(labelText: 'Water amount')),
        const SizedBox(height: 10),
        TextField(
            controller: b,
            decoration: const InputDecoration(labelText: 'Method')),
        const SizedBox(height: 10),
        TextField(
            controller: cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cost')),
      ];
    }
    if (widget.type == 'fertilizer') {
      return [
        TextField(
            controller: a,
            decoration: const InputDecoration(labelText: 'Fertilizer name')),
        const SizedBox(height: 10),
        TextField(
            controller: b,
            decoration: const InputDecoration(labelText: 'Type')),
        const SizedBox(height: 10),
        TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity')),
        const SizedBox(height: 10),
        TextField(
            controller: cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cost')),
      ];
    }
    if (widget.type == 'medicine') {
      return [
        TextField(
            controller: a,
            decoration:
                const InputDecoration(labelText: 'Medicine/pesticide name')),
        const SizedBox(height: 10),
        TextField(
            controller: b,
            decoration:
                const InputDecoration(labelText: 'Disease/pest targeted')),
        const SizedBox(height: 10),
        TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity')),
        const SizedBox(height: 10),
        TextField(
            controller: cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cost')),
      ];
    }
    if (widget.type == 'finance') {
      return [
        _DialogDropdown(
          label: 'Entry type',
          value: financeType,
          items: const ['expense', 'income'],
          onChanged: (value) => setState(() => financeType = value),
        ),
        const SizedBox(height: 10),
        TextField(
            controller: a,
            decoration: const InputDecoration(labelText: 'Category')),
        const SizedBox(height: 10),
        TextField(
            controller: cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount')),
        const SizedBox(height: 10),
        TextField(
            controller: b,
            decoration: const InputDecoration(labelText: 'Description')),
      ];
    }
    return [
      TextField(
          controller: a,
          decoration: const InputDecoration(labelText: 'Activity type')),
      const SizedBox(height: 10),
      TextField(
          controller: b,
          decoration: const InputDecoration(labelText: 'Description')),
      const SizedBox(height: 10),
      TextField(
          controller: cost,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cost')),
      const SizedBox(height: 10),
      TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Income')),
    ];
  }

  Future<void> _save() async {
    final amount = double.tryParse(cost.text) ?? 0.0;
    final request = switch (widget.type) {
      'irrigation' => {
          'date': _date(date),
          'waterAmount': double.tryParse(a.text) ?? 0.0,
          'method': b.text.trim().isEmpty ? 'flood' : b.text.trim(),
          'cost': amount,
          'notes': notes.text.trim(),
        },
      'fertilizer' => {
          'date': _date(date),
          'fertilizerName': a.text.trim(),
          'fertilizerType': b.text.trim(),
          'quantity': double.tryParse(c.text) ?? 0.0,
          'cost': amount,
          'purpose': notes.text.trim(),
          'notes': notes.text.trim(),
        },
      'medicine' => {
          'date': _date(date),
          'medicineName': a.text.trim(),
          'target': b.text.trim(),
          'quantity': double.tryParse(c.text) ?? 0.0,
          'cost': amount,
          'safetyNotes': notes.text.trim(),
        },
      'finance' => {
          'date': _date(date),
          'entryType': financeType,
          'category': a.text.trim(),
          'amount': amount,
          'description': b.text.trim(),
          'notes': notes.text.trim(),
        },
      _ => {
          'date': _date(date),
          'activityType': a.text.trim(),
          'description': b.text.trim(),
          'cost': amount,
          'income': double.tryParse(c.text) ?? 0.0,
          'notes': notes.text.trim(),
        },
    };
    await ref.read(fieldManagementProvider.notifier).addLog(
          fieldId: widget.fieldId,
          type: widget.type,
          request: request,
        );
    if (mounted) Navigator.pop(context);
  }
}

class _ChartPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: AppTextStyles.headingSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        SizedBox(height: 190, child: child),
      ]),
    );
  }
}

class _BreakdownDonut extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _BreakdownDonut({required this.rows});

  @override
  Widget build(BuildContext context) {
    final total = rows.fold<double>(0, (sum, row) => sum + _num(row['amount']));
    if (total <= 0) return const Center(child: Text('No expenses yet'));
    return PieChart(
      PieChartData(
        centerSpaceRadius: 42,
        sections: List.generate(rows.length, (index) {
          final color =
              AppColors.cropColors[index % AppColors.cropColors.length];
          final value = _num(rows[index]['amount']);
          return PieChartSectionData(
            value: value,
            color: color,
            radius: 55,
            title: '${(value / total * 100).toStringAsFixed(0)}%',
            titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
          );
        }),
      ),
    );
  }
}

class _MonthlyLine extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _MonthlyLine({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const Center(child: Text('No monthly logs yet'));
    final spots = List.generate(
        rows.length, (i) => FlSpot(i.toDouble(), _num(rows[i]['expense'])));
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: AppColors.deepGreen,
            isCurved: true,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.deepGreen.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseBar extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const _IncomeExpenseBar({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
                toY: _num(analytics['totalIncomePkr']),
                color: AppColors.deepGreen,
                width: 34)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
                toY: _num(analytics['totalCostPkr']),
                color: AppColors.burntOrange,
                width: 34)
          ]),
        ],
      ),
    );
  }
}

class _UsageBars extends StatelessWidget {
  final Map<String, dynamic> usage;

  const _UsageBars({required this.usage});

  @override
  Widget build(BuildContext context) {
    final values = [
      _num(usage['irrigationEvents']),
      _num(usage['fertilizerEvents']),
      _num(usage['medicineEvents']),
    ];
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              toY: values[index],
              color: AppColors.cropColors[index],
              width: 26,
            ),
          ]),
        ),
      ),
    );
  }
}

class _FieldComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _FieldComparisonChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const Center(child: Text('No comparison yet'));
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(rows.length, (index) {
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              toY: _num(rows[index]['totalCostPkr']),
              color: AppColors.cropColors[index % AppColors.cropColors.length],
              width: 18,
            ),
          ]);
        }),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _GlassPanel({
    required this.child,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.90)),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final String label;

  const _WhiteChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String text;

  const _TaskTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.event_available_rounded,
            size: 15, color: AppColors.amber),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _EmptyBox({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.deepGreen, size: 34),
        const SizedBox(height: 10),
        Text(title, style: AppTextStyles.headingSmall),
        const SizedBox(height: 4),
        Text(text, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.burntOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.burntOrange.withValues(alpha: 0.25)),
      ),
      child: Text(message,
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.burntOrange)),
    );
  }
}

class _DialogDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DialogDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                _title(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          initialDate: date,
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_month_rounded),
      label: Text(
        '$label: ${_date(date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

List<Map<String, dynamic>> _rows(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
  return const [];
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<String> _list(dynamic value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  return const [];
}

double _num(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

String _title(dynamic value) {
  final raw = value?.toString().replaceAll('-', ' ') ?? '';
  return raw
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _money(num value) {
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();
  if (abs >= 1000000) return '$sign PKR ${(abs / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return '$sign PKR ${(abs / 1000).toStringAsFixed(0)}K';
  return '$sign PKR ${abs.toStringAsFixed(0)}';
}

String _date(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
