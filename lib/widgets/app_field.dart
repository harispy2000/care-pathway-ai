import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';

/// Standard app text field. Uses the global [InputDecorationTheme] so it stays
/// consistent everywhere, while keeping call sites short.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int minLines;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Password field with built-in visibility toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const AppPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.validator,
    this.obscureText = true,
    this.onChanged,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidden = !_hidden),
          tooltip: _hidden ? 'Show password' : 'Hide password',
          icon: Icon(
            _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}

/// Controlled dropdown that mirrors the app's input styling and updates
/// reliably when [value] changes programmatically.
class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final IconData? icon;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;
  final bool enabled;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.icon,
    this.itemLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: value == null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        enabled: enabled,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          onChanged: enabled
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          icon: const Icon(Icons.expand_more_rounded),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                itemLabel?.call(e) ?? e.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          dropdownColor: context.cardBg,
          style: TextStyle(
            color: context.textMain,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}