import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Press-to-scale touch feedback with a subtle haptic tick. Use for custom
/// tappable cards where a ripple is not desirable.
class EchoTap extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double maxScale;
  final String? semanticLabel;

  const EchoTap({
    super.key,
    required this.child,
    this.onTap,
    this.maxScale = 0.97,
    this.semanticLabel,
  });

  @override
  State<EchoTap> createState() => _EchoTapState();
}

class _EchoTapState extends State<EchoTap> {
  bool _pressed = false;

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap == null ? null : _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? widget.maxScale : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}