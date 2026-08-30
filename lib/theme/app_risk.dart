import 'package:flutter/material.dart';

import 'ui_colors.dart';

/// Normalised triage severity used to drive colors, icons and emphasis.
enum AppRiskLevel { low, moderate, urgent, emergency }

/// Maps a backend triage label + risk score to a normalised level.
AppRiskLevel appRiskLevelFor(String triageLevel, int riskScore) {
  final t = triageLevel.toLowerCase();
  if (t.contains('emergency') || riskScore >= 80) return AppRiskLevel.emergency;
  if (t.contains('urgent') || riskScore >= 60) return AppRiskLevel.urgent;
  if (t.contains('moderate') || riskScore >= 40) return AppRiskLevel.moderate;
  return AppRiskLevel.low;
}

extension AppRiskLevelX on AppRiskLevel {
  Color color(BuildContext context) {
    switch (this) {
      case AppRiskLevel.low:
        return AppColors.success;
      case AppRiskLevel.moderate:
        return AppColors.warning;
      case AppRiskLevel.urgent:
        return AppColors.urgent;
      case AppRiskLevel.emergency:
        return AppColors.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case AppRiskLevel.low:
        return Icons.check_circle_outline_rounded;
      case AppRiskLevel.moderate:
        return Icons.monitor_heart_outlined;
      case AppRiskLevel.urgent:
        return Icons.warning_amber_rounded;
      case AppRiskLevel.emergency:
        return Icons.sos_rounded;
    }
  }

  /// Plain, accessible label (not only conveyed through color).
  String get label {
    switch (this) {
      case AppRiskLevel.low:
        return 'Low risk';
      case AppRiskLevel.moderate:
        return 'Moderate';
      case AppRiskLevel.urgent:
        return 'Urgent';
      case AppRiskLevel.emergency:
        return 'Emergency';
    }
  }
}