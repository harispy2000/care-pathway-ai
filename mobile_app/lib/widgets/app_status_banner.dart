import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';

enum AppStatusTone { info, success, warning, danger }

/// Non-intrusive inline message banner (disclaimers, notices, inline errors).
class AppStatusBanner extends StatelessWidget {
  final AppStatusTone tone;
  final String message;
  final IconData? icon;

  const AppStatusBanner({
    super.key,
    required this.tone,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AppStatusTone.info => AppColors.info,
      AppStatusTone.success => AppColors.success,
      AppStatusTone.warning => AppColors.warning,
      AppStatusTone.danger => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.textSubtle,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}