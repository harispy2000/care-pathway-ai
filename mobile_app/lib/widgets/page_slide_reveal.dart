import 'package:flutter/material.dart';

/// Soft fade + slide-in reveal used for screen content so it feels alive but
/// stays fast and calm.
class PageSlideReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool fromBottom;

  const PageSlideReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.fromBottom = true,
  });

  @override
  State<PageSlideReveal> createState() => _PageSlideRevealState();
}

class _PageSlideRevealState extends State<PageSlideReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final begin = widget.fromBottom
        ? const Offset(0, 0.06)
        : const Offset(0, -0.06);

    _offset = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}