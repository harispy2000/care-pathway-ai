import 'package:flutter/material.dart';

import '../theme/app_risk.dart';
import '../theme/ui_colors.dart';
import 'app_card.dart';

/// Visual triage summary: level, score and an animated scale bar.
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style: TextStyle(fontSize: 12.5, color: context.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$riskScore',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(fontSize: 12, color: context.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                );
              },
            ),
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