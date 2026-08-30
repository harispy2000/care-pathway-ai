import 'package:flutter/material.dart';

/// Central spacing, radius, padding and motion values for the whole app.
/// Screens should use these instead of ad-hoc literals where practical.
abstract final class AppDimensions {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  /// Horizontal gutter used on screens.
  static const double pageGutter = 16;

  static const EdgeInsets pagePadding =
      EdgeInsets.fromLTRB(16, 12, 16, 24);

  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  /// Content is centered within this visual width on large screens.
  static const double maxContentWidth = 640;

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration med = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
}

/// Centers content horizontally and caps its width on tablets/landscape.
class ContentConstrainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ContentConstrainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}