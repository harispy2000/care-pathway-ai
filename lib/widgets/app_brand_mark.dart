import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';

/// Reusable app brand mark: a soft gradient medical badge with a glowing halo.
class AppBrandMark extends StatelessWidget {
  final double size;
  final bool showHalo;

  const AppBrandMark({
    super.key,
    this.size = 96,
    this.showHalo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: showHalo
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        size: size * 0.56,
        color: Colors.white,
      ),
    );
  }
}