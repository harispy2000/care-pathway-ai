import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';

enum AppButtonVariant { primary, outline, subtle, danger }

/// Strong, loading-aware button used consistently across the app.
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final double minHeight;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.minHeight = 52,
    this.variant = AppButtonVariant.primary,
  });

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = switch (variant) {
      AppButtonVariant.primary => scheme.onPrimary,
      AppButtonVariant.danger => scheme.onPrimary,
      AppButtonVariant.outline => scheme.primary,
      AppButtonVariant.subtle => scheme.primary,
    };

    final Widget child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: foreground,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.7),
          minimumSize: Size(0, minHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: foreground,
          minimumSize: Size(0, minHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: scheme.outlineVariant),
          minimumSize: Size(0, minHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      AppButtonVariant.subtle => TextButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
    };

    if (variant == AppButtonVariant.outline || variant == AppButtonVariant.subtle) {
      return OutlinedButton(
        onPressed: _enabled ? onPressed : null,
        style: style as ButtonStyle?,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: _enabled ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

/// Small icon-plus-label action, e.g. an emergency call button.
class AppIconActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final double minHeight;

  const AppIconActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.minHeight = 44,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        minimumSize: Size(0, minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}