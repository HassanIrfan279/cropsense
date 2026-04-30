import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cropsense/core/utils.dart';

class RiskMeterWidget extends StatelessWidget {
  final double riskScore;
  const RiskMeterWidget({super.key, required this.riskScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(180, 100),
          painter: _GaugePainter(riskScore: riskScore),
        ),
        const SizedBox(height: 8),
        Text(
          'Risk Score: ${riskScore.toStringAsFixed(0)}/100',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: riskScoreColor(riskScore),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double riskScore;
  _GaugePainter({required this.riskScore});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    final colors = [
      const Color(0xFF1B5E20),
      const Color(0xFF8BC34A),
      const Color(0xFFFF8F00),
      const Color(0xFFE65100),
      const Color(0xFFB71C1C),
    ];
    final sweepAngle = pi * (riskScore / 100);
    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: pi + sweepAngle,
      colors: colors,
    );
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, sweepAngle, false, fgPaint);

    final needleAngle = pi + (pi * riskScore / 100);
    final needleX = cx + (radius - 8) * cos(needleAngle);
    final needleY = cy + (radius - 8) * sin(needleAngle);
    final needlePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(needleX, needleY), needlePaint);
    canvas.drawCircle(Offset(cx, cy), 5,
        Paint()..color = const Color(0xFF1A1A1A));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.riskScore != riskScore;
}
