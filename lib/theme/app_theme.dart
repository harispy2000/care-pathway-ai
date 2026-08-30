import 'package:flutter/material.dart';

import 'app_dimensions.dart';
import 'page_transitions.dart';
import 'ui_colors.dart';

/// Complete Material 3 theme for Care Pathway AI.
///
/// Legacy callers (`AppTheme.primary`, `AppTheme.danger`, ...) still work via
/// the static aliases below; new code should prefer [AppColors] and the
/// theme-aware `context.*` helpers from `ui_colors.dart`.
class AppTheme {
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color secondary = AppColors.secondary;
  static const Color tertiary = AppColors.tertiary;
  static const Color danger = AppColors.danger;
  static const Color warning = AppColors.warning;
  static const Color success = AppColors.success;
  static const Color info = AppColors.info;
  static const Color lightBg = AppColors.lightBg;
  static const Color darkBg = AppColors.darkBg;

  static ThemeData get lightTheme => _build(brightness: Brightness.light);

  static ThemeData get darkTheme => _build(brightness: Brightness.dark);

  // ---------------------------------------------------------------------------
  // Color schemes
  // ---------------------------------------------------------------------------

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.lightPrimarySoft,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD9EAF4),
    onSecondaryContainer: Color(0xFF163F57),
    tertiary: AppColors.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDFE9F0),
    onTertiaryContainer: Color(0xFF28404E),
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFADADA),
    onErrorContainer: Color(0xFF761F1B),
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightText,
    surfaceContainerHighest: AppColors.lightSurfaceMuted,
    onSurfaceVariant: AppColors.lightTextSubtle,
    outline: AppColors.lightTextMuted,
    outlineVariant: Color(0xFFDCE6E4),
    shadow: Color(0xFF142724),
    scrim: Color(0x66000000),
    inverseSurface: Color(0xFF1D2C2B),
    onInverseSurface: Color(0xFFE4EFED),
    inversePrimary: Color(0xFF79CFC3),
    surfaceTint: AppColors.primary,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryBright,
    onPrimary: Color(0xFF06322E),
    primaryContainer: AppColors.darkPrimarySoft,
    onPrimaryContainer: Color(0xFF9BDBD2),
    secondary: Color(0xFF8FC0E0),
    onSecondary: Color(0xFF0B3048),
    secondaryContainer: Color(0xFF163F57),
    onSecondaryContainer: Color(0xFFC7E2F2),
    tertiary: Color(0xFF9DB8CC),
    onTertiary: Color(0xFF132631),
    tertiaryContainer: Color(0xFF28404E),
    onTertiaryContainer: Color(0xFFD0E4F2),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    surfaceContainerHighest: AppColors.darkSurfaceMuted,
    onSurfaceVariant: AppColors.darkTextSubtle,
    outline: AppColors.darkTextMuted,
    outlineVariant: Color(0xFF2A3B3A),
    shadow: Color(0xFF000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFE4EFED),
    onInverseSurface: Color(0xFF1D2C2B),
    inversePrimary: Color(0xFF0E7C75),
    surfaceTint: AppColors.primaryBright,
  );

  // ---------------------------------------------------------------------------
  // Theme construction
  // ---------------------------------------------------------------------------

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? _darkScheme : _lightScheme;
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
    final text = _textTheme(scheme);

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const AppPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.7),
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outlineVariant),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.outline),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        secondaryLabelStyle:
            text.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(color: scheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outlineVariant,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.05),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    const base = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.45),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
    );
    return base.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamily: 'Roboto',
    );
  }
}