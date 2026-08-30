import 'package:flutter/material.dart';

/// Central healthcare palette. Colors resolve per brightness through the
/// [UiColors] extension so screens never hard-code theme-specific values.
abstract final class AppColors {
  static const Color primary = Color(0xFF0E7C75);
  static const Color primaryDark = Color(0xFF0A5F5A);
  static const Color primaryBright = Color(0xFF3FB3A7);
  static const Color secondary = Color(0xFF2E6F9E);
  static const Color tertiary = Color(0xFF5C7A95);

  static const Color success = Color(0xFF2E9E6E);
  static const Color warning = Color(0xFFE0992B);
  static const Color urgent = Color(0xFFE8590C);
  static const Color danger = Color(0xFFDA4036);
  static const Color info = Color(0xFF317FB5);

  // Light mode surfaces / text.
  static const Color lightBg = Color(0xFFF3F8F7);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = Color(0xFFE7F1EF);
  static const Color lightPrimarySoft = Color(0xFFDCF2EF);
  static const Color lightText = Color(0xFF142524);
  static const Color lightTextSubtle = Color(0xFF4E5F5D);
  static const Color lightTextMuted = Color(0xFF83918F);
  static const Color lightBorder = Color(0x14142524);

  // Dark mode surfaces / text.
  static const Color darkBg = Color(0xFF071012);
  static const Color darkSurface = Color(0xFF0F1E20);
  static const Color darkSurfaceMuted = Color(0xFF15272A);
  static const Color darkPrimarySoft = Color(0xFF122F2B);
  static const Color darkText = Color(0xFFE4EFED);
  static const Color darkTextSubtle = Color(0xFFA2B6B3);
  static const Color darkTextMuted = Color(0xFF647B77);
  static const Color darkBorder = Color(0x1FFFFFFF);
}

/// Theme-aware color helpers. Prefer these over raw constants in widgets.
extension UiColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get screenBg => Theme.of(this).scaffoldBackgroundColor;

  Color get cardBg =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  Color get surfaceMuted =>
      isDarkMode ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted;

  /// Soft tint used behind primary icons and hero blocks.
  Color get primarySoft =>
      isDarkMode ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft;

  /// The app's primary accent (tuned for the active brightness).
  Color get primary => isDarkMode
      ? AppColors.primaryBright
      : AppColors.primary;

  Color get inputCardBg => cardBg;

  Color get inputScreenBg =>
      isDarkMode ? AppColors.darkBg : AppColors.lightBg;

  Color get inputFieldBg =>
      isDarkMode ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted;

  Color get textMain =>
      isDarkMode ? AppColors.darkText : AppColors.lightText;

  Color get textSubtle =>
      isDarkMode ? AppColors.darkTextSubtle : AppColors.lightTextSubtle;

  Color get textMuted =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  Color get softBorder =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

  Color get divider =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
}