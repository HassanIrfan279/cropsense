import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cropsense/config/app_config.dart';
import 'package:cropsense/core/constants.dart';
import 'package:cropsense/core/theme.dart';
import 'package:cropsense/core/utils.dart';
import 'package:cropsense/data/models/chat_message.dart';
import 'package:cropsense/providers/ai_advisor_provider.dart';
import 'package:cropsense/screens/ai_advisor/widgets/risk_meter.dart';
import 'package:cropsense/screens/ai_advisor/widgets/symptom_selector.dart';
import 'package:cropsense/screens/ai_advisor/widgets/advice_result_panel.dart';

class AIAdvisorScreen extends ConsumerStatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  ConsumerState<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends ConsumerState<AIAdvisorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  double _calcRisk(AdvisorFormState f) {
    double s = 0;
    if (f.ndvi < 0.3) {
      s += 30;
    } else if (f.ndvi < 0.5) {
      s += 15;
    }
    if (f.rainfallMm < 50) {
      s += 25;
    } else if (f.rainfallMm < 100) {
      s += 10;
    }
    if (f.tempMaxC > 42) {
      s += 20;
    } else if (f.tempMaxC > 38) {
      s += 10;
    }
    if (f.soilMoisturePct < 20) {
      s += 15;
    }
    if (f.selectedSymptoms.isNotEmpty &&
        !f.selectedSymptoms.contains('no_symptoms')) {
      s += 10;
    }
    return s.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(advisorFormProvider);
    final risk = _calcRisk(form);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(children: [
        _buildHeader(form),
        Expanded(
            child: TabBarView(
          controller: _tabs,
          children: [
            _FormTab(
                form: form, risk: risk, onAnalyzed: () => _tabs.animateTo(1)),
            const _ResultsTab(),
            const _ChatPanel(),
          ],
        )),
      ]),
    );
  }

  Widget _buildHeader(AdvisorFormState form) {
    final isCompact = MediaQuery.of(context).size.width < 800;
    final district = AppDistricts.all.firstWhere(
      (d) => d['id'] == form.district,
      orElse: () => {'label': form.district},
    )['label']!;
    final crop = AppCrops.all.firstWhere(
      (c) => c['id'] == form.crop,
      orElse: () => {'label': form.crop},
    )['label']!;

    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24,
          vertical: isCompact ? 12 : 14,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071F09), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.limeGreen, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Farming Assistant',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  )),
              Text('Grok-powered chatbot with CropSense 2005-2023 context',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11)),
            ],
          )),
          if (!isCompact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white54, size: 13),
                const SizedBox(width: 5),
                Text('$district / $crop',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    )),
              ]),
            ),
        ]),
      ),
      // ── Tab bar ──────────────────────────────────────────────────────
      Container(
        color: AppColors.cardSurface,
        child: TabBar(
          controller: _tabs,
          labelColor: AppColors.deepGreen,
          unselectedLabelColor: AppColors.grey600,
          indicatorColor: AppColors.deepGreen,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(
                icon: Icon(Icons.agriculture_rounded, size: 16),
                text: 'Profile'),
            Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 16),
                text: 'Diagnosis'),
            Tab(
                icon: Icon(Icons.chat_bubble_rounded, size: 16),
                text: 'Assistant'),
          ],
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 0 — Form
// ─────────────────────────────────────────────────────────────────────────────
class _FormTab extends ConsumerWidget {
  final AdvisorFormState form;
  final double risk;
  final VoidCallback onAnalyzed;

  const _FormTab(
      {required this.form, required this.risk, required this.onAnalyzed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(aiAdviceProvider, (prev, next) {
      if (next is AsyncData && next.value != null) onAnalyzed();
    });

    final maxWidth = MediaQuery.of(context).size.width;
    final padH = maxWidth > 1000 ? (maxWidth - 700) / 2 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: 20),
      child: _FormPanel(form: form, risk: risk),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Results
// ─────────────────────────────────────────────────────────────────────────────
class _ResultsTab extends ConsumerWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceAsync = ref.watch(aiAdviceProvider);
    return adviceAsync.when(
      data: (a) => a != null
          ? SingleChildScrollView(child: AdviceResultPanel(advice: a))
          : _EmptyState(),
      loading: () => _ShimmerLoading(),
      error: (e, _) => Center(child: _ErrorWidget(message: e.toString())),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Chat
// ─────────────────────────────────────────────────────────────────────────────
class _ChatPanel extends ConsumerStatefulWidget {
  const _ChatPanel();

  @override
  ConsumerState<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<_ChatPanel> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText(String text) async {
    text = text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await ref.read(chatProvider.notifier).sendMessage(text);
    if (mounted) setState(() => _sending = false);
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    await _sendText(text);
  }

  Future<void> _pickImage() async {
    if (_sending) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      setState(() => _sending = true);
      await ref.read(chatProvider.notifier).analyzeImage(b64);
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    } catch (_) {
      // image_picker not supported or cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final form = ref.watch(advisorFormProvider);

    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Column(children: [
      _ChatContextStrip(
        form: form,
        onClear: () => ref.read(chatProvider.notifier).clearChat(),
      ),
      _QuickQuestionBar(
        sending: _sending,
        onSelected: _sendText,
      ),
      Expanded(
          child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        itemCount: messages.length,
        itemBuilder: (ctx, i) => _ChatBubble(
          message: messages[i],
          onSuggestionTap: _sendText,
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
      )),
      _InputBar(
        controller: _ctrl,
        sending: _sending,
        onSend: _send,
        onPickImage: _pickImage,
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat bubble
// ─────────────────────────────────────────────────────────────────────────────
class _ChatContextStrip extends StatelessWidget {
  final AdvisorFormState form;
  final VoidCallback onClear;

  const _ChatContextStrip({required this.form, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final district = AppDistricts.all.firstWhere(
      (d) => d['id'] == form.district,
      orElse: () => {'label': form.district},
    )['label']!;
    final crop = AppCrops.all.firstWhere(
      (c) => c['id'] == form.crop,
      orElse: () => {'label': form.crop},
    )['label']!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppColors.deepGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal farm assistant',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 15)),
            const SizedBox(height: 3),
            Wrap(spacing: 6, runSpacing: 5, children: [
              _ContextChip(text: district, icon: Icons.location_on_rounded),
              _ContextChip(text: crop, icon: Icons.grass_rounded),
              _ContextChip(
                  text: form.season, icon: Icons.calendar_month_rounded),
              _ContextChip(text: form.soilType, icon: Icons.layers_rounded),
              _ContextChip(
                text: '${form.farmSizeAcres.toStringAsFixed(0)} acres',
                icon: Icons.agriculture_rounded,
              ),
              const _ContextChip(
                text: 'Based on 2005-2023 data',
                icon: Icons.history_rounded,
              ),
            ]),
          ],
        )),
        IconButton(
          tooltip: 'Clear chat',
          onPressed: onClear,
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.grey600,
        ),
      ]),
    );
  }
}

class _ContextChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _ContextChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: AppColors.grey600),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 11, color: AppColors.grey800)),
      ]),
    );
  }
}

class _QuickQuestionBar extends StatelessWidget {
  final bool sending;
  final ValueChanged<String> onSelected;

  const _QuickQuestionBar({required this.sending, required this.onSelected});

  static const _questions = [
    'Which crop is best for me?',
    'How much profit can I expect?',
    'What risks should I avoid?',
    'What fertilizer should I use?',
    'Explain my analytics report',
    'Generate my crop plan',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _questions.map((question) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.bolt_rounded, size: 14),
                label: Text(question, style: const TextStyle(fontSize: 12)),
                onPressed: sending ? null : () => onSelected(question),
                backgroundColor: AppColors.deepGreen.withValues(alpha: 0.06),
                side: BorderSide(
                    color: AppColors.deepGreen.withValues(alpha: 0.16)),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onSuggestionTap;

  const _ChatBubble({required this.message, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_aiAvatar(), const SizedBox(width: 8)],
          Flexible(
              child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _bubble(context, isUser),
              if (!isUser &&
                  message.contentUrdu != null &&
                  message.contentUrdu!.isNotEmpty)
                _urduText(),
              if (!isUser && message.suggestions.isNotEmpty) _suggestions(),
            ],
          )),
          if (isUser) ...[const SizedBox(width: 8), _userAvatar()],
        ],
      ),
    );
  }

  Widget _aiAvatar() => Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.psychology_rounded, color: Colors.white, size: 15),
      );

  Widget _userAvatar() => CircleAvatar(
        radius: 15,
        backgroundColor: AppColors.deepGreen.withValues(alpha: 0.12),
        child: const Icon(Icons.person, color: AppColors.deepGreen, size: 15),
      );

  Widget _bubble(BuildContext context, bool isUser) {
    if (message.isLoading) return _loadingBubble();
    if (message.imageBase64 != null && isUser) return _imageBubble();
    if (message.imageAnalysis != null) return _analysisBubble(context);
    if (!isUser && _hasStructuredAnswer) return _assistantAnswerBubble(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (kIsWeb ? 0.55 : 0.75)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.deepGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.darkText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  bool get _hasStructuredAnswer =>
      message.directAnswer != null ||
      message.dataUsed.isNotEmpty ||
      message.nextSteps.isNotEmpty ||
      message.risksWarnings.isNotEmpty ||
      message.sourceLabels.isNotEmpty;

  Widget _assistantAnswerBubble(BuildContext context) {
    final color =
        message.isError ? const Color(0xFFB71C1C) : AppColors.deepGreen;
    final confidence = message.confidenceLevel?.toLowerCase();

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (kIsWeb ? 0.58 : 0.84)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(
              message.isError
                  ? Icons.warning_amber_rounded
                  : Icons.psychology_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message.isError ? 'Assistant warning' : 'CropSense assistant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            if (confidence != null && confidence.isNotEmpty)
              _ConfidenceBadge(level: confidence),
          ]),
          const SizedBox(height: 10),
          _AnswerSection(
            title: 'Direct answer',
            text: message.directAnswer ?? message.content,
            strong: true,
          ),
          if ((message.explanation ?? '').isNotEmpty)
            _AnswerSection(
                title: 'Short explanation', text: message.explanation!),
          if (message.dataUsed.isNotEmpty)
            _AnswerList(title: 'Data used', items: message.dataUsed),
          if ((message.recommendation ?? '').isNotEmpty)
            _AnswerSection(
                title: 'Recommendation', text: message.recommendation!),
          if (message.risksWarnings.isNotEmpty)
            _AnswerList(title: 'Risks/warnings', items: message.risksWarnings),
          if (message.nextSteps.isNotEmpty)
            _AnswerList(
                title: 'Next steps', items: message.nextSteps, numbered: true),
          if ((message.warning ?? '').isNotEmpty)
            _AnswerSection(title: 'System note', text: message.warning!),
          if (message.sourceLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: message.sourceLabels
                  .map((label) => _SourceChip(label: label))
                  .toList(),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _loadingBubble() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0),
          SizedBox(width: 5),
          _Dot(delay: 180),
          SizedBox(width: 5),
          _Dot(delay: 360),
        ]),
      );

  Widget _imageBubble() => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
        child: Image.memory(
          base64Decode(message.imageBase64!),
          width: 180,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 180,
            height: 60,
            color: AppColors.grey200,
            child: const Icon(Icons.image_not_supported_rounded,
                color: AppColors.grey600),
          ),
        ),
      );

  Widget _analysisBubble(BuildContext context) {
    final r = message.imageAnalysis!;
    final severity = r['severity'] as String? ?? 'Low';
    final color = _severityColor(severity);
    final pct = (r['affectedPct'] as num?)?.toDouble() ?? 0.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (kIsWeb ? 0.50 : 0.80)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.biotech_rounded, color: color, size: 15),
            const SizedBox(width: 6),
            Text('Image Analysis',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13, color: color)),
          ]),
          const SizedBox(height: 10),
          _row('Disease', r['disease'] ?? 'None detected'),
          _row('Severity', severity, color: color),
          const SizedBox(height: 8),
          Text('Affected area', style: AppTextStyles.label),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 3),
          Text('${pct.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          if ((r['treatment'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text('Treatment:', style: AppTextStyles.label),
            const SizedBox(height: 3),
            Text(r['treatment'] as String,
                style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
          if ((r['medicineName'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.deepGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.deepGreen.withValues(alpha: 0.18)),
              ),
              child: Row(children: [
                const Icon(Icons.medication_rounded,
                    size: 14, color: AppColors.deepGreen),
                const SizedBox(width: 6),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['medicineName'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.deepGreen,
                        )),
                    if (r['medicinePrice'] != null)
                      Text(
                          'Rs. ${(r['medicinePrice'] as num).toStringAsFixed(0)}/acre',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey600)),
                  ],
                )),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Text('$label: ', style: AppTextStyles.label),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  Widget _urduText() => Padding(
        padding: const EdgeInsets.only(top: 5, left: 4),
        child: Text(
          message.contentUrdu!,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      );

  Widget _suggestions() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 5,
          children: message.suggestions
              .map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    onPressed: () => onSuggestionTap(s),
                    backgroundColor:
                        AppColors.deepGreen.withValues(alpha: 0.06),
                    side: BorderSide(
                        color: AppColors.deepGreen.withValues(alpha: 0.22)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      );

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return riskColor('critical');
      case 'high':
        return riskColor('high');
      case 'moderate':
        return riskColor('above');
      default:
        return riskColor('good');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing indicator dot
// ─────────────────────────────────────────────────────────────────────────────
class _ConfidenceBadge extends StatelessWidget {
  final String level;

  const _ConfidenceBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'high' => AppColors.riskGood,
      'medium' => AppColors.amber,
      _ => AppColors.burntOrange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '${level.toUpperCase()} confidence',
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  final String title;
  final String text;
  final bool strong;

  const _AnswerSection({
    required this.title,
    required this.text,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: AppTextStyles.label.copyWith(color: AppColors.grey800)),
        const SizedBox(height: 3),
        Text(
          text,
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: strong ? 14.5 : 13.5,
            height: 1.45,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ]),
    );
  }
}

class _AnswerList extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool numbered;

  const _AnswerList({
    required this.title,
    required this.items,
    this.numbered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: AppTextStyles.label.copyWith(color: AppColors.grey800)),
        const SizedBox(height: 4),
        ...List.generate(items.length, (index) {
          final marker = numbered ? '${index + 1}.' : '-';
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: numbered ? 22 : 12,
                child: Text(
                  marker,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  items[index],
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;

  const _SourceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.18)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.source_rounded, size: 11, color: AppColors.skyBlue),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.skyBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
            color: AppColors.grey400, shape: BoxShape.circle),
      )
          .animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: Duration(milliseconds: delay),
          )
          .scaleXY(
              begin: 0.55, end: 1.0, duration: 500.ms, curve: Curves.easeInOut);
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat input bar
// ─────────────────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.grey200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(children: [
          // Image picker button
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            color: AppColors.deepGreen,
            onPressed: sending ? null : onPickImage,
            tooltip: 'Analyze crop image',
          ),
          // Text field
          Expanded(
              child: TextField(
            controller: controller,
            onSubmitted: sending ? null : (_) => onSend(),
            decoration: InputDecoration(
              hintText:
                  'Ask about crop choice, profit, fertilizer, weather risk...',
              hintStyle:
                  const TextStyle(color: AppColors.grey400, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide:
                    const BorderSide(color: AppColors.deepGreen, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: AppColors.grey100,
            ),
            style: const TextStyle(fontSize: 14),
            minLines: 1,
            maxLines: 4,
          )),
          const SizedBox(width: 8),
          // Send button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: sending
                ? Container(
                    key: const ValueKey('loading'),
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.deepGreen,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : GestureDetector(
                    key: const ValueKey('send'),
                    onTap: onSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form panel (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _FormPanel extends ConsumerWidget {
  final AdvisorFormState form;
  final double risk;
  const _FormPanel({required this.form, required this.risk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(advisorFormProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Farm Conditions', Icons.agriculture_rounded),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _Dropdown<String>(
          label: 'District',
          value: form.district,
          items: AppDistricts.all
              .map((d) =>
                  DropdownMenuItem(value: d['id'], child: Text(d['label']!)))
              .toList(),
          onChanged: n.setDistrict,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _Dropdown<String>(
          label: 'Crop',
          value: form.crop,
          items: AppCrops.all
              .map((c) =>
                  DropdownMenuItem(value: c['id'], child: Text(c['label']!)))
              .toList(),
          onChanged: n.setCrop,
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: _Dropdown<String>(
          label: 'Season',
          value: form.season,
          items: ['Rabi', 'Kharif']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: n.setSeason,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _FieldSlider(
          label: 'Farm Size',
          icon: Icons.agriculture_rounded,
          value: form.farmSizeAcres,
          min: 1,
          max: 100,
          unit: ' ac',
          onChanged: n.setFarmSize,
          colorFn: (_) => AppColors.deepGreen,
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: _Dropdown<String>(
          label: 'Soil Type',
          value: form.soilType,
          items: const ['loam', 'clay', 'sandy', 'saline', 'mixed']
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s[0].toUpperCase() + s.substring(1)),
                  ))
              .toList(),
          onChanged: n.setSoilType,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _FieldSlider(
          label: 'Budget',
          icon: Icons.account_balance_wallet_rounded,
          value: form.budgetPkr,
          min: 20000,
          max: 1000000,
          unit: ' PKR',
          onChanged: n.setBudget,
          colorFn: (_) => AppColors.skyBlue,
        )),
      ]),
      const SizedBox(height: 18),
      _sectionLabel('Field Readings', Icons.sensors_rounded),
      const SizedBox(height: 10),
      _FieldSlider(
        label: 'NDVI',
        icon: Icons.eco_rounded,
        value: form.ndvi,
        min: 0.0,
        max: 1.0,
        unit: '',
        decimals: 2,
        onChanged: n.setNdvi,
        colorFn: (v) =>
            Color.lerp(AppColors.riskCritical, AppColors.riskGood, v)!,
      ),
      _FieldSlider(
        label: 'Rainfall',
        icon: Icons.water_drop_rounded,
        value: form.rainfallMm,
        min: 0,
        max: 500,
        unit: ' mm',
        onChanged: n.setRainfall,
        colorFn: (v) {
          if (v < 50) return AppColors.riskCritical;
          if (v < 100) return AppColors.riskWatch;
          if (v < 300) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),
      _FieldSlider(
        label: 'Max Temp',
        icon: Icons.thermostat_rounded,
        value: form.tempMaxC,
        min: 20,
        max: 50,
        unit: '°C',
        onChanged: n.setTempMax,
        colorFn: (v) {
          if (v < 30) return AppColors.riskGood;
          if (v < 38) return AppColors.riskAbove;
          if (v < 43) return AppColors.riskWatch;
          return AppColors.riskCritical;
        },
      ),
      _FieldSlider(
        label: 'Soil Moisture',
        icon: Icons.opacity_rounded,
        value: form.soilMoisturePct,
        min: 10,
        max: 80,
        unit: '%',
        onChanged: n.setSoilMoisture,
        colorFn: (v) {
          if (v < 20) return AppColors.riskCritical;
          if (v < 30) return AppColors.riskWatch;
          if (v < 60) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),
      _FieldSlider(
        label: 'Water Table',
        icon: Icons.water_rounded,
        value: form.waterTableM,
        min: 1,
        max: 20,
        unit: ' m',
        onChanged: n.setWaterTable,
        colorFn: (v) {
          if (v < 3) return AppColors.riskWatch;
          if (v < 12) return AppColors.riskGood;
          return AppColors.riskAbove;
        },
      ),
      if (form.weatherAutoFilled) ...[
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppColors.limeGreen.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_done_rounded,
                size: 13, color: AppColors.limeGreen),
            const SizedBox(width: 5),
            Text('Auto-filled from live weather data',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.limeGreen.withValues(alpha: 0.9),
                )),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      Consumer(builder: (ctx, ref, _) {
        final f = ref.watch(advisorFormProvider);
        return SymptomSelector(
          selected: f.selectedSymptoms,
          onToggle: ref.read(advisorFormProvider.notifier).toggleSymptom,
        );
      }),
      const SizedBox(height: 18),
      RiskMeterWidget(riskScore: risk),
      const SizedBox(height: 14),
      _ConditionSummary(form: form),
      const SizedBox(height: 18),
      Consumer(builder: (ctx, ref, _) {
        final busy = ref.watch(aiAdviceProvider) is AsyncLoading;
        return _AnalyzeButton(busy: busy);
      }),
      const SizedBox(height: 8),
    ]);
  }

  Widget _sectionLabel(String label, IconData icon) => Row(children: [
        Icon(icon, size: 15, color: AppColors.deepGreen),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.headingSmall),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyze button
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyzeButton extends ConsumerWidget {
  final bool busy;
  const _AnalyzeButton({required this.busy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget button = SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(13),
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: busy
                  ? [AppColors.grey400, AppColors.grey400]
                  : [AppColors.amber, const Color(0xFFE65100)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: busy
                ? []
                : [
                    BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            splashColor: Colors.white24,
            onTap: busy
                ? null
                : () => ref.read(aiAdviceProvider.notifier).analyze(),
            child: Center(
              child: busy
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)),
                      const SizedBox(width: 12),
                      Text('Analyzing…',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ])
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.psychology_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text('Analyze with AI',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ]),
            ),
          ),
        ),
      ),
    );

    if (busy) {
      return button
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1300.ms, color: Colors.white30);
    }
    return button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slider
// ─────────────────────────────────────────────────────────────────────────────
class _FieldSlider extends StatelessWidget {
  final String label, unit;
  final IconData icon;
  final double value, min, max;
  final int decimals;
  final ValueChanged<double> onChanged;
  final Color Function(double) colorFn;

  const _FieldSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    required this.colorFn,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFn(value);
    final displayVal = decimals == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimals);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: AppColors.grey600),
          const SizedBox(width: 5),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$displayVal$unit',
              key: ValueKey('$label-$displayVal'),
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
            ).animate(key: ValueKey('$label-$displayVal')).scaleXY(
                begin: 0.85, end: 1.0, duration: 160.ms, curve: Curves.easeOut),
          ),
        ]),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: color,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.grey200),
          boxShadow: AppShadows.card,
        ),
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: (v) => onChanged(v as T),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: AppTextStyles.bodyMedium,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppColors.grey600),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Condition summary chips
// ─────────────────────────────────────────────────────────────────────────────
class _ConditionSummary extends StatelessWidget {
  final AdvisorFormState form;
  const _ConditionSummary({required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.14)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.dashboard_outlined,
              size: 14, color: AppColors.deepGreen),
          const SizedBox(width: 5),
          Text('Field Summary',
              style: AppTextStyles.label.copyWith(color: AppColors.deepGreen)),
        ]),
        const SizedBox(height: 9),
        Wrap(spacing: 7, runSpacing: 6, children: [
          _chip('NDVI', form.ndvi.toStringAsFixed(2), AppColors.limeGreen),
          _chip('Rain', '${form.rainfallMm.toStringAsFixed(0)}mm',
              AppColors.skyBlue),
          _chip('Temp', '${form.tempMaxC.toStringAsFixed(0)}°C',
              AppColors.burntOrange),
          _chip('Moisture', '${form.soilMoisturePct.toStringAsFixed(0)}%',
              AppColors.deepGreen),
          _chip('Water', '${form.waterTableM.toStringAsFixed(0)}m',
              AppColors.skyBlue),
          _chip('Farm', '${form.farmSizeAcres.toStringAsFixed(0)} ac',
              AppColors.limeGreen),
          _chip('Soil', form.soilType, AppColors.deepGreen),
          _chip('Budget', 'PKR ${form.budgetPkr.toStringAsFixed(0)}',
              AppColors.skyBlue),
          if (form.selectedSymptoms.isNotEmpty &&
              !form.selectedSymptoms.contains('no_symptoms'))
            _chip('Symptoms', '${form.selectedSymptoms.length}',
                AppColors.burntOrange),
        ]),
      ]),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(
                fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / shimmer / error states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.amber, size: 48)),
        const SizedBox(height: 20),
        Text('No analysis yet', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Text('Fill the Form tab and tap Analyze with AI',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center),
      ],
    ));
  }
}

class _ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _block(80),
        const SizedBox(height: 12),
        _block(60),
        const SizedBox(height: 12),
        _block(140),
        const SizedBox(height: 12),
        _block(100),
      ]),
    );
  }

  Widget _block(double h) => Container(
        height: h,
        decoration: BoxDecoration(
            color: AppColors.grey200, borderRadius: BorderRadius.circular(12)),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1400.ms, color: Colors.white70);
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFB71C1C).withValues(alpha: 0.28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, color: Color(0xFFB71C1C), size: 32),
        const SizedBox(height: 12),
        Text('Could not get advice',
            style: AppTextStyles.headingSmall
                .copyWith(color: const Color(0xFFB71C1C))),
        const SizedBox(height: 6),
        Text(message,
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('Make sure the backend is running at ${AppConfig.apiBaseUrl}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
