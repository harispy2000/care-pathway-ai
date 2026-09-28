import 'package:flutter/material.dart';

/// A soft glowing avatar with a 3D gradient and a gentle pulse animation.
/// Used for quick actions, reminders and profile accents.
class PulseAvatar3D extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  /// Icon tint. Defaults to white; use a dark accent when placing the
  /// avatar on light/gradient backgrounds so the glyph stays visible.
  final Color iconColor;

  const PulseAvatar3D({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconColor = Colors.white,
  });

  @override
  State<PulseAvatar3D> createState() => _PulseAvatar3DState();
}

class _PulseAvatar3DState extends State<PulseAvatar3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final glowScale = 1.0 + t * 0.28;
        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.18 * (1 - t)),
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withValues(alpha: 0.9),
                      widget.color.withValues(alpha: 0.65),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon,
                    color: widget.iconColor, size: widget.size * 0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
