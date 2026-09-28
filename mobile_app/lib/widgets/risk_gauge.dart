import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_risk.dart';
import '../theme/ui_colors.dart';
import 'app_card.dart';

/// Visual triage summary: level, score and an animated radial gauge with a
/// pseudo-3D ring (lit arc, shaded track and glow).
class RiskGauge extends StatelessWidget {
  final String triageLevel;
  final int riskScore;
  final String? caption;

  const RiskGauge({
    super.key,
    required this.triageLevel,
    required this.riskScore,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final level = appRiskLevelFor(triageLevel, riskScore);
    final color = level.color(context);
    final fraction = (riskScore / 100).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(20),
      color: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CustomPaint(
                    painter: _RadialGauge3DPainter(
                      progress: value,
                      color: color,
                      dark: context.isDarkMode,
                      track: context.isDarkMode
                          ? AppColors.darkSurfaceMuted
                          : AppColors.lightSurfaceMuted,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$riskScore',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: color,
                              height: 1,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.14),
                      ),
                      child: Icon(level.icon, color: color, size: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      triageLevel.isEmpty ? level.label : triageLevel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    caption!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textMain,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A radial gauge with depth: soft track, gradient sweep arc, rounded cap,
/// and an under-shadow so the arc reads as raised off the card.
class _RadialGauge3DPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool dark;
  final Color track;

  _RadialGauge3DPainter({
    required this.progress,
    required this.color,
    required this.dark,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const stroke = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = 135 * math.pi / 180;
    const sweepTotal = 270 * math.pi / 180;

    // Drop shadow under the whole ring for depth.
    canvas.drawArc(
      rect.translate(0, 4),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.black.withValues(alpha: dark ? 0.30 : 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Track.
    canvas.drawArc(
      rect,
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = track,
    );

    if (progress <= 0) return;

    // Value arc with lit gradient.
    final sweep = sweepTotal * progress;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [
          Color.lerp(color, Colors.white, 0.35)!,
          color,
        ],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweep, false, paint);

    // Glowing end cap dot.
    final capAngle = startAngle + sweep;
    final capCenter = Offset(
      center.dx + radius * math.cos(capAngle),
      center.dy + radius * math.sin(capAngle),
    );
    canvas.drawCircle(
      capCenter,
      stroke * 0.55,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_RadialGauge3DPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.dark != dark;
}
