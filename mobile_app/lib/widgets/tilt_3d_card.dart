import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/motion.dart';
import '../theme/ui_colors.dart';

export 'pulse_avatar_3d.dart';

/// Card that tilts in 3D following the device gyroscope (or pointer position
/// on desktop/web), with a glossy sheen that slides across the surface.
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool showSheen;
  final VoidCallback? onTap;
  final Color? background;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadows;
  final double perspective;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTilt = 0.10,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.showSheen = true,
    this.onTap,
    this.background,
    this.gradient,
    this.border,
    this.shadows,
    this.perspective = 0.0022,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> {
  Offset _pointer = Offset.zero;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Motion.instance,
      builder: (context, child) {
        double dx = Motion.instance.x * 0.8;
        double dy = Motion.instance.y * 0.8;

        if (_hovering) {
          dx += _pointer.dx;
          dy += _pointer.dy;
        }

        final tiltX = (-dy * widget.maxTilt).clamp(-1.0, 1.0);
        final tiltY = (dx * widget.maxTilt).clamp(-1.0, 1.0);

        final transform = Matrix4.identity()
          ..setEntry(3, 2, widget.perspective)
          ..rotateX(tiltX)
          ..rotateY(tiltY);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() {
            _hovering = false;
            _pointer = Offset.zero;
          }),
          onHover: (e) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null || !box.hasSize) return;
            final size = box.size;
            if (size.isEmpty) return;
            setState(() {
              _pointer = Offset(
                (e.localPosition.dx / size.width - 0.5) * 2,
                (e.localPosition.dy / size.height - 0.5) * 2,
              );
            });
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: Transform(
              transform: transform,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      color:
                          widget.gradient == null ? (widget.background ?? context.cardBg) : null,
                      gradient: widget.gradient,
                      borderRadius: widget.borderRadius,
                      border: widget.border ??
                          Border.all(color: context.softBorder),
                      boxShadow: widget.shadows ??
                          [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: context.isDarkMode ? 0.30 : 0.06,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                    ),
                    child: child,
                  ),
                  if (widget.showSheen && Motion.instance.enabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: widget.borderRadius,
                          child: CustomPaint(
                            painter: _SheenPainter(
                              shift: dx,
                              dark: context.isDarkMode,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _SheenPainter extends CustomPainter {
  final double shift;
  final bool dark;

  _SheenPainter({required this.shift, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final bandCenter = size.width * (0.5 + shift * 0.5);
    final bandWidth = size.width * 0.42;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: dark ? 0.055 : 0.16),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final band = Rect.fromCenter(
      center: Offset(bandCenter, size.height / 2),
      width: bandWidth,
      height: size.height,
    );

    final paint = Paint()
      ..shader = gradient.createShader(band)
      ..blendMode = BlendMode.srcOver;

    canvas.save();
    canvas.clipRect(rect);
    canvas.rotate(0.22);
    canvas.translate(0, -size.height * 0.15);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(bandCenter, size.height / 2),
        width: bandWidth,
        height: size.height * 1.8,
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) =>
      oldDelegate.shift != shift || oldDelegate.dark != dark;
}

/// Wraps a child stack so layers can drift in 3D against each other:
/// pass larger [depth] values to layers that should move more.
class ParallaxStack extends StatelessWidget {
  final List<Widget> layers;
  final double depth;

  const ParallaxStack({
    super.key,
    required this.layers,
    this.depth = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Motion.instance,
      builder: (context, _) {
        final mx = Motion.instance.x;
        final my = Motion.instance.y;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < layers.length; i++)
              Transform.translate(
                offset: Offset(
                  mx * depth * (0.4 + i * 0.6) * 0.5,
                  my * depth * (0.4 + i * 0.6) * 0.5,
                ),
                child: layers[i],
              ),
          ],
        );
      },
    );
  }
}

/// Wraps a child so it drifts subtly with the tilt. Use inside a Stack for
/// multi-layer parallax scenes.
class ParallaxLayer extends StatelessWidget {
  final Widget child;
  final double depth;

  const ParallaxLayer({
    super.key,
    required this.child,
    this.depth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Motion.instance,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(
            Motion.instance.x * depth,
            Motion.instance.y * depth * 0.7,
          ),
          child: child,
        );
      },
    );
  }
}

/// A card that flips in 3D to reveal a back face — kept as a reusable
/// primitive for "tap for more" interactions.
class Flip3DCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final double height;
  final Duration duration;

  const Flip3DCard({
    super.key,
    required this.front,
    required this.back,
    this.height = 190,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<Flip3DCard> createState() => _Flip3DCardState();
}

class _Flip3DCardState extends State<Flip3DCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _showBack = false;

  void _toggle() {
    HapticFeedback.selectionClick();
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * math.pi;
          final showBack = _controller.value > 0.5;

          final front = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0022)
              ..rotateY(angle),
            child: Opacity(
              opacity: showBack ? 0 : 1,
              child: _SizedBox(height: widget.height, child: widget.front),
            ),
          );

          final back = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0022)
              ..rotateY(angle - math.pi),
            child: Opacity(
              opacity: showBack ? 1 : 0,
              child: _SizedBox(height: widget.height, child: widget.back),
            ),
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              if (!showBack) front else back,
            ],
          );
        },
      ),
    );
  }
}

class _SizedBox extends StatelessWidget {
  final double height;
  final Widget child;

  const _SizedBox({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: double.infinity, child: child);
  }
}
