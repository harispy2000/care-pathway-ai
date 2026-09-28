import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';

/// Theme-aware surface used across the app. Renders a soft border, subtle
/// shadow and — when [onTap] is provided — a ripple that respects the radius.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppDimensions.cardPadding,
    this.margin,
    this.color,
    this.borderColor,
    this.radius = AppDimensions.radiusLg,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.cardBg;
    final decoration = BoxDecoration(
      color: resolvedColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? context.softBorder),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.22 : 0.045,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );

    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: decoration.boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: decoration.copyWith(boxShadow: null),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: content,
          ),
        ),
      ),
    );
  }
}