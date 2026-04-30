// lib/screens/dashboard/widgets/alert_ticker.dart
//
// Scrolling alert ticker — like a news ticker at the bottom of a TV screen.
// Alerts scroll left continuously. Pauses on hover.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cropsense/core/theme.dart';

class AlertTicker extends StatefulWidget {
  final List<AlertTickerItem> alerts;

  const AlertTicker({super.key, required this.alerts});

  @override
  State<AlertTicker> createState() => _AlertTickerState();
}

class AlertTickerItem {
  final String district;
  final String message;
  final String severity; // 'critical', 'high', 'watch'

  const AlertTickerItem({
    required this.district,
    required this.message,
    required this.severity,
  });

  Color get color {
    switch (severity) {
      case 'critical': return AppColors.riskCritical;
      case 'high':     return AppColors.burntOrange;
      default:         return AppColors.amber;
    }
  }

  IconData get icon {
    switch (severity) {
      case 'critical': return Icons.crisis_alert_rounded;
      case 'high':     return Icons.warning_rounded;
      default:         return Icons.info_rounded;
    }
  }
}

class _AlertTickerState extends State<AlertTicker> {
  late ScrollController _controller;
  Timer? _timer;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    // Start scrolling after a short delay to let the widget render
    Future.delayed(const Duration(milliseconds: 500), _startScrolling);
  }

  void _startScrolling() {
    // Scroll 1 pixel every 30ms = smooth continuous scroll
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_hovering) return; // Pause on hover
      if (!_controller.hasClients) return;

      final max = _controller.position.maxScrollExtent;
      final current = _controller.offset;

      if (current >= max) {
        // Jump back to start seamlessly
        _controller.jumpTo(0);
      } else {
        _controller.animateTo(
          current + 1,
          duration: const Duration(milliseconds: 30),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    // Duplicate alerts so the scroll loops seamlessly
    final doubled = [...widget.alerts, ...widget.alerts];

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          // "LIVE" badge on the left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.burntOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Scrolling alerts area
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovering = true),
              onExit: (_) => setState(() => _hovering = false),
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doubled.length,
                separatorBuilder: (_, __) => Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  color: Colors.white24,
                ),
                itemBuilder: (context, index) {
                  final alert = doubled[index];
                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(alert.icon, color: alert.color, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${alert.district}: ${alert.message}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}